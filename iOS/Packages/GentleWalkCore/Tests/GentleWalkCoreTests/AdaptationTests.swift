import Foundation
import Testing
@testable import GentleWalkCore

@Suite struct AdaptationTests {
    @Test(arguments: [(CheckIn.achy, Intensity.gentle), (.okay, .steady), (.great, .strong)])
    func checkInSetsIntensity(_ checkIn: CheckIn, _ intensity: Intensity) {
        #expect(Intensity(checkIn: checkIn) == intensity)
    }

    func feedback(_ feelings: [Feeling?], level: WalkLevel = .inPlace, breaks: Int = 0) -> [SessionFeedback] {
        feelings.map { SessionFeedback(level: level, feeling: $0, breakCount: breaks) }
    }

    @Test func threeTooHardInARowStepsDown() {
        let result = Adaptation.next(level: .inPlace, history: feedback([.justRight, .tooHard, .tooHard, .tooHard]))
        #expect(result.level == .seated)
        #expect(result.card == .movedDown(to: .seated))
    }

    @Test func twoTooHardOrABrokenStreakDoesNothing() {
        #expect(Adaptation.next(level: .inPlace, history: feedback([.tooHard, .tooHard])).level == .inPlace)
        #expect(Adaptation.next(level: .inPlace, history: feedback([.tooHard, .tooHard, .justRight])).card == nil)
        // Sessions with no answer do not break or extend the streak.
        #expect(Adaptation.next(level: .inPlace, history: feedback([.tooHard, nil, .tooHard, .tooHard])).level == .seated)
    }

    @Test func threeTooEasyInARowStepsUp() {
        let result = Adaptation.next(level: .seated, history: feedback([.tooEasy, .tooEasy, .tooEasy], level: .seated))
        #expect(result.level == .inPlace)
        #expect(result.card == .movedUp(to: .inPlace))
    }

    @Test func streakOnlyCountsSessionsAtTheCurrentLevel() {
        // Two at the old level + one at the new level: no second step.
        let history = feedback([.tooHard, .tooHard], level: .inPlace) + feedback([.tooHard], level: .seated)
        #expect(Adaptation.next(level: .seated, history: history).level == .seated)
    }

    // MARK: Current level (task 0.1)

    let d0 = Date(timeIntervalSince1970: 1_790_000_000)
    func dated(_ feelings: [Feeling], level: WalkLevel, startingDaysFrom offset: Int) -> [SessionFeedback] {
        feelings.enumerated().map { index, feeling in
            SessionFeedback(level: level, feeling: feeling, breakCount: 0,
                            date: d0.addingTimeInterval(Double(offset + index) * 86_400))
        }
    }

    @Test func tooHardAtTheNewLevelStepsBackDown() {
        let history = dated([.tooEasy, .tooEasy, .tooEasy], level: .seated, startingDaysFrom: -3)
            + dated([.tooHard, .tooHard, .tooHard], level: .inPlace, startingDaysFrom: 1)
        let result = Adaptation.next(state: LevelState(level: .inPlace, changedAt: d0), history: history)
        #expect(result.level == .seated)
        #expect(result.card == .movedDown(to: .seated))
    }

    @Test func answersBeforeTheChangeDoNotCount() {
        // Moved back down to Seated at d0; the old "Too easy" streak at Seated must not lift her again.
        let history = dated([.tooEasy, .tooEasy, .tooEasy], level: .seated, startingDaysFrom: -10)
            + dated([.tooHard, .tooHard, .tooHard], level: .inPlace, startingDaysFrom: -3)
        let result = Adaptation.next(state: LevelState(level: .seated, changedAt: d0), history: history)
        #expect(result.level == .seated)
        #expect(result.card == nil)
    }

    @Test func firstChangeHasNoDate() {
        let history = dated([.tooEasy, .tooEasy, .tooEasy], level: .seated, startingDaysFrom: -3)
        let result = Adaptation.next(state: LevelState(level: .seated, changedAt: nil), history: history)
        #expect(result.level == .inPlace)
        #expect(result.card == .movedUp(to: .inPlace))
    }

    @Test func seatedIsTheFloorAndThePadIsNeverChosenAutomatically() {
        #expect(Adaptation.next(level: .seated, history: feedback([.tooHard, .tooHard, .tooHard], level: .seated)).card == nil)
        #expect(Adaptation.next(level: .inPlace, history: feedback([.tooEasy, .tooEasy, .tooEasy])).level == .inPlace)
        #expect(Adaptation.next(level: .pad, history: feedback([.tooHard, .tooHard, .tooHard], level: .pad)).level == .inPlace)
    }

    @Test func twoBreaksMakeTheNextSessionTwoMinutesShorter() {
        let result = Adaptation.next(level: .inPlace, history: feedback([.justRight], breaks: 2))
        #expect(result.minutesDelta == -2)
        #expect(result.card == .shorter)
        #expect(Adaptation.next(level: .inPlace, history: feedback([.justRight], breaks: 1)).minutesDelta == 0)
    }

    @Test func shorteningKeepsAtLeastFiveMinutesAndEveryPhase() throws {
        let content = TestSupport.appContent
        let walk = PlannedDay(main: .walk, chairMoves: 0, cooldown: false)
        let steady = try SessionBuilder.build(kind: walk, level: .seated, intensity: .steady, limits: [], rotationIndex: 0, content: content)
        let shorter = steady.shortened(byMinutes: 2)
        // Only the warm-up can lose time (the cool-down walk is already at its one-minute floor).
        #expect(shorter.totalSeconds == steady.totalSeconds - 60)
        // Its opening, set-up and safety lines stay.
        #expect(Set(steady.blocks[0].segments[0].cues.filter { $0.at < 45 }.map(\.line))
                .isSubset(of: Set(shorter.blocks[0].segments[0].cues.map(\.line))))
        #expect(shorter.segments.map(\.kind) == steady.segments.map(\.kind))
        #expect(shorter.segments.allSatisfy { seg in seg.cues.allSatisfy { $0.at < seg.seconds } })

        let gentle = try SessionBuilder.build(kind: walk, level: .seated, intensity: .gentle, limits: [], rotationIndex: 0, content: content)
        #expect(gentle.shortened(byMinutes: 2).totalSeconds == gentle.totalSeconds)
    }
}
