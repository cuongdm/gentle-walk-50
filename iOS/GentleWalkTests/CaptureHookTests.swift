import Foundation
import SwiftData
import SwiftUI
import Testing
import GentleWalkCore
@testable import GentleWalk

@Suite(.serialized) @MainActor
struct CaptureHookTests {
    @Test func parsesScreenshotModeArgument() {
        #expect(CaptureHook.state(from: ["GentleWalk", "-ScreenshotMode", "paywall-eligible"]) == .paywallEligible)
        #expect(CaptureHook.state(from: ["GentleWalk", "-ScreenshotMode", "today-trial-ending"]) == .todayTrialEnding)
        #expect(CaptureHook.state(from: ["GentleWalk", "-ScreenshotMode", "all-sessions-free"]) == .allSessionsFree)
        #expect(CaptureHook.state(from: ["GentleWalk", "-ScreenshotMode", "countdown"]) == .countdown)
        #expect(CaptureHook.state(from: ["GentleWalk", "-ScreenshotMode", "not-a-state"]) == nil)
        #expect(CaptureHook.state(from: ["GentleWalk", "-ScreenshotMode"]) == nil)
        #expect(CaptureHook.state(from: ["GentleWalk"]) == nil)
    }

    /// Review M10: only "-xxl" states pin a text size; the rest follow the simulator (for @xxl).
    @Test func onlyXxlStatesPinTheTextSize() {
        #expect(CaptureRouter.pinnedTypeSize(for: .todayXxl) == .accessibility3)
        #expect(CaptureRouter.pinnedTypeSize(for: .today) == nil)
    }

    @Test func coversEveryPlannedState() {
        #expect(CaptureState.allCases.count == 119)
    }

    @Test func seedsMargaretFixture() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        // Wednesday 1 October 2026, 9:00 in New York.
        let now = try #require(calendar.date(from: DateComponents(year: 2026, month: 10, day: 1, hour: 9)))
        let container = try ModelContainerFactory.make(inMemory: true)
        let context = ModelContext(container)

        try CaptureHook.seed(CaptureFixture.load(bundle: .main), into: context, now: now, calendar: calendar)

        let profile = try #require(try context.fetch(FetchDescriptor<UserProfile>()).first)
        #expect(profile.name == "Margaret")
        #expect(profile.bodyLimits == ["knees", "noFloor"])
        #expect(profile.onboardingCompleted)

        let workouts = try context.fetch(FetchDescriptor<WorkoutRecord>())
        let days = Set(workouts.map { calendar.startOfDay(for: $0.date) })
        #expect(workouts.count == 13)
        #expect(days.count == 13)
        #expect(workouts.allSatisfy { !profile.restDays.contains(calendar.component(.weekday, from: $0.date)) })
        #expect(workouts.allSatisfy { $0.date < calendar.startOfDay(for: now) })

        let journey = try #require(try context.fetch(FetchDescriptor<JourneyState>()).first)
        #expect(journey.journeyID == "jr.ny")
        #expect(journey.miles == 1.8)
        #expect(journey.isCurrent)
        #expect(try context.fetchCount(FetchDescriptor<PostcardUnlock>()) == 2)

        // Steady program: week 3, two self-checks done with her hands (task 4.1).
        let program = try #require(try context.fetch(FetchDescriptor<ProgramState>()).first)
        #expect(ProgramCalendar.position(program.programRound, on: now, calendar: calendar) == .week(3, .base))
        let checks = try context.fetch(FetchDescriptor<SelfCheckRecord>(sortBy: [SortDescriptor(\.date)]))
        #expect(checks.map(\.count) == [7, 8])
        #expect(checks.allSatisfy { $0.usedHands })
    }

    /// Every steady-program state parses (task 4.1).
    @Test func steadyProgramStatesParse() {
        for name in ["today-program", "today-check-due", "program", "selfcheck-intro", "selfcheck-timer", "selfcheck-count",
                     "progress-checks", "complete-check-invite", "complete-reps-up", "program-finished"] {
            #expect(CaptureHook.state(from: ["GentleWalk", "-ScreenshotMode", name]) != nil, "\(name)")
        }
    }
}
