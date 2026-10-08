import Testing
@testable import GentleWalkCore

/// The support ladder (Pro, review 06/10/2026): two hands → one hand → fingertips, never no hands.
@Suite struct SupportLadderTests {
    @Test func twoSteadySessionsRaiseOneStep() {
        var progress: [String: SupportProgress] = [:]
        progress = SupportLadder.update(progress, steady: ["bl.tandem"], troubled: [])
        #expect(progress["bl.tandem"]?.level == .twoHands)
        progress = SupportLadder.update(progress, steady: ["bl.tandem"], troubled: [])
        #expect(progress["bl.tandem"] == SupportProgress(level: .oneHand, steadySessions: 0, pendingChange: .up))
    }

    @Test func troubleLowersOneStepAndResetsTheCount() {
        let start = ["bl.tandem": SupportProgress(level: .fingertips, steadySessions: 1)]
        let after = SupportLadder.update(start, steady: [], troubled: ["bl.tandem"])
        #expect(after["bl.tandem"] == SupportProgress(level: .oneHand, steadySessions: 0, pendingChange: .down))
        // Already at both hands: stays there.
        let floor = SupportLadder.update(["mv.single-leg": SupportProgress()], steady: [], troubled: ["mv.single-leg"])
        #expect(floor["mv.single-leg"]?.level == .twoHands)
    }

    @Test func neverAboveTheExercisesTopStep() {
        var progress = ["mv.single-leg": SupportProgress(level: .oneHand, steadySessions: 5)]
        progress = SupportLadder.update(progress, steady: ["mv.single-leg"], troubled: [])
        #expect(progress["mv.single-leg"]?.level == .oneHand)
        #expect(SupportLevel.allCases.allSatisfy { $0 != .fingertips || SupportLadder.highest("bl.tandem") == $0 })
    }

    @Test func todayIsCappedByIntensityAndLimits() {
        let progress = ["bl.tandem": SupportProgress(level: .fingertips)]
        #expect(SupportLadder.today("bl.tandem", progress: progress, intensity: .gentle, limits: []) == .twoHands)
        #expect(SupportLadder.today("bl.tandem", progress: progress, intensity: .steady, limits: []) == .oneHand)
        #expect(SupportLadder.today("bl.tandem", progress: progress, intensity: .strong, limits: []) == .fingertips)
        for limit in [BodyLimit.dizzy, .unsteady] {
            #expect(SupportLadder.today("bl.tandem", progress: progress, intensity: .strong, limits: [limit]) == .twoHands)
        }
    }

    @Test func theBuilderSaysHerLevelAndAnnouncesARaise() throws {
        let day = PlannedDay(main: .chair, chairMoves: 0, cooldown: true, steadySet: .matchingIntensity)
        let progress = ["bl.tandem": SupportProgress(level: .oneHand, pendingChange: .up)]
        let support = SupportLadder.plan(progress: progress, intensity: .strong, limits: [])
        let plan = try SessionBuilder.build(kind: day, level: .inPlace, intensity: .strong, limits: [], rotationIndex: 0,
                                            content: TestSupport.appContent, support: support)
        let tandem = try #require(plan.blocks.last?.segments.first { $0.exerciseID == "bl.tandem" })
        #expect(tandem.cues.contains { $0.line == "a11.ladder.one" })
        #expect(!tandem.cues.contains { $0.line == "a11.hands.tips" })
        // On an achy day the raise waits: both hands, nothing announced.
        let gentle = SupportLadder.plan(progress: progress, intensity: .gentle, limits: [])
        #expect(gentle.levels["bl.tandem"] == .twoHands && gentle.announce["bl.tandem"] == nil)
    }

    /// P13: back after a long break, every hands level goes one step down (never below two hands) and
    /// the coach says so at the next session (`a11.ladder.down`).
    @Test func longBreakStepsEveryLevelDown() {
        let start = ["bl.tandem": SupportProgress(level: .fingertips, steadySessions: 1, pendingChange: .up),
                     "mv.single-leg": SupportProgress(level: .oneHand),
                     "wk.shift": SupportProgress(level: .twoHands, steadySessions: 1)]
        let after = SupportLadder.stepDownAll(start)
        #expect(after["bl.tandem"] == SupportProgress(level: .oneHand, steadySessions: 0, pendingChange: .down))
        #expect(after["mv.single-leg"] == SupportProgress(level: .twoHands, steadySessions: 0, pendingChange: .down))
        // Already at both hands: nothing to lower, nothing to announce, the count starts again.
        #expect(after["wk.shift"] == SupportProgress(level: .twoHands, steadySessions: 0, pendingChange: nil))
        #expect(SupportLadder.plan(progress: after, intensity: .strong, limits: []).announce["bl.tandem"] == .down)
    }
}
