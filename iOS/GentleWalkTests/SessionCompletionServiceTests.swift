import Foundation
import SwiftData
import Testing
import GentleWalkCore
@testable import GentleWalk

@MainActor final class FakeHealthWriter: WorkoutHealthWriting {
    private(set) var saved: [SessionSummary] = []
    func saveWorkout(_ summary: SessionSummary) async { saved.append(summary) }
}

@MainActor final class FakeRescheduler: NotificationRescheduling {
    private(set) var calls = 0
    func reschedule() async { calls += 1 }
}

@MainActor @Suite(.serialized) struct SessionCompletionServiceTests {
    let calendar = { var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(identifier: "America/New_York")!; return c }()

    /// Keeps each test's in-memory container alive (a context whose container is freed crashes).
    let container = try! ModelContainerFactory.make(inMemory: true)

    let levelDefaults: UserDefaults = {
        let defaults = UserDefaults(suiteName: "SessionCompletionServiceTests")!
        defaults.removePersistentDomain(forName: "SessionCompletionServiceTests")
        return defaults
    }()
    var levels: WalkLevelStore { WalkLevelStore(defaults: levelDefaults) }

    func service(entitlement: Entitlement = .subscribed) throws -> (SessionCompletionService, ModelContext, FakeHealthWriter, FakeRescheduler) {
        let context = container.mainContext
        let health = FakeHealthWriter()
        let notifications = FakeRescheduler()
        let service = SessionCompletionService(context: context, content: TestFixtures.content, entitlement: { entitlement },
                                               health: health, notifications: notifications, levels: levels,
                                               cheers: CheerMemoryStore(defaults: levelDefaults), calendar: calendar)
        return (service, context, health, notifications)
    }

    func summary(minutes: Double, on date: Date, breaks: Int = 0, level: WalkLevel = .seated) -> SessionSummary {
        SessionSummary(date: date, kind: .walk, level: level, intensity: .steady, place: .indoors,
                       activeSeconds: Int(minutes * 60), breakCount: breaks)
    }

    func day(_ d: Int, _ hour: Int = 9) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: d, hour: hour))!
    }

    @Test func twelveMinutesSavesARecordAndMovesTheJourney() async throws {
        let (service, context, health, notifications) = try service()
        let first = try await service.complete(summary(minutes: 12, on: day(28), breaks: 1))
        #expect(abs(first.sessionMiles - 0.6) < 0.0001)
        #expect(first.unlockedStops.map(\.id) == ["pc.ny.zoo"])
        #expect(first.isFirstWorkout)
        #expect(first.activeDays == 1)
        let records = try context.fetch(FetchDescriptor<WorkoutRecord>())
        #expect(records.count == 1)
        #expect(records[0].activeSeconds == 720)
        #expect(records[0].breakCount == 1)
        #expect(records[0].kind == "walk")
        let journey = try #require(try context.fetch(FetchDescriptor<JourneyState>()).first { $0.isCurrent })
        #expect(journey.journeyID == "jr.ny")
        #expect(abs(journey.miles - 0.6) < 0.0001)
        #expect(health.saved.count == 1)
        #expect(notifications.calls == 1)
    }

    @Test func crossingAStopUnlocksItsPostcard() async throws {
        let (service, context, _, _) = try service()
        _ = try await service.complete(summary(minutes: 12, on: day(21)))
        let second = try await service.complete(summary(minutes: 10, on: day(22)))  // 0.6 + 0.5 = 1.1 ≥ 1.0 Bethesda
        #expect(second.unlockedStops.map(\.id) == ["pc.ny.bethesda"])
        #expect(second.nextStop?.id == "pc.ny.times")
        #expect(second.activeDays == 2)
        let unlocks = try context.fetch(FetchDescriptor<PostcardUnlock>())
        #expect(Set(unlocks.map(\.stopID)) == ["pc.ny.zoo", "pc.ny.bethesda"])
    }

    /// The route is complete in the session that reaches its end, not in every one after it
    /// (each later session offered the plans again; review 02/10/2026).
    @Test func journeyCompleteOnlyOnce() async throws {
        let (service, _, _, _) = try service()
        let finish = try await service.complete(summary(minutes: 110, on: day(21)))
        #expect(finish.journeyComplete)
        let after = try await service.complete(summary(minutes: 10, on: day(22)))
        #expect(!after.journeyComplete)
    }

    @Test func sameDayTwiceIsOneActiveDay() async throws {
        let (service, _, _, _) = try service()
        _ = try await service.complete(summary(minutes: 5, on: day(28, 8)))
        let again = try await service.complete(summary(minutes: 5, on: day(28, 18)))
        #expect(again.activeDays == 1)
        #expect(!again.isFirstWorkout)
    }

    @Test func stoppingAfterThreeMinutesStillCounts() async throws {
        let (service, context, _, _) = try service()
        let result = try await service.complete(summary(minutes: 3, on: day(28)))
        #expect(result.activeDays == 1)
        #expect(try context.fetch(FetchDescriptor<WorkoutRecord>()).count == 1)
    }

    @Test func seventhActiveDayReachesSprout() async throws {
        let (service, _, _, _) = try service()
        var last: CompletionResult?
        for d in 21...27 { last = try await service.complete(summary(minutes: 5, on: day(d))) }
        #expect(last?.activeDays == 7)
        #expect(last?.reachedLevel == .sprout)
    }

    @Test func feelingIsSavedOnTheRecord() async throws {
        let (service, context, _, _) = try service()
        let result = try await service.complete(summary(minutes: 8, on: day(28)))
        try service.recordFeeling(.tooHard, for: result.recordID)
        #expect(try context.fetch(FetchDescriptor<WorkoutRecord>()).first?.feeling == "tooHard")
    }

    /// "First leg free" (owner 30/09/2026): a free user walks to the second stop, then the route stops.
    @Test func freeUserOnAPaidRouteWalksTheFirstLegButMilesCount() async throws {
        let (service, context, _, _) = try service(entitlement: .free)
        context.insert(JourneyState(journeyID: "jr.smoky", miles: 0, isCurrent: true, startedAt: day(20)))
        try context.save()
        let result = try await service.complete(summary(minutes: 60, on: day(28)))  // 3 miles
        #expect(result.unlockedStops.map(\.id) == ["pc.smoky.1", "pc.smoky.2"])
        #expect(result.isLockedAhead)
        let journey = try #require(try context.fetch(FetchDescriptor<JourneyState>()).first { $0.isCurrent })
        #expect(abs(journey.miles - 3) < 0.0001)
    }

    @Test func upgradingUnlocksTheStopsWalkedPastWhileFree() async throws {
        let context = container.mainContext
        // Walked 3 miles of Smoky on the free plan (capped at the first stop), then bought Pro.
        context.insert(JourneyState(journeyID: "jr.smoky", miles: 3, isCurrent: true, startedAt: day(20)))
        context.insert(PostcardUnlock(journeyID: "jr.smoky", stopID: "pc.smoky.1", unlockedAt: day(21)))
        try context.save()
        let (pro, _, _, _) = try service(entitlement: .subscribed)
        let result = try await pro.complete(summary(minutes: 6, on: day(28)))  // 3.3 miles
        #expect(result.unlockedStops.map(\.id) == ["pc.smoky.2"])
        #expect(result.nextStop?.id == "pc.smoky.3")
    }

    // MARK: Level changes when the feeling is recorded (plan 08/10/2026 task 0.3)

    /// Walks three sessions at `level` from `firstDay` and answers each with `feeling`.
    func walk(_ count: Int, at level: WalkLevel, from firstDay: Int, feeling: Feeling, on service: SessionCompletionService) async throws {
        for offset in 0..<count {
            let result = try await service.complete(summary(minutes: 10, on: day(firstDay + offset), level: level))
            try service.recordFeeling(feeling, for: result.recordID)
        }
    }

    @Test func threeTooHardAtInPlaceMovesDownAndKeepsACard() async throws {
        let (service, _, _, _) = try service()
        levels.set(level: .inPlace, changedAt: day(1), card: nil)
        try await walk(3, at: .inPlace, from: 2, feeling: .tooHard, on: service)
        #expect(levels.state(startLevel: .seated) == LevelState(level: .seated, changedAt: day(4)))
        #expect(levels.pendingCard == .movedDown(to: .seated))
    }

    @Test func threeTooEasyAtSeatedMovesUp() async throws {
        let (service, _, _, _) = try service()
        try await walk(3, at: .seated, from: 2, feeling: .tooEasy, on: service)
        #expect(levels.state(startLevel: .seated).level == .inPlace)
        #expect(levels.pendingCard == .movedUp(to: .inPlace))
        // Then "Too hard" three times at the new level steps back down.
        try await walk(3, at: .inPlace, from: 5, feeling: .tooHard, on: service)
        #expect(levels.state(startLevel: .seated).level == .seated)
        #expect(levels.pendingCard == .movedDown(to: .seated))
    }

    @Test func justRightChangesNothing() async throws {
        let (service, _, _, _) = try service()
        try await walk(4, at: .seated, from: 2, feeling: .justRight, on: service)
        #expect(levels.state(startLevel: .seated) == LevelState(level: .seated, changedAt: nil))
        #expect(levels.pendingCard == nil)
    }

    // MARK: Complete cheers (plan 08/10/2026 task 3.6)

    /// A new line every session, never the same one twice in a row, remembered across launches.
    @Test func cheerNeverRepeatsTwiceInARow() async throws {
        let (service, _, _, _) = try service()
        var last: Cheer?
        for d in 21...30 {
            let result = try await service.complete(summary(minutes: 10, on: day(d)))
            let cheer = try #require(result.cheer)
            #expect(cheer.id != last?.id, "day \(d)")
            #expect(CheerMemoryStore(defaults: levelDefaults).lastID == cheer.id)
            last = cheer
        }
    }

    @Test func firstSessionGetsTheFirstSessionCheerAndNumberOne() async throws {
        let (service, _, _, _) = try service()
        let first = try await service.complete(summary(minutes: 5, on: day(21)))
        #expect(first.cheerContext == .firstSession)
        #expect(first.sessionNumber == 1)
        let second = try await service.complete(summary(minutes: 5, on: day(22)))
        #expect(second.cheerContext == .ordinary)
        #expect(second.sessionNumber == 2)
    }

    /// Her rest days decide when the week is done: Monday 28 Sep to Friday 2 Oct with Saturday and Sunday off.
    @Test func weekDoneFollowsHerRestDays() async throws {
        let (service, context, _, _) = try service()
        context.insert(UserProfile(name: "Margaret", restDays: [7, 1], onboardingCompleted: true))
        var contexts: [CheerContext?] = []
        for d in [28, 29, 30] { contexts.append(try await service.complete(summary(minutes: 10, on: day(d))).cheerContext) }
        for d in [1, 2] {
            let date = calendar.date(from: DateComponents(year: 2026, month: 10, day: d, hour: 9))!
            contexts.append(try await service.complete(summary(minutes: 10, on: date)).cheerContext)
        }
        #expect(contexts == [.firstSession, .ordinary, .ordinary, .ordinary, .weekDone])
    }
}

