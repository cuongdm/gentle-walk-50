import Foundation
import Testing
@testable import GentleWalkCore

/// Milestone 4 personalisation (docs/plans/2026-10-08-ui-onboarding-personalization.md, P1–P13): the
/// pieces the cloud core left for the app integration.
@Suite struct SessionOpeningTests {
    let content = TestSupport.appContent
    let walkOnly = PlannedDay(main: .walk, chairMoves: 0, cooldown: false)
    let chairDay = PlannedDay(main: .chair, chairMoves: 0, cooldown: true)

    func build(_ day: PlannedDay, _ intensity: Intensity = .steady, opening: OpeningContext?, rotation: Int = 0) throws -> SessionPlan {
        try SessionBuilder.build(kind: day, level: .seated, intensity: intensity, limits: [], rotationIndex: rotation,
                                 content: content, opening: opening)
    }

    /// 4.1: one line before the first block, restart > level change > shorter > the check-in.
    @Test func openingLineFollowsTheDay() throws {
        func first(_ opening: OpeningContext, rotation: Int = 0) throws -> String? {
            let plan = try build(walkOnly, opening.intensity, opening: opening, rotation: rotation)
            #expect(plan.segments.first?.kind == .intro)
            #expect((4...6).contains(plan.segments.first?.seconds ?? 0))
            #expect(plan.segments.first?.cues.count == 1)
            return plan.segments.first?.cues.first?.line
        }
        #expect(try first(OpeningContext(intensity: .gentle)) == "a9.gentle")
        #expect(try first(OpeningContext(intensity: .steady)) == "a9.steady")
        #expect(try first(OpeningContext(intensity: .strong)) == "a9.strong")
        #expect(try first(OpeningContext(intensity: .gentle, shortened: true)) == "a9.shorter")
        #expect(try first(OpeningContext(intensity: .gentle, shortened: true, levelChange: .movedUp(to: .inPlace))) == "a9.levelup")
        #expect(try first(OpeningContext(intensity: .gentle, levelChange: .movedDown(to: .seated))) == "a9.leveldown")
        #expect(try first(OpeningContext(intensity: .gentle, restart: true, shortened: true, levelChange: .movedDown(to: .seated)))
            == "a9.back.1")
        // The two welcome-back lines take turns.
        #expect(try first(OpeningContext(intensity: .gentle, restart: true), rotation: 1) == "a9.back.2")
        // Chair days open the same way, before "Chair moves today".
        let chair = try build(chairDay, opening: OpeningContext(intensity: .steady))
        #expect(Array(chair.lineIDs.prefix(2)) == ["a9.steady", "a9.chair.open"])
    }

    /// No opening asked (First Walk, extras, outdoors): the plan is exactly the template's.
    @Test func firstWalkHasNoOpening() throws {
        let plain = try build(walkOnly, opening: nil)
        #expect(plain.segments.first?.kind == .warmup)
        #expect(!plain.lineIDs.contains { $0.hasPrefix("a9.") || $0.hasPrefix("a13.") })
    }

    /// 4.15: at most one history line; the week line opens (in place of the check-in line), the others close.
    @Test func oneHistoryLinePerSession() throws {
        let week = try build(walkOnly, opening: OpeningContext(intensity: .steady, history: .week(5)))
        #expect(week.lineIDs.first == "a13.week.5")
        #expect(week.lineIDs.filter { $0.hasPrefix("a13.") }.count == 1)
        #expect(!week.lineIDs.contains("a9.steady"))

        let plain = try build(walkOnly, opening: OpeningContext(intensity: .steady))
        let walk = try build(walkOnly, opening: OpeningContext(intensity: .steady, history: .walk(3)))
        #expect(walk.lineIDs.first == "a9.steady")
        #expect(walk.lineIDs.last == "a13.walk.3")
        #expect(walk.lineIDs.filter { $0.hasPrefix("a13.") }.count == 1)
        #expect(walk.totalSeconds > plain.totalSeconds)
        // The closing line comes after the session's own last line, and fits in the session.
        let timeline = SessionTimeline.make(plan: walk, voice: content.voiceLines)
        let closing = try #require(timeline.voice.last)
        #expect(closing.lineID == "a13.walk.3")
        #expect(closing.end <= timeline.total + 0.01)
        #expect(timeline.bells.last?.kind == .done)

        // A level change keeps its own line; the week waits.
        let moved = try build(walkOnly, opening: OpeningContext(intensity: .steady, levelChange: .movedUp(to: .inPlace),
                                                               history: .week(2)))
        #expect(moved.lineIDs.first == "a9.levelup")
        #expect(!moved.lineIDs.contains { $0.hasPrefix("a13.") })
    }

    @Test func historyPickPrefersTheWeekThenTheWalkThenTheDays() {
        #expect(HistoryLine.pick(programWeek: 3, firstOfProgramWeek: true, isWalk: true, walkNumber: 2, activeDays: 2) == .week(3))
        #expect(HistoryLine.pick(programWeek: 3, firstOfProgramWeek: false, isWalk: true, walkNumber: 2, activeDays: 2) == .walk(2))
        #expect(HistoryLine.pick(programWeek: nil, firstOfProgramWeek: false, isWalk: true, walkNumber: 6, activeDays: 4)
            == .activeDays(4))
        #expect(HistoryLine.pick(programWeek: 13, firstOfProgramWeek: true, isWalk: false, walkNumber: 0, activeDays: 1) == nil)
    }

    /// Every line the opening can say is recorded (EN and VI).
    @Test func openingLinesHaveRecordings() {
        let english = Dictionary(content.voiceLines.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let ids = ["a9.gentle", "a9.steady", "a9.strong", "a9.shorter", "a9.levelup", "a9.leveldown", "a9.back.1", "a9.back.2"]
            + CoachHistory.allLineIDs
        #expect(ids.allSatisfy { english[$0]?.file != nil })
    }

    /// 4.6 (P12): a swapped move gives way to her choice while the memory holds, then comes back.
    @Test func swappedMoveComesBackLater() throws {
        let usual = try SessionBuilder.build(kind: chairDay, level: .seated, intensity: .steady, limits: [], rotationIndex: 0,
                                             content: content)
        #expect(usual.exerciseIDs.contains("mv.row"))
        #expect(!usual.exerciseIDs.contains("mv.knee-lift"))
        let swapped = try SessionBuilder.build(kind: chairDay, level: .seated, intensity: .steady, limits: [], rotationIndex: 0,
                                               content: content, swapMemory: ["mv.row": "mv.knee-lift"])
        #expect(!swapped.exerciseIDs.contains("mv.row"))
        #expect(swapped.exerciseIDs.contains("mv.knee-lift"))
        // The memory runs out after two weeks: the move is back.
        var memory = ExerciseMemory()
        let then = TestSupport.date("2026-10-01T10:00:00Z")
        memory.noteSwaps(["mv.row": "mv.knee-lift"], at: then)
        #expect(memory.activeSwaps(now: then.addingTimeInterval(13 * 86_400)) == ["mv.row": "mv.knee-lift"])
        #expect(memory.activeSwaps(now: then.addingTimeInterval(14 * 86_400)).isEmpty)
    }

    /// 4.9: a week she found easier makes the walk about two minutes longer; the "ten seconds" lines keep
    /// their place before the change.
    @Test func easierWeekLengthensTheWalk() throws {
        let plan = try SessionBuilder.build(kind: walkOnly, level: .inPlace, intensity: .steady, limits: [], rotationIndex: 0,
                                            content: content)
        let longer = plan.lengthened(byMinutes: 2)
        #expect(longer.totalSeconds - plan.totalSeconds >= 120)
        #expect(longer.totalSeconds - plan.totalSeconds < 180)
        #expect(longer.lineIDs == plan.lineIDs)
        for (before, after) in zip(plan.segments, longer.segments) where before.kind == .easy {
            let tailBefore = before.cues.filter { $0.at >= before.seconds - SessionPlan.easyTail }.map { before.seconds - $0.at }
            let tailAfter = after.cues.filter { $0.at >= after.seconds - SessionPlan.easyTail }.map { after.seconds - $0.at }
            #expect(tailBefore == tailAfter)
        }
        #expect(plan.lengthened(byMinutes: 0) == plan)
    }
}

@Suite struct PersonalisationAdaptationTests {
    func feedback(_ feelings: [Feeling?], level: WalkLevel) -> [SessionFeedback] {
        feelings.map { SessionFeedback(level: level, feeling: $0, breakCount: 0) }
    }

    /// 4.2 (P2, D16): two "Too hard" in a row: Achy chosen in advance and two minutes shorter.
    @Test func twoTooHardSuggestsAchyAndShorter() {
        let result = Adaptation.next(level: .inPlace, history: feedback([.justRight, .tooHard, .tooHard], level: .inPlace))
        #expect(result.level == .inPlace)
        #expect(result.suggestedCheckIn == .achy)
        #expect(result.minutesDelta == -Adaptation.shorterByMinutes)
        // The third moves the level instead (no gentler day on top).
        let third = Adaptation.next(level: .inPlace, history: feedback([.tooHard, .tooHard, .tooHard], level: .inPlace))
        #expect(third.level == .seated && third.suggestedCheckIn == nil && third.minutesDelta == 0)
        // Seated cannot go lower: it stays gentler.
        let seated = Adaptation.next(level: .seated, history: feedback([.tooHard, .tooHard, .tooHard], level: .seated))
        #expect(seated.suggestedCheckIn == .achy)
    }

    /// Two "Too easy" where the level does not go up by itself (In place, the pad): Great in advance.
    @Test func twoTooEasyAtTheTopSuggestsGreat() {
        #expect(Adaptation.next(level: .inPlace, history: feedback([.tooEasy, .tooEasy], level: .inPlace)).suggestedCheckIn == .great)
        #expect(Adaptation.next(level: .seated, history: feedback([.tooEasy, .tooEasy], level: .seated)).suggestedCheckIn == nil)
        #expect(Adaptation.next(level: .inPlace, history: feedback([.tooEasy, .justRight], level: .inPlace)).suggestedCheckIn == nil)
    }
}

@Suite struct ExerciseMemoryTests {
    let now = TestSupport.date("2026-10-08T10:00:00Z")
    func days(_ n: Double) -> Date { now.addingTimeInterval(-n * 86_400) }

    /// 4.4 (P5): Easier twice in two weeks → the move starts easier; "Try the usual one" forgets it.
    @Test func twoEasierTapsMakeItTheDefault() {
        var memory = ExerciseMemory()
        memory.noteEasier("mv.leg-ext", at: days(3))
        #expect(memory.defaultsEasier(now: now).isEmpty)
        memory.noteEasier("mv.leg-ext", at: days(1))
        #expect(memory.defaultsEasier(now: now) == ["mv.leg-ext"])
        #expect(memory.exerciseRules(now: now).easier == ["mv.leg-ext"])
        // Old taps fall out of the window.
        #expect(memory.defaultsEasier(now: days(-12)).isEmpty)
        memory.useUsualVersion("mv.leg-ext")
        #expect(memory.defaultsEasier(now: now).isEmpty)
    }

    /// D10: Harder done in full allows one more rep step for a week; it never raises the step by itself.
    @Test func harderDoneRaisesTheCeilingOnly() {
        var memory = ExerciseMemory()
        memory.noteHarderDone("mv.sit-to-stand", at: days(2))
        #expect(memory.harderBonus(now: now) == ["mv.sit-to-stand"])
        #expect(memory.harderBonus(now: days(-6)).isEmpty)
        let earned = ["mv.sit-to-stand": RepProgress(step: 3)]
        // Steady: base 1, cap 2 → with the bonus, cap 3.
        #expect(RepLadder.today("mv.sit-to-stand", progress: earned, intensity: .steady, limits: []) == RepStep(sets: 1, reps: 10))
        #expect(RepLadder.today("mv.sit-to-stand", progress: earned, intensity: .steady, limits: [], bonusCap: 1)
            == RepStep(sets: 2, reps: 8))
        // Not earned yet: the bonus alone changes nothing.
        #expect(RepLadder.today("mv.sit-to-stand", progress: [:], intensity: .steady, limits: [], bonusCap: 1)
            == RepStep(sets: 1, reps: 8))
        // Dizzy or unsteady still hold it down.
        #expect(RepLadder.today("mv.sit-to-stand", progress: earned, intensity: .steady, limits: [.dizzy], bonusCap: 1)
            == RepStep(sets: 1, reps: 8))
    }

    @Test func memoryRoundTripsAsJSON() throws {
        var memory = ExerciseMemory()
        memory.noteEasier("mv.row", at: now)
        memory.restore("mv.mini-squat", at: now)
        memory.noteSwaps(["mv.row": "mv.knee-lift"], at: now)
        let data = try JSONEncoder().encode(memory)
        #expect(try JSONDecoder().decode(ExerciseMemory.self, from: data) == memory)
    }
}

@Suite struct SelfCheckHistoryTests {
    /// 4.15: from the second check the coach recalls the last count first; the rest keeps its timing
    /// after the lead-in.
    @Test func secondCheckRecallsTheLast() {
        let lines = TestSupport.appContent.voiceLines
        let plain = SessionTimeline.selfCheck(voice: lines)
        let recalled = SessionTimeline.selfCheck(voice: lines, previousCount: 8)
        #expect(recalled.voice.first?.lineID == "a13.check.n.8")
        #expect(recalled.leadIn > 0)
        #expect(recalled.voice.first.map { $0.end <= recalled.leadIn } ?? false)
        #expect(Array(recalled.voice.dropFirst().map(\.lineID)) == plain.voice.map(\.lineID))
        for (a, b) in zip(plain.voice, recalled.voice.dropFirst()) { #expect(abs(b.start - a.start - recalled.leadIn) < 0.001) }
        #expect(recalled.bells.map(\.at) == plain.bells.map { $0.at + recalled.leadIn })
        // First check, or a count with no recording: as before.
        #expect(SessionTimeline.selfCheck(voice: lines, previousCount: nil) == plain)
        #expect(SessionTimeline.selfCheck(voice: lines, previousCount: 25) == plain)
    }
}

@Suite struct YourResultsTests {
    let calendar = TestSupport.newYork
    func day(_ d: Int, _ month: Int = 10) -> Date { TestSupport.local(calendar, 2026, month, d, 9) }

    /// 4.10: minutes per week for the last four weeks; "usual" is the median of the four weeks before.
    @Test func usualMinutesIsTheMedianOfFourWeeks() {
        // Weeks (Sunday start) of Sep 6, 13, 20, 27 and Oct 4; now is Thursday Oct 8.
        let sessions = [(day(7, 9), 10), (day(14, 9), 20), (day(16, 9), 10), (day(21, 9), 40), (day(28, 9), 25), (day(5), 15),
                        (day(6), 15)]
            .map { MovedSession(date: $0.0, seconds: $0.1 * 60, unbrokenWalk: true) }
        let weeks = YourResults.weeklyMinutes(sessions, now: day(8), calendar: calendar)
        #expect(weeks.map(\.minutes) == [30, 40, 25, 30])
        #expect(weeks.map(\.activeDays) == [2, 1, 1, 2])
        // Before this week: 10, 30, 40, 25 → median 27 (whole minutes).
        #expect(YourResults.usualMinutes(sessions, now: day(8), calendar: calendar) == 27)
        #expect(YourResults.usualMinutes([], now: day(8), calendar: calendar) == nil)
    }

    @Test func steadyWeeksCountBackFromLastFullWeek() {
        let days = [7, 8, 9, 14, 15, 16, 21, 22, 23].map { day($0, 9) } + [day(5)]
        let sessions = days.map { MovedSession(date: $0, seconds: 600, unbrokenWalk: false) }
        // This week (Oct 4) has 1 day so far: it does not break the run; Sep 27 has none: the run is 0.
        #expect(YourResults.steadyWeeksInARow(sessions, now: day(8), calendar: calendar) == 0)
        let more = sessions + [day(28, 9), day(29, 9), day(30, 9)].map { MovedSession(date: $0, seconds: 600, unbrokenWalk: false) }
        #expect(YourResults.steadyWeeksInARow(more, now: day(8), calendar: calendar) == 4)
        #expect(YourResults.firstWeekLongestWalk(sessions + [MovedSession(date: day(8, 9), seconds: 300, unbrokenWalk: true)]) == 5)
    }
}
