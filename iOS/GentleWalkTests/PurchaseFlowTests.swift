import Foundation
import SwiftData
import Testing
import GentleWalkCore
@testable import GentleWalk

/// Buying from the paywall (owner report 09/10/2026, TestFlight: Apple's "This item is not available."
/// over the "Next, Apple will ask you to confirm" step). The paywall closes only once the "pro"
/// entitlement is really active; otherwise it stays open and says calmly what happened.
@MainActor @Suite(.serialized) struct PurchaseFlowTests {
    static let now = Date(timeIntervalSince1970: 1_790_000_000)

    /// An app on the paywall opened from something marked Pro, over a store with the three plans loaded.
    func makeApp() async throws -> (AppModel, FakePurchaseBackend) {
        let container = try ModelContainerFactory.make(inMemory: true)
        let defaults = try #require(UserDefaults(suiteName: "purchase-flow-tests"))
        defaults.removePersistentDomain(forName: "purchase-flow-tests")
        let backend = FakePurchaseBackend(now: Self.now)
        let store = StoreService(backend: backend, now: { Self.now })
        try await store.loadProducts()
        let app = AppModel(container: container, content: TestFixtures.content, store: store,
                           health: HealthService(store: CaptureHealthStore(connected: false), defaults: defaults),
                           notificationCenter: CaptureNotificationCenter(),
                           location: LocationService(manager: CaptureLocationManager(), background: CaptureBackgroundActivity()),
                           pedometer: PedometerService(pedometer: CapturePedometer()), motion: MotionService(), defaults: defaults)
        app.reload()
        app.cover = .paywall(.lockedContent)
        return (app, backend)
    }

    func option(_ kind: PlanKind, in app: AppModel) throws -> PlanOption {
        try #require(PaywallModel.options(from: app.store.offers).first { $0.kind == kind })
    }

    func isPaywall(_ cover: AppCover?) -> Bool {
        if case .paywall? = cover { return true } else { return false }
    }

    /// The store can't sell the plan: the calm line on the paywall, no Pro, the paywall stays, no alert
    /// on top of Apple's, and the plans are read once more past the cache.
    @Test func unavailablePlanSaysSoAndStays() async throws {
        let (app, backend) = try await makeApp()
        backend.failsPurchase = PurchaseFailure(reason: .planUnavailable, code: "test")
        let notice = await app.purchase(try option(.yearly, in: app), trigger: .lockedContent)
        #expect(notice == .planUnavailable)
        #expect(app.store.entitlement == .free)
        #expect(!app.isPro)
        #expect(isPaywall(app.cover))
        #expect(app.storeNotice == nil)
        #expect(backend.refreshes == 1)
        #expect(app.store.offers.count == 3)
    }

    /// Asked again, the store sells nothing: the plans empty out, so the paywall shows "Plans aren't
    /// available right now" instead of live buy buttons.
    @Test func unavailableWithNothingLeftEmptiesThePlans() async throws {
        let (app, backend) = try await makeApp()
        let yearly = try option(.yearly, in: app)
        backend.failsPurchase = PurchaseFailure(reason: .planUnavailable, code: "test")
        backend.offerList = []
        let notice = await app.purchase(yearly, trigger: .lockedContent)
        #expect(notice == .planUnavailable)
        #expect(app.store.offers.isEmpty)
        #expect(isPaywall(app.cover))
        #expect(app.store.entitlement == .free)
    }

    /// She closed Apple's sheet: no message at all, the paywall stays.
    @Test func cancelledPurchaseSaysNothing() async throws {
        let (app, backend) = try await makeApp()
        backend.nextPurchase = .cancelled
        let notice = await app.purchase(try option(.yearly, in: app), trigger: .lockedContent)
        #expect(notice == nil)
        #expect(app.storeNotice == nil)
        #expect(isPaywall(app.cover))
        #expect(app.store.entitlement == .free)
        #expect(backend.refreshes == 0)
    }

    /// Bought: Pro is on and the paywall closes. Monthly, because a trial schedules its reminder in a task
    /// of its own that would outlive this test's in-memory store (the trial is covered in StoreServiceTests).
    @Test func successUnlocksAndClosesThePaywall() async throws {
        let (app, _) = try await makeApp()
        let notice = await app.purchase(try option(.monthly, in: app), trigger: .lockedContent)
        #expect(notice == nil)
        #expect(app.store.entitlement == .subscribed)
        #expect(app.isPro)
        #expect(!isPaywall(app.cover))
    }

    /// Ask to Buy: a neutral "waiting for approval" line, nothing unlocked yet, the paywall stays.
    @Test func askToBuyWaitsWithANeutralLine() async throws {
        let (app, backend) = try await makeApp()
        backend.nextPurchase = .pending
        let notice = await app.purchase(try option(.monthly, in: app), trigger: .lockedContent)
        #expect(notice == .pending)
        #expect(app.store.entitlement == .free)
        #expect(isPaywall(app.cover))
    }

    /// The store took the purchase but "pro" is not active (an entitlement left off in RevenueCat): she is
    /// not moved on as if she had Pro; the paywall stays and points to Restore.
    @Test func purchaseWithoutTheEntitlementKeepsThePaywall() async throws {
        let (app, backend) = try await makeApp()
        backend.nextPurchase = .purchased(.empty)
        let notice = await app.purchase(try option(.lifetime, in: app), trigger: .lockedContent)
        #expect(notice == .notActive)
        #expect(!app.isPro)
        #expect(isPaywall(app.cover))
    }

    /// No connection: the connection line, and no re-reading of the plans.
    @Test func networkFailureAsksToCheckTheConnection() async throws {
        let (app, backend) = try await makeApp()
        backend.failsPurchase = PurchaseFailure(reason: .network, code: "test")
        let notice = await app.purchase(try option(.yearly, in: app), trigger: .lockedContent)
        #expect(notice == .couldNotConnect)
        #expect(isPaywall(app.cover))
        #expect(backend.refreshes == 0)
    }

    /// Any other store error: a plain "couldn't finish" line, never "check your connection".
    @Test func otherStoreErrorSaysItCouldNotFinish() async throws {
        let (app, backend) = try await makeApp()
        backend.failsPurchase = PurchaseFailure(reason: .other, code: "test")
        let notice = await app.purchase(try option(.yearly, in: app), trigger: .lockedContent)
        #expect(notice == .couldNotFinish)
        #expect(isPaywall(app.cover))
    }

    /// What each line says (EN), calm and with no blame or store jargon.
    @Test func noticeWording() {
        #expect(String(localized: PaywallNotice.planUnavailable.message)
            == "This plan isn't available in your App Store country or right now. Try another plan or try again later.")
        #expect(String(localized: PaywallNotice.pending.message)
            == "Waiting for approval. Your plan will start as soon as it's approved.")
        #expect(String(localized: PaywallNotice.notActive.message)
            == "We're still confirming your purchase. If your plan hasn't started in a minute, tap Restore.")
        #expect(String(localized: PaywallNotice.couldNotConnect.message)
            == "Couldn't reach the App Store. Please check your connection and try again.")
        #expect(String(localized: PaywallNotice.couldNotFinish.message)
            == "The App Store couldn't finish the purchase. Please try again later.")
    }
}
