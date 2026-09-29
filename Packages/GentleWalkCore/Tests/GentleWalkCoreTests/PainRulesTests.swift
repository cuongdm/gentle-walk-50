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
}
