import Foundation
import Testing
@testable import GentleWalkCore

@Suite struct SelfCheckComparisonTests {
    let ny = TestSupport.newYork

    func result(_ day: Int, _ count: Int, hands: Bool = true) -> SelfCheckResult {
        SelfCheckResult(date: TestSupport.local(ny, 2026, 10, day), count: count, usedHands: hands)
    }

    /// Only checks done the same way (hands or not) are compared (plan 2.9).
    @Test func deltaOnlyAgainstSameMethod() {
        let first = result(1, 7)
        #expect(SelfCheckComparison.delta(latest: first, history: []) == SelfCheckDelta(sinceFirst: nil, sinceLast: nil,
                                                                                         newMethodBaseline: false))
        let second = result(15, 8)
        let third = result(29, 9)
        #expect(SelfCheckComparison.delta(latest: third, history: [first, second])
            == SelfCheckDelta(sinceFirst: 2, sinceLast: 1, newMethodBaseline: false))

        let noHands = result(29, 9, hands: false)
        #expect(SelfCheckComparison.delta(latest: noHands, history: [first, second])
            == SelfCheckDelta(sinceFirst: nil, sinceLast: nil, newMethodBaseline: true))
    }

    @Test func rejectsOutOfRange() {
        #expect(SelfCheckComparison.isValid(0))
        #expect(SelfCheckComparison.isValid(40))
        #expect(!SelfCheckComparison.isValid(-1))
        #expect(!SelfCheckComparison.isValid(41))
    }

    /// No age norms and no risk labels anywhere in what the comparison returns (plan 2.10, 1.4.1).
    @Test func noNormsOrRiskLabels() {
        let delta = SelfCheckComparison.delta(latest: result(29, 9), history: [result(1, 7)])
        let fields = Mirror(reflecting: delta).children.compactMap(\.label).map { $0.lowercased() }
        #expect(!fields.isEmpty)
        for banned in ["age", "norm", "risk", "average", "percentile", "score"] {
            #expect(fields.allSatisfy { !$0.contains(banned) }, "field mentions \(banned)")
        }
    }

    // MARK: P9 trend (plan 4.8)

    /// Up or down by 2 or more against her last check done the same way; within two weeks only.
    @Test func trendComparesTheSameWayByTwoOrMore() {
        let ny = TestSupport.newYork
        func at(_ day: Int) -> Date { TestSupport.local(ny, 2026, 10, day) }
        func trend(_ checks: [SelfCheckResult], now: Int) -> SelfCheckTrend {
            SelfCheckComparison.trend(history: checks, now: at(now), calendar: ny)
        }
        let first = SelfCheckResult(date: at(1), count: 8, usedHands: false)
        #expect(trend([first], now: 2) == .flat)
        #expect(trend([first, SelfCheckResult(date: at(15), count: 10, usedHands: false)], now: 16) == .up)
        #expect(trend([first, SelfCheckResult(date: at(15), count: 9, usedHands: false)], now: 16) == .flat)
        #expect(trend([first, SelfCheckResult(date: at(15), count: 6, usedHands: false)], now: 16) == .down)
        // Another way of doing it is not compared.
        #expect(trend([first, SelfCheckResult(date: at(15), count: 12, usedHands: true)], now: 16) == .flat)
        // The last same-way check counts, not the first one.
        let middle = SelfCheckResult(date: at(8), count: 11, usedHands: false)
        #expect(trend([first, middle, SelfCheckResult(date: at(15), count: 11, usedHands: false)], now: 16) == .flat)
        // It lasts two weeks after the check.
        let up = [first, SelfCheckResult(date: at(15), count: 10, usedHands: false)]
        #expect(trend(up, now: 29) == .up)
        #expect(trend(up, now: 30) == .flat)
    }
}
