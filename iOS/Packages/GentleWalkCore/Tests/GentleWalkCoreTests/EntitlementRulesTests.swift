import Foundation
import Testing
@testable import GentleWalkCore

@Suite struct EntitlementRulesTests {
    static let now = TestSupport.date("2026-10-01T12:00:00Z")
    static let later = TestSupport.date("2026-10-11T12:00:00Z")
    static let earlier = TestSupport.date("2026-09-20T12:00:00Z")

    static func yearly(expires: Date, trial: Bool = false, revoked: Date? = nil) -> TransactionSnapshot {
        TransactionSnapshot(productID: ProductID.yearly, purchaseDate: earlier, expirationDate: expires,
                            revocationDate: revoked, isFreeTrial: trial)
    }

    static let lifetime = TransactionSnapshot(productID: ProductID.lifetime, purchaseDate: earlier,
                                              expirationDate: nil, revocationDate: nil, isFreeTrial: false)

    static let cases: [([TransactionSnapshot], Entitlement)] = [
        ([], .free),
        ([yearly(expires: later, trial: true)], .trial(ends: later)),
        ([yearly(expires: later)], .subscribed),
        ([lifetime], .lifetime),
        ([yearly(expires: later, trial: true), lifetime], .lifetime),
        ([yearly(expires: later, revoked: earlier)], .free),
        ([yearly(expires: earlier)], .free),
        ([TransactionSnapshot(productID: ProductID.monthly, purchaseDate: earlier, expirationDate: later,
                              revocationDate: nil, isFreeTrial: false)], .subscribed),
        ([TransactionSnapshot(productID: ProductID.lifetime, purchaseDate: earlier, expirationDate: nil,
                              revocationDate: earlier, isFreeTrial: false)], .free),
        ([TransactionSnapshot(productID: "com.example.other", purchaseDate: earlier, expirationDate: later,
                              revocationDate: nil, isFreeTrial: false)], .free),
    ]

    @Test(arguments: cases)
    func resolve(_ snapshots: [TransactionSnapshot], _ expected: Entitlement) {
        #expect(EntitlementRules.resolve(snapshots, now: Self.now) == expected)
    }
}
