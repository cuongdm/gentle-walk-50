import Foundation
import SwiftData
import Testing
import GentleWalkCore
@testable import GentleWalk

// Milestone 4 personalisation in the app (docs/plans/2026-10-08-ui-onboarding-personalization.md, P1–P13).

extension TodayModelTests {
    func workouts(_ feelings: [Feeling?], level: WalkLevel = .seated) -> [TodayInput.Workout] {
        zip([22, 23, 24, 25], feelings).map { TodayInput.Workout(date: at($0), feeling: $1, breakCount: 0, level: level) }
    }

    /// 4.2 (P2, D16): two "Too hard" in a row: Achy chosen in advance, two minutes shorter, and why.
    @Test func twoTooHardPreselectsAchy() {
        let plain = model(input())
        let hard = model(input(workouts: workouts([.justRight, .justRight, .tooHard, .tooHard])))
        #expect(hard.checkedIn == .achy)
        #expect(hard.intensity == .gentle)
        #expect(hard.checkInNote == "After last time, we'll keep it gentle. Change it if you like.")
        #expect(hard.request?.minutesDelta == -2)
        // The shorter card is for Breaks; the line under the check-in says it here.
        #expect(hard.specialCard != .shorter)
        // She can still change it.
        hard.checkIn(.okay)
        #expect(hard.intensity == .steady)
        #expect(plain.checkedIn == nil && plain.checkInNote == nil)
    }

    /// 4.2: "Mostly sitting" starts gentle for ten sessions and shorter for two weeks.
    @Test func mostlySitStartsGentleAndShorter() {
        var value = input()
        value.activity = .mostlySit
        let model = model(value)
        #expect(model.checkedIn == .achy)
        #expect(model.request?.minutesDelta == -2)
        value.workouts = (1...12).map { TodayInput.Workout(date: at($0), feeling: .justRight, breakCount: 0, level: .seated) }
        #expect(self.model(value).checkedIn == nil)
        #expect(self.model(value).request?.minutesDelta == 0)
    }

    /// 4.8 (P9): a check down by two chooses Okay (never Strong) in advance.
    @Test func checkDownSuggestsOkay() {
        var value = input()
        value.checkTrend = .down
        #expect(model(value).checkedIn == .okay)
    }

    /// 4.3 (P4): her goal shows under today's session only when the session serves it.
    @Test func goalLineOnlyWhenTheSessionFits() {
        var value = input()
        value.goals = [.lessPain, .steadier]
        #expect(model(value).goalLine == "Gentle on your joints")
        value.goals = [.notSure]
        #expect(model(value).goalLine == nil)
        let fit = GoalText.SessionFit(isWalk: false, hasSitToStand: false, hasSteadySet: false)
        #expect(GoalText.todayLine(.chairs, session: fit) == nil)
        #expect(GoalText.todayLine(.chairs, session: .init(isWalk: false, hasSitToStand: true, hasSteadySet: false))
            == "For getting up from chairs")
        #expect(GoalText.todayLine(.moreEnergy, session: .init(isWalk: true, hasSitToStand: false, hasSteadySet: false)) != nil)
        // Done for today: no line.
        value.goals = [.lessPain]
        value.workouts.append(.init(date: at(28, hour: 8), feeling: nil, breakCount: 0, level: .seated))
        #expect(model(value).goalLine == nil)
        // Everyday wins for her goal first, the rest in order.
        let wins = GoalText.sorted(["win.1", "win.2", "win.3", "win.4"], id: { $0 }, goal: .steadier)
        #expect(wins == ["win.4", "win.1", "win.2", "win.3"])
    }

    /// 4.9 (P6): Monday and Tuesday say last week's chip; the week's answer shapes the session.
    @Test func lastWeekLineOnMonday() {
        var value = input()
        value.weeklyNotes = [WeeklyNote(weekStart: at(21, hour: 0), effort: .harder, better: .stairs, answeredAt: at(27))]
        let monday = model(value)
        #expect(monday.lastWeekLine == "Last week you said stairs felt a bit better. Let's keep the leg work going.")
        #expect(monday.checkedIn == .achy)
        #expect(monday.request?.minutesDelta == -2)
        value.now = at(30)
        #expect(model(value).lastWeekLine == nil)
        value.now = at(28)
        value.weeklyNotes = [WeeklyNote(weekStart: at(21, hour: 0), effort: .easier, better: nil, answeredAt: at(27))]
        #expect(model(value).request?.minutesDelta == 2)
        #expect(model(value).checkedIn == .great)
    }

    /// 4.5 (P3): a move set aside in the last days gets its card, by name.
    @Test func setAsideCardNamesTheMove() {
        var value = input()
        value.exerciseRules = ExerciseRules(setAside: ["mv.mini-squat": at(27).addingTimeInterval(28 * 86_400)])
        #expect(model(value).specialCard == .setAside(name: "Mini-squat"))
        value.now = at(28, 10)
        #expect(model(value).specialCard != .setAside(name: "Mini-squat"))
    }

    /// 4.1 + 4.15 (P1, P7): today's request carries the opening; the first session of a program week
    /// opens with the week line.
    @Test func requestOpensWithTheDay() throws {
        var value = input()
        value.program = ProgramRound(start: at(28, hour: 0))
        let model = model(value)
        let request = try #require(model.request)
        #expect(request.opening?.history == .week(1))
        let plan = try request.plan(content: TestFixtures.content)
        #expect(plan.lineIDs.first == "a13.week.1")
        // The same session outdoors or picked from All sessions has no opening.
        var outdoors = request
        outdoors.place = .outdoors
        let outdoorLines = try outdoors.plan(content: TestFixtures.content).lineIDs
        #expect(!outdoorLines.contains { $0.hasPrefix("a13.") || ["a9.gentle", "a9.steady", "a9.strong"].contains($0) })
    }
}

extension AppFlowTests {
    /// 4.7 (P13): "Pick up at week N" lowers both ladders one step.
    @Test func pickUpLowersLadders() throws {
        let app = makeApp(entitlement: .subscribed)
        let support = SupportLadderStore(defaults: app.defaults)
        support.record(steady: ["bl.tandem"], troubled: [], announced: [])
        support.record(steady: ["bl.tandem"], troubled: [], announced: [])
        #expect(support.progress["bl.tandem"]?.level == .oneHand)
        let reps = RepLadderStore(defaults: app.defaults)
        reps.record(done: ["mv.sit-to-stand": 1], steady: ["mv.sit-to-stand"], troubled: [], shown: [])
        reps.record(done: ["mv.sit-to-stand": 1], steady: ["mv.sit-to-stand"], troubled: [], shown: [])
        let before = try #require(reps.progress["mv.sit-to-stand"]?.step)

        app.pickUpProgram()

        #expect(support.progress["bl.tandem"]?.level == .twoHands)
        #expect(support.progress["bl.tandem"]?.pendingChange == .down)
        #expect(reps.progress["mv.sit-to-stand"]?.step == before - 1)
    }

    /// 4.5 (P3): two reports on a move set it aside; "Bring it back" ends it.
    @Test func bringBackEndsASetAside() {
        let app = makeApp(entitlement: .subscribed)
        for days in [3.0, 1.0] {
            app.painRecorder.record(PainReportSnapshot(date: app.now().addingTimeInterval(-days * 86_400), area: .knees,
                                                       exerciseID: "mv.mini-squat"))
        }
        #expect(app.setAsideMoves.map(\.id) == ["mv.mini-squat"])
        #expect(app.personalised(WorkoutRequest.chairMovesAfterOutdoor(limits: [], rotationIndex: 0))
            .exerciseRules.setAsideIDs == ["mv.mini-squat"])
        app.bringBack("mv.mini-squat")
        #expect(app.setAsideMoves.isEmpty)
    }

    /// 4.9 (D11): the weekly check-in opens only when due, and a saved answer is kept.
    @Test func weeklyCheckInSavesTheAnswer() {
        let app = makeApp(entitlement: .subscribed)
        app.saveWeeklyCheckIn(effort: .harder, better: .stairs)
        let reviewed = WeeklyCheckIn.reviewedWeek(now: app.now(), calendar: app.calendar)
        #expect(app.weeklyNoteStore.notes.count == (reviewed == nil ? 0 : 1))
        // Never over another screen.
        app.cover = .reminderOffer
        app.offerWeeklyCheckInIfDue()
        if case .weeklyCheckIn? = app.cover { Issue.record("opened over another screen") }
    }

    /// 4.6 (P12): a level and swaps chosen on the preview are remembered.
    @Test func previewChoicesAreRemembered() {
        let app = makeApp(entitlement: .subscribed)
        var request = WorkoutRequest(day: PlannedDay(main: .walk, chairMoves: 2, cooldown: true), level: .inPlace,
                                     intensity: .steady, place: .indoors, limits: [], rotationIndex: 0)
        request.swaps = ["mv.row": "mv.knee-lift"]
        PreviewChoiceStore(defaults: app.defaults).record(request, currentLevel: .seated, now: app.now())
        #expect(app.walkLevels.state(startLevel: .seated).level == .inPlace)
        #expect(app.walkLevels.pendingCard == nil)
        #expect(app.exerciseMemory.memory.activeSwaps(now: app.now()) == ["mv.row": "mv.knee-lift"])
    }
}

extension DataEraserTests {
    /// Compliance: personalisation stays on the phone and "Delete all my data" clears it.
    @Test func eraseClearsPersonalisationStores() throws {
        ExerciseMemoryStore(defaults: defaults).update { $0.noteEasier("mv.row", at: Date()) }
        WeeklyNoteStore(defaults: defaults).add(WeeklyNote(weekStart: Date(), effort: .right, better: nil, answeredAt: Date()))
        SessionHabitStore(defaults: defaults).add(SessionHabit(recordID: UUID(), date: Date(), plannedSeconds: 600, isExtra: false))
        SessionHabitStore(defaults: defaults).answerReminder(at: Date())

        try DataEraser(context: container.mainContext, defaults: defaults, notifications: FakePendingNotifications()).eraseAll()

        for key in [ExerciseMemoryStore.defaultsKey, WeeklyNoteStore.defaultsKey, SessionHabitStore.defaultsKey,
                    SessionHabitStore.reminderAnsweredKey] {
            #expect(defaults.object(forKey: key) == nil)
        }
    }
}

extension HealthServiceTests {
    /// 4.12 (P11): busy only before her reminder, and over 1.5 × her own usual steps.
    @Test func busyDayNeedsOneAndAHalfTimesTheMedian() async {
        let store = FakeHealthStore()
        let service = HealthService(store: store, defaults: defaults)
        let now = calendar.date(from: DateComponents(year: 2026, month: 10, day: 8, hour: 9))!
        let today = calendar.startOfDay(for: now)
        for back in 1...10 { store.steps[calendar.date(byAdding: .day, value: -back, to: today)!] = 4_000 }
        store.steps[today] = 7_000
        // Not asked yet: never read.
        #expect(!(await service.isBusyDay(now: now, reminderMinutes: 600, calendar: calendar)))
        _ = await service.requestAuthorization()
        #expect(await service.isBusyDay(now: now, reminderMinutes: 600, calendar: calendar))
        #expect(!(await service.isBusyDay(now: now, reminderMinutes: 8 * 60, calendar: calendar)))
        store.steps[today] = 5_000
        #expect(!(await service.isBusyDay(now: now, reminderMinutes: 600, calendar: calendar)))
    }
}

@MainActor @Suite struct ResultsSummaryTests {
    /// 4.10 (P8): the first check compared is the first done the same way as the latest.
    @Test func comparesChecksDoneTheSameWay() {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let checks = [(30, 6, false), (16, 7, true), (2, 9, true)].map {
            SelfCheckPoint(id: UUID(), date: now.addingTimeInterval(-Double($0.0) * 86_400), count: $0.1, usedHands: $0.2, week: 0)
        }
        let summary = ResultsSummary(sessions: [], checks: checks, longestWalk: nil, now: now, calendar: calendar)
        #expect(summary.latestCheck == 9 && summary.firstCheck == 7)
        #expect(!summary.hasMinutes)
        #expect(ResultTile.order(for: .chairs).first == .sitToStands)
        #expect(ResultTile.order(for: .steadier).first == .hands)
    }
}

extension AppFlowTests {
    /// Progress "Hands on the chair" shows the step she has earned (fingertips in tandem stance lights up
    /// for Pro), while today's session keeps its own cap.
    @Test func progressShowsTheEarnedHandsLevel() {
        let app = makeApp(entitlement: .subscribed)
        let support = SupportLadderStore(defaults: app.defaults)
        for _ in 0..<4 { support.record(steady: ["bl.tandem"], troubled: [], announced: []) }
        #expect(support.progress["bl.tandem"]?.level == .fingertips)
        app.reload()
        #expect(app.progress.supportLevels["bl.tandem"] == .fingertips)
        #expect(SupportLadderSummary(levels: app.progress.supportLevels).highest == .fingertips)
        // Viewing it changes nothing: the stored step stays, and a steady day still holds one hand.
        #expect(support.progress["bl.tandem"]?.level == .fingertips)
        #expect(SupportLadder.plan(progress: support.progress, intensity: .steady, limits: []).levels["bl.tandem"] == .oneHand)
        // Free: the card stays on two hands (no ladder).
        let free = makeApp(entitlement: .free)
        #expect(free.progress.supportLevels.isEmpty)
    }
}
