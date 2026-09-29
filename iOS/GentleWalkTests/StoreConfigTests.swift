import StoreKit
import StoreKitTest
import Testing

/// Checks App/GentleWalk.storekit — the local StoreKit configuration used by tests and Xcode runs.
/// Prices in that file are test values only; real prices come from App Store Connect.
@Suite(.serialized) @MainActor
struct StoreConfigTests {
    static let ids = ["com.kmd.gentlewalk.pro.yearly", "com.kmd.gentlewalk.pro.monthly", "com.kmd.gentlewalk.pro.lifetime"]

    @Test func loadsThreeProducts() async throws {
        let session = try SKTestSession(configurationFileNamed: "GentleWalk")
        session.disableDialogs = true
        session.clearTransactions()

        let products = try await Product.products(for: Self.ids)
        #expect(products.count == 3)

        let byID = Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0) })
        let yearly = try #require(byID["com.kmd.gentlewalk.pro.yearly"])
        let monthly = try #require(byID["com.kmd.gentlewalk.pro.monthly"])
        let lifetime = try #require(byID["com.kmd.gentlewalk.pro.lifetime"])

        #expect(yearly.type == .autoRenewable)
        #expect(monthly.type == .autoRenewable)
        #expect(lifetime.type == .nonConsumable)
        // One subscription group, same level, so yearly <-> monthly is a crossgrade (3.1.2(b)).
        #expect(yearly.subscription?.subscriptionGroupID == monthly.subscription?.subscriptionGroupID)
        #expect(yearly.subscription?.subscriptionPeriod.unit == .year)
        #expect(yearly.subscription?.subscriptionPeriod.value == 1)
        #expect(monthly.subscription?.subscriptionPeriod.unit == .month)
        #expect(monthly.subscription?.subscriptionPeriod.value == 1)
        // 14-day free trial on the yearly plan only.
        let intro = try #require(yearly.subscription?.introductoryOffer)
        #expect(intro.paymentMode == .freeTrial)
        #expect(intro.period.unit == .week)
        #expect(intro.period.value == 2)
        #expect(monthly.subscription?.introductoryOffer == nil)
    }
}
