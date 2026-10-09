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
        #expect(CaptureState.allCases.count == 138)
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

    /// The stage-recap states (plan 09/10/2026) parse.
    @Test func stageRecapStatesParse() {
        for name in ["today-stage-recap", "program-recaps", "program-finished-route", "journey-with-stages"] {
            #expect(CaptureHook.state(from: ["GentleWalk", "-ScreenshotMode", name]) != nil, "\(name)")
        }
    }

    /// The stage-recap captures tell one story: the program week, the sessions, journey miles, postcards and
    /// checks agree (an earlier fixture showed week 3 of 12 next to four weeks of results).
    @Test(arguments: [22, 52, 86])
    func programStoryIsConsistent(days: Int) throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        // Friday 9 October 2026, 9:05 in New York.
        let now = try #require(calendar.date(from: DateComponents(year: 2026, month: 10, day: 9, hour: 9, minute: 5)))
        let container = try ModelContainerFactory.make(inMemory: true)
        let context = ModelContext(container)
        try CaptureHook.seed(CaptureFixture.load(bundle: .main), into: context, now: now, calendar: calendar)
        ProgramStory.seed(context, now: now, calendar: calendar, programDays: days, journeys: TestFixtures.content.journeys,
                          restDays: [7, 1], reminderMinutes: 510)
        try context.save()

        let program = try #require(try context.fetch(FetchDescriptor<ProgramState>()).first)
        let position = ProgramCalendar.position(program.programRound, on: now, calendar: calendar)
        #expect(position == (days >= 84 ? .finished : .week(days / 7 + 1, .of(week: days / 7 + 1))))

        let workouts = try context.fetch(FetchDescriptor<WorkoutRecord>(sortBy: [SortDescriptor(\.date)]))
        #expect(workouts.first.map { calendar.startOfDay(for: $0.date) } == program.start)
        #expect(workouts.allSatisfy { $0.date < calendar.startOfDay(for: now) })
        #expect(workouts.allSatisfy { ![7, 1].contains(calendar.component(.weekday, from: $0.date)) })

        // Miles add up: every route's miles are the sessions walked on it, its postcards the stops those miles reach.
        let states = try context.fetch(FetchDescriptor<JourneyState>())
        #expect(states.filter(\.isCurrent).count == 1)
        let unlocks = try context.fetch(FetchDescriptor<PostcardUnlock>())
        for state in states {
            let journey = try #require(TestFixtures.content.journeys.first { $0.id == state.journeyID })
            let opened = Set(unlocks.filter { $0.journeyID == state.journeyID }.map(\.stopID))
            #expect(opened == JourneyProgress.reached(journey, at: state.miles), "\(state.journeyID)")
        }
        let routeMiles = states.reduce(0) { $0 + $1.miles }
        let earned = workouts.reduce(0) { $0 + $1.journeyMiles }
        #expect(abs(routeMiles - earned) < 1e-6)

        // A check every two weeks from the first session, none in the future.
        let checks = try context.fetch(FetchDescriptor<SelfCheckRecord>(sortBy: [SortDescriptor(\.date)]))
        #expect(checks.count == (days + 13) / 14)
        #expect(checks.first?.week == 0)
        #expect(checks.allSatisfy { $0.date < now })
    }

    /// The new onboarding's states parse; the old ones are gone (plan 08/10/2026 task 2.14).
    @Test func onboardingStatesParse() {
        for name in ["onboarding-welcome", "onboarding-goal", "onboarding-barriers", "onboarding-name", "onboarding-activity",
                     "onboarding-strength", "onboarding-sore-spots", "onboarding-anything-else", "onboarding-plan",
                     "onboarding-plan-coach"] {
            #expect(CaptureHook.state(from: ["GentleWalk", "-ScreenshotMode", name]) != nil, "\(name)")
        }
        for gone in ["onboarding-understanding-joints", "onboarding-understanding-charged", "onboarding-body"] {
            #expect(CaptureHook.state(from: ["GentleWalk", "-ScreenshotMode", gone]) == nil, "\(gone)")
        }
    }
}
