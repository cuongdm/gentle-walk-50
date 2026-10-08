import StoreKit
import StoreKitTest
import Testing

/// Checks App/GentleWalk.storekit — the local StoreKit configuration for Xcode runs and screenshots.
/// It mirrors App Store Connect (owner 09/10/2026: 49.99 / 9.99 / 99.99 USD, 14-day trial on yearly);
/// the app reads prices through RevenueCat, which reads them from the store.
@Suite(.serialized) @MainActor
struct StoreConfigTests {
    static let ids = ["com.kmd.goodfooting.pro.yearly", "com.kmd.goodfooting.pro.monthly", "com.kmd.goodfooting.pro.lifetime"]

    @Test func loadsThreeProducts() async throws {
        let session = try SKTestSession(configurationFileNamed: "GentleWalk")
        session.disableDialogs = true
        session.clearTransactions()

        let products = try await Product.products(for: Self.ids)
        #expect(products.count == 3)

        let byID = Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0) })
        let yearly = try #require(byID["com.kmd.goodfooting.pro.yearly"])
        let monthly = try #require(byID["com.kmd.goodfooting.pro.monthly"])
        let lifetime = try #require(byID["com.kmd.goodfooting.pro.lifetime"])

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
        // Prices chosen 09/10/2026 (research 2026-10-08 §7.1).
        #expect(yearly.price == Decimal(string: "49.99"))
        #expect(monthly.price == Decimal(string: "9.99"))
        #expect(lifetime.price == Decimal(string: "99.99"))
    }

    /// RevenueCat collects purchase history (owner 09/10/2026): declared, never linked to her, never tracking.
    @Test func privacyManifestDeclaresPurchaseHistoryOnly() throws {
        let url = try #require(Bundle.main.url(forResource: "PrivacyInfo", withExtension: "xcprivacy"))
        let plist = try #require(try PropertyListSerialization.propertyList(from: Data(contentsOf: url), format: nil) as? [String: Any])
        #expect(plist["NSPrivacyTracking"] as? Bool == false)
        let collected = try #require(plist["NSPrivacyCollectedDataTypes"] as? [[String: Any]])
        #expect(collected.map { $0["NSPrivacyCollectedDataType"] as? String } == ["NSPrivacyCollectedDataTypePurchaseHistory"])
        #expect(collected.first?["NSPrivacyCollectedDataTypeLinked"] as? Bool == false)
        #expect(collected.first?["NSPrivacyCollectedDataTypeTracking"] as? Bool == false)
    }
}
