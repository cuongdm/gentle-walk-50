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
}
