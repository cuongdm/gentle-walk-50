import Foundation
import Testing
@testable import GentleWalkCore

@Suite struct RepLadderTests {
    let sts = "mv.sit-to-stand"
    let squat = "mv.mini-squat"

    /// One session where `id` was done at `step` and held through.
    func held(_ progress: [String: RepProgress], _ id: String, at step: Int) -> [String: RepProgress] {
        RepLadder.update(progress, done: [id: step], steady: [id], troubled: [])
    }

    @Test func stepsPerMove() {
        #expect(RepLadder.steps(for: sts) == [RepStep(sets: 1, reps: 6), RepStep(sets: 1, reps: 8), RepStep(sets: 1, reps: 10),
                                              RepStep(sets: 2, reps: 8), RepStep(sets: 2, reps: 10)])
        #expect(RepLadder.steps(for: squat) == [RepStep(sets: 1, reps: 8), RepStep(sets: 1, reps: 10),
                                                RepStep(sets: 1, reps: 12), RepStep(sets: 2, reps: 10)])
        #expect(RepLadder.exercises == [sts, squat, "mv.side-leg"])
        #expect(RepLadder.steps(for: "mv.heel-toe").isEmpty)
    }

    /// Up one step after two sessions in a row done in full, without This hurts or a Break (Otago).
    @Test func raisesAfterTwoFullSessions() {
        var progress: [String: RepProgress] = [:]
        progress = held(progress, sts, at: 1)
        #expect(progress[sts] == RepProgress(step: 1, fullSessions: 1, pendingChange: nil))
        progress = held(progress, sts, at: 1)
        #expect(progress[sts] == RepProgress(step: 2, fullSessions: 0, pendingChange: .up))
        for _ in 0..<6 { progress = held(progress, sts, at: progress[sts]!.step) }
        #expect(progress[sts]?.step == 4)  // 2 × 10 is the top
        progress = held(progress, sts, at: 4)
        progress = held(progress, sts, at: 4)
        #expect(progress[sts]?.step == 4)
    }

    @Test func dropsOneStepOnTrouble() {
        var progress = [sts: RepProgress(step: 3, fullSessions: 1, pendingChange: nil)]
        progress = RepLadder.update(progress, done: [sts: 3], steady: [], troubled: [sts])
        #expect(progress[sts] == RepProgress(step: 2, fullSessions: 0, pendingChange: .down))
        progress = RepLadder.update([sts: RepProgress(step: 0, fullSessions: 0, pendingChange: nil)], done: [sts: 0],
                                    steady: [], troubled: [sts])
        #expect(progress[sts]?.step == 0)
    }

    /// Today's step: never below the day's own (free) amount, at most one step above it (plan 2.6).
    @Test func achyDayCapsReps() {
        let top = [sts: RepProgress(step: 4), squat: RepProgress(step: 3)]
        #expect(RepLadder.today(sts, progress: top, intensity: .gentle, limits: []) == RepStep(sets: 1, reps: 8))
        #expect(RepLadder.today(sts, progress: top, intensity: .steady, limits: []) == RepStep(sets: 1, reps: 10))
        #expect(RepLadder.today(sts, progress: top, intensity: .strong, limits: []) == RepStep(sets: 2, reps: 10))
        #expect(RepLadder.today(squat, progress: top, intensity: .gentle, limits: []) == RepStep(sets: 1, reps: 10))
        #expect(RepLadder.today(squat, progress: top, intensity: .strong, limits: []) == RepStep(sets: 2, reps: 10))
        // Nothing earned yet: the day's own amount, the same as the free plan.
        #expect(RepLadder.today(sts, progress: [:], intensity: .steady, limits: []) == RepStep(sets: 1, reps: 8))
        #expect(RepLadder.today(squat, progress: [:], intensity: .strong, limits: []) == RepStep(sets: 1, reps: 12))
    }

    /// Feeling dizzy or unsteady: no more than an achy day allows, whatever was earned.
    @Test func unsteadyKeepsTheDefault() {
        let top = [sts: RepProgress(step: 4)]
        #expect(RepLadder.today(sts, progress: top, intensity: .strong, limits: [.unsteady]) == RepStep(sets: 1, reps: 8))
        #expect(RepLadder.today(sts, progress: top, intensity: .steady, limits: [.dizzy]) == RepStep(sets: 1, reps: 8))
    }

    /// Exercises outside the ladder are never stored.
    @Test func ignoresOtherMoves() {
        let progress = RepLadder.update([:], done: ["mv.heel-toe": 0], steady: ["mv.heel-toe"], troubled: [])
        #expect(progress.isEmpty)
    }

    /// P13: back after a long break, every counted move goes one step down, never below the first step.
    @Test func stepDownNeverBelowZero() {
        let start = [sts: RepProgress(step: 3, fullSessions: 1, pendingChange: .up),
                     squat: RepProgress(step: 0, fullSessions: 1)]
        let after = RepLadder.stepDownAll(start)
        #expect(after[sts] == RepProgress(step: 2, fullSessions: 0, pendingChange: .down))
        #expect(after[squat] == RepProgress(step: 0, fullSessions: 0, pendingChange: nil))
        #expect(RepLadder.stepDownAll([:]).isEmpty)
    }

    /// P9: a check up by two allows one more step for two weeks; a check down by two keeps the day's own
    /// reps. Still earned the usual way (two full sessions); unsteady or dizzy still caps it.
    @Test func selfCheckTrendMovesTheCap() {
        let top = [sts: RepProgress(step: 4)]
        #expect(RepLadder.today(sts, progress: top, intensity: .gentle, limits: [], trend: .flat) == RepStep(sets: 1, reps: 8))
        #expect(RepLadder.today(sts, progress: top, intensity: .gentle, limits: [], trend: .up) == RepStep(sets: 1, reps: 10))
        #expect(RepLadder.today(sts, progress: top, intensity: .gentle, limits: [], trend: .down) == RepStep(sets: 1, reps: 6))
        #expect(RepLadder.today(sts, progress: [:], intensity: .steady, limits: [], trend: .up) == RepStep(sets: 1, reps: 8))
        #expect(RepLadder.today(sts, progress: top, intensity: .strong, limits: [], trend: .up) == RepStep(sets: 2, reps: 10))
        #expect(RepLadder.today(sts, progress: top, intensity: .steady, limits: [.dizzy], trend: .up) == RepStep(sets: 1, reps: 8))
    }

    /// A hard week (P6) or a check down (P9): full sessions still count, no step up; trouble still lowers.
    @Test func holdRaisesKeepsTheStep() {
        let start = [sts: RepProgress(step: 1, fullSessions: 1)]
        let held = RepLadder.update(start, done: [sts: 1], steady: [sts], troubled: [], holdRaises: true)
        #expect(held[sts]?.step == 1 && held[sts]?.pendingChange == nil)
        let down = RepLadder.update(start, done: [sts: 1], steady: [], troubled: [sts], holdRaises: true)
        #expect(down[sts]?.step == 0)
        #expect(RepLadder.update(held, done: [sts: 1], steady: [sts], troubled: [])[sts]?.step == 2)
    }
}
