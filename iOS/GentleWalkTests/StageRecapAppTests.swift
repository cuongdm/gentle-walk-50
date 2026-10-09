import Foundation
import SwiftData
import Testing
import GentleWalkCore
@testable import GentleWalk

/// The plan and the journey as one story (docs/plans/2026-10-09-plan-journey-link.md): the app reads stage recaps
/// from the store, remembers breaks she picked up from and the stage card she tapped away.
@MainActor @Suite(.serialized) struct StageRecapAppTests {
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        return calendar
    }()

    func at(_ month: Int, _ day: Int, hour: Int = 9) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour))!
    }

    /// Margaret with a program from Monday 7 September and 12-minute sessions on the given days.
    func makeApp(now: Date, sessionDays: [Date]) -> AppModel {
        let container = try! ModelContainerFactory.make(inMemory: true)
        let defaults = UserDefaults(suiteName: "stage-recap-tests")!
        defaults.removePersistentDomain(forName: "stage-recap-tests")
        let context = container.mainContext
        context.insert(UserProfile(name: "Margaret", onboardingCompleted: true))
        context.insert(ProgramState(start: at(9, 7, hour: 0)))
        var miles = 0.0
        let ny = TestFixtures.content.journeys.first { $0.id == "jr.ny" }!
        for day in sessionDays {
            context.insert(WorkoutRecord(date: day, kind: "walk", level: "seated", intensity: "steady", place: "indoors",
                                         activeSeconds: 12 * 60, journeyMiles: 0.6))
            let before = miles
            miles += 0.6
            for stop in JourneyProgress.advance(journey: ny, from: before, to: miles).unlocked {
                context.insert(PostcardUnlock(journeyID: "jr.ny", stopID: stop, unlockedAt: day))
            }
        }
        context.insert(JourneyState(journeyID: "jr.ny", miles: miles, isCurrent: true, startedAt: at(9, 7)))
        try! context.save()
        let app = AppModel(container: container, content: TestFixtures.content, store: StoreService(backend: FakePurchaseBackend(now: now)),
                           health: HealthService(store: CaptureHealthStore(connected: true), defaults: defaults),
                           notificationCenter: CaptureNotificationCenter(),
                           location: LocationService(manager: CaptureLocationManager(), background: CaptureBackgroundActivity()),
                           pedometer: PedometerService(pedometer: CapturePedometer()), motion: MotionService(), defaults: defaults)
        app.entitlementOverride = .subscribed
        app.now = { now }
        app.calendar = calendar
        app.reload()
        return app
    }

    /// Weekdays from `first` up to (not including) `end`.
    func weekdays(from first: Date, to end: Date) -> [Date] {
        var days: [Date] = []
        var day = first
        while day < end {
            if !calendar.isDateInWeekend(day) { days.append(day) }
            day = calendar.date(byAdding: .day, value: 1, to: day)!
        }
        return days
    }

    @Test func stageCardShowsUntilTappedAway() throws {
        let app = makeApp(now: at(9, 28), sessionDays: weekdays(from: at(9, 7, hour: 8), to: at(9, 26)))
        let recap = try #require(app.programRecap.turn)
        #expect(recap.stage == .base)
        #expect(recap.activeDays == 15)
        #expect(app.programRecap.stages.map(\.status) == [.done, .soFar])
        #expect(app.today?.specialCard == .stageDone(recap))
        // Every stop she reached in stage 1, on the route she is on.
        #expect(app.programRecap.journeyStages.map(\.stage) == [.base])
        #expect(app.programRecap.journeyStages.first?.stops.first?.name == "Central Park Zoo")

        app.dismissStageRecap()
        #expect(ProgramMemoryStore(defaults: app.defaults).dismissedStage == StageMark(round: 1, stage: 1))
        #expect(app.programRecap.turn == nil)
        #expect(app.today?.specialCard != .stageDone(recap))
    }

    /// "Pick up at week 4" keeps the sessions before the break in their stage; a new 12 weeks forgets the break.
    @Test func pickingUpKeepsEarlierSessionsInTheirStage() throws {
        let app = makeApp(now: at(10, 20), sessionDays: weekdays(from: at(9, 7, hour: 8), to: at(10, 1, hour: 0)))
        #expect(app.today?.programStrip?.pickUpWeek == 4)
        app.pickUpProgram()
        let pauses = ProgramMemoryStore(defaults: app.defaults).pauses
        #expect(pauses.count == 1)
        #expect(pauses.first?.days == 20)
        #expect(app.today?.programStrip?.kind == .week(4, .build))
        #expect(app.programRecap.stages.map(\.activeDays) == [15, 3])

        app.restartProgram()
        #expect(ProgramMemoryStore(defaults: app.defaults).pauses.isEmpty)
    }

    /// The finish screen counts this round: its days and its whole route.
    @Test func finishSummaryCountsThisRound() throws {
        let app = makeApp(now: at(12, 2), sessionDays: weekdays(from: at(9, 7, hour: 8), to: at(11, 30)))
        let summary = app.programFinishedSummary()
        let whole = try #require(summary.route)
        #expect(summary.activeDays == whole.activeDays)
        #expect(whole.first?.name == "Central Park Zoo")
        #expect(whole.last?.name == "Brooklyn Bridge")
        #expect(app.programRecap.stages.count == 4)
    }
}
