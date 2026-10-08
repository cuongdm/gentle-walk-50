import Foundation
import Testing
@testable import GentleWalkCore

@Suite struct PainRulesTests {
    let now = TestSupport.date("2026-09-29T15:00:00Z")

    func report(_ area: BodyArea, daysAgo: Double) -> PainReportSnapshot {
        PainReportSnapshot(date: now.addingTimeInterval(-daysAgo * 86_400), area: area, exerciseID: nil)
    }

    @Test func sameAreaThreeTimesInSevenDaysSuggestsTheDoctorAndSeatedMoves() {
        let alert = PainRules.evaluate(reports: [report(.knees, daysAgo: 6), report(.knees, daysAgo: 3), report(.knees, daysAgo: 0)], now: now)
        #expect(alert == PainAlert(area: .knees, count: 3, switchToSeated: true))
    }

    @Test func twiceIsNotEnough() {
        #expect(PainRules.evaluate(reports: [report(.knees, daysAgo: 3), report(.knees, daysAgo: 0)], now: now) == nil)
    }

    @Test func differentAreasDoNotAddUp() {
        let reports = [report(.knees, daysAgo: 1), report(.hips, daysAgo: 1), report(.lowerBack, daysAgo: 0)]
        #expect(PainRules.evaluate(reports: reports, now: now) == nil)
    }

    @Test func reportsOlderThanSevenDaysDoNotCount() {
        let reports = [report(.knees, daysAgo: 8), report(.knees, daysAgo: 3), report(.knees, daysAgo: 0)]
        #expect(PainRules.evaluate(reports: reports, now: now) == nil)
    }

    @Test func easierVersionWhenThereIsOneOtherwiseSkip() {
        let move = TestSupport.exercise("mv.sit-to-stand")
        #expect(PainRules.response(for: .showEasier, exercise: move) == .easierVersion(move.easier))
        var noEasier = move
        noEasier.easier = ""
        #expect(PainRules.response(for: .showEasier, exercise: noEasier) == .skipExercise)
        #expect(PainRules.response(for: .skip, exercise: move) == .skipExercise)
    }

    // MARK: P3 pain per move (plan 4.5, D9)

    func move(_ id: String, daysAgo: Double, area: BodyArea = .knees) -> PainReportSnapshot {
        PainReportSnapshot(date: now.addingTimeInterval(-daysAgo * 86_400), area: area, exerciseID: id)
    }

    /// One report in 14 days: the easier version by default. Older ones, or reports without a move, do nothing.
    @Test func oneReportMakesItEasier() {
        let rules = PainRules.exerciseRules(reports: [move("mv.mini-squat", daysAgo: 3), report(.hips, daysAgo: 1),
                                                       move("mv.row", daysAgo: 15)], now: now)
        #expect(rules.easier == ["mv.mini-squat"])
        #expect(rules.setAside.isEmpty)
    }

    /// Two reports on the same move in 28 days: set aside for four weeks after the latest one.
    @Test func twoReportsSetItAside() {
        let rules = PainRules.exerciseRules(reports: [move("mv.mini-squat", daysAgo: 20), move("mv.mini-squat", daysAgo: 2)],
                                            now: now)
        #expect(rules.setAsideIDs == ["mv.mini-squat"])
        #expect(rules.setAside["mv.mini-squat"] == now.addingTimeInterval(26 * 86_400))
        #expect(rules.easier.isEmpty)
        // Four weeks later it is back, no longer easier either (the last report is 28 days old).
        let later = PainRules.exerciseRules(reports: [move("mv.mini-squat", daysAgo: 20), move("mv.mini-squat", daysAgo: 2)],
                                            now: now.addingTimeInterval(26 * 86_400))
        #expect(later == ExerciseRules())
        // Two reports on two different moves do not add up.
        let two = PainRules.exerciseRules(reports: [move("mv.row", daysAgo: 2), move("mv.leg-ext", daysAgo: 1)], now: now)
        #expect(two.setAside.isEmpty && two.easier == ["mv.row", "mv.leg-ext"])
    }

    /// "Bring it back" in Me: reports up to that moment no longer count.
    @Test func restoredStaysAllowed() {
        let reports = [move("mv.mini-squat", daysAgo: 20), move("mv.mini-squat", daysAgo: 2)]
        let restored = PainRules.exerciseRules(reports: reports, now: now,
                                               restored: ["mv.mini-squat": now.addingTimeInterval(-86_400)])
        #expect(restored == ExerciseRules())
        // A new report after bringing it back starts again from easier.
        let again = PainRules.exerciseRules(reports: reports + [move("mv.mini-squat", daysAgo: 0)], now: now,
                                            restored: ["mv.mini-squat": now.addingTimeInterval(-86_400)])
        #expect(again.easier == ["mv.mini-squat"] && again.setAside.isEmpty)
    }

    /// The area she named suggests the matching body limit ("Add 'Easy on knees' to your plan?").
    @Test func areaSuggestsALimit() {
        #expect(PainRules.suggestedLimit(for: .knees) == .knees)
        #expect(PainRules.suggestedLimit(for: .hips) == .hips)
        #expect(PainRules.suggestedLimit(for: .lowerBack) == .lowerBack)
        #expect(PainRules.suggestedLimit(for: .shoulders) == .shoulders)
        #expect(PainRules.suggestedLimit(for: .neck) == nil)
        #expect(PainRules.suggestedLimit(for: .other) == nil)
    }
}
