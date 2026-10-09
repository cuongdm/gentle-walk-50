import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

@MainActor final class FakeTrialReminders: TrialReminderScheduling {
    private(set) var scheduled: [(at: Date, billing: Date, price: String)] = []
    private(set) var cancels = 0
    func scheduleTrialReminder(at date: Date, billingDate: Date, price: String) { scheduled.append((date, billingDate, price)) }
    func cancelTrialReminder() { cancels += 1 }
}

/// The purchase layer in memory: plans, a customer record, and what each purchase does. Stands in for
/// RevenueCat so the tests never touch the network (owner 09/10/2026).
@MainActor final class FakePurchaseBackend: PurchaseBackend {
    struct Failed: Error {}

    var offerList: [StoreOffer]
    var record: CustomerSnapshot = .empty
    var eligibility: IntroEligibility = .eligible
    /// What the next purchase does; nil = it goes through.
    var nextPurchase: BackendPurchase?
    /// The next purchase fails like this (RevenueCat's error, already mapped), before anything else.
    var failsPurchase: PurchaseFailure?
    var failsOffers = false
    /// How many times the plans were read past the cache (after a plan the store can't sell).
    private(set) var refreshes = 0
    var failsRestore = false
    /// Restore finds these purchases (a reinstall on a new phone).
    var restorable: CustomerSnapshot?
    let now: Date
    private var continuation: AsyncStream<CustomerSnapshot>.Continuation?

    init(trialPeriod: (value: Int, unit: TrialOffer.Unit)? = (2, .week), now: Date) {
        self.now = now
        let days = trialPeriod.flatMap { TrialOffer.days(value: $0.value, unit: $0.unit) }
        offerList = [
            StoreOffer(id: ProductID.yearly, kind: .yearly, displayPrice: "$49.99", price: Decimal(string: "49.99")!,
                       currencyCode: "USD", freeTrialDays: days),
            StoreOffer(id: ProductID.monthly, kind: .monthly, displayPrice: "$9.99", price: Decimal(string: "9.99")!,
                       currencyCode: "USD", freeTrialDays: nil),
            StoreOffer(id: ProductID.lifetime, kind: .lifetime, displayPrice: "$99.99", price: Decimal(string: "99.99")!,
                       currencyCode: "USD", freeTrialDays: nil),
        ]
    }

    func offers(refresh: Bool) async throws -> [StoreOffer] {
        if refresh { refreshes += 1 }
        if failsOffers { throw Failed() }
        // Like RevenueCat's backend: a store with nothing to sell is an error, never an empty list.
        if offerList.isEmpty { throw StoreError.productUnavailable }
        return offerList
    }

    func customer() async throws -> CustomerSnapshot { record }

    func customerUpdates() -> AsyncStream<CustomerSnapshot> {
        AsyncStream { continuation = $0 }
    }

    /// A change from the store (renewal, refund, expiry), as RevenueCat's stream delivers it.
    func push(_ snapshot: CustomerSnapshot) {
        record = snapshot
        continuation?.yield(snapshot)
    }

    func purchase(_ productID: String) async throws -> BackendPurchase {
        if let failsPurchase { throw failsPurchase }
        if let next = nextPurchase { return next }
        let offer = try #require(offerList.first { $0.id == productID })
        var purchased = record.purchasedProductIDs
        purchased.insert(productID)
        var subscriptions = record.subscriptions
        let pro: ProAccess
        switch offer.kind {
        case .lifetime:
            pro = ProAccess(productID: productID, isActive: true, isTrial: false, expirationDate: nil, willRenew: false)
        case .yearly, .monthly:
            let trial = offer.kind == .yearly && eligibility == .eligible && offer.freeTrialDays != nil
                && record.subscriptions.isEmpty
            let days = trial ? offer.freeTrialDays! : (offer.kind == .yearly ? 365 : 30)
            let ends = now.addingTimeInterval(Double(days) * 86_400)
            subscriptions.append(SubscriptionState(productID: productID, isActive: true, willRenew: true, expiresDate: ends))
            // A lifetime already bought keeps the entitlement pointing at it.
            if let current = record.pro, current.isActive, current.expirationDate == nil {
                pro = current
            } else {
                pro = ProAccess(productID: productID, isActive: true, isTrial: trial, expirationDate: ends, willRenew: true)
            }
        }
        record = CustomerSnapshot(pro: pro, subscriptions: subscriptions, purchasedProductIDs: purchased)
        return .purchased(record)
    }

    func restore() async throws -> CustomerSnapshot {
        if failsRestore { throw Failed() }
        if let restorable { record = restorable }
        return record
    }

    func introEligibility(for productID: String) async -> IntroEligibility { eligibility }
}

/// StoreService over the purchase seam: entitlement from the "pro" entitlement, trial from the offer,
/// renewal and the trial reminder, expiry and refunds through the update stream, and no store at all.
@MainActor @Suite(.serialized) struct StoreServiceTests {
    static let now = Date(timeIntervalSince1970: 1_790_000_000)

    func store(_ backend: FakePurchaseBackend? = nil, reminders: TrialReminderScheduling? = nil) async throws
        -> (StoreService, FakePurchaseBackend) {
        let backend = backend ?? FakePurchaseBackend(now: Self.now)
        let store = StoreService(backend: backend, trialReminders: reminders, now: { Self.now })
        try await store.loadProducts()
        return (store, backend)
    }

    /// Waits for the update stream to reach the store (it hops through a task).
    func settle(_ store: StoreService, until done: () -> Bool) async {
        for _ in 0..<50 where !done() { await Task.yield() }
    }

    @Test func purchaseYearlyStartsTrial() async throws {
        let (store, _) = try await store()
        #expect(store.offers.map(\.kind) == [.yearly, .monthly, .lifetime])
        _ = try await store.purchase(ProductID.yearly)
        guard case .trial = store.entitlement else { Issue.record("expected trial, got \(store.entitlement)"); return }
        #expect(store.activeRenewingProductID == ProductID.yearly)
    }

    @Test func restoreAfterReinstall() async throws {
        let backend = FakePurchaseBackend(now: Self.now)
        backend.restorable = CustomerSnapshot(
            pro: ProAccess(productID: ProductID.monthly, isActive: true, isTrial: false,
                           expirationDate: Self.now.addingTimeInterval(20 * 86_400), willRenew: true),
            subscriptions: [], purchasedProductIDs: [ProductID.monthly])
        let (fresh, _) = try await store(backend)
        #expect(fresh.entitlement == .free)
        try await fresh.restore()
        #expect(fresh.entitlement == .subscribed)
    }

    @Test func expiryDropsToFree() async throws {
        let (store, backend) = try await store()
        store.startListening()
        _ = try await store.purchase(ProductID.monthly)
        #expect(store.entitlement == .subscribed)
        var expired = backend.record
        expired.pro?.isActive = false
        expired.subscriptions = expired.subscriptions.map { var plan = $0; plan.isActive = false; plan.willRenew = false; return plan }
        backend.push(expired)
        await settle(store) { store.entitlement == .free }
        #expect(store.entitlement == .free)
        #expect(store.activeRenewingProductID == nil)
    }

    /// An old cached record that still says active, whose period has ended, is free (offline phone).
    @Test func endedPeriodIsFreeEvenIfTheRecordSaysActive() async throws {
        let backend = FakePurchaseBackend(now: Self.now)
        backend.record = CustomerSnapshot(
            pro: ProAccess(productID: ProductID.monthly, isActive: true, isTrial: false,
                           expirationDate: Self.now.addingTimeInterval(-3600), willRenew: true),
            subscriptions: [], purchasedProductIDs: [ProductID.monthly])
        let (store, _) = try await store(backend)
        #expect(store.entitlement == .free)
    }

    @Test func refundRevokesAccess() async throws {
        let (store, backend) = try await store()
        store.startListening()
        _ = try await store.purchase(ProductID.lifetime)
        #expect(store.entitlement == .lifetime)
        var refunded = backend.record
        refunded.pro?.isActive = false
        backend.push(refunded)
        await settle(store) { store.entitlement == .free }
        #expect(store.entitlement == .free)
    }

    @Test func updatesRebuildTheScreens() async throws {
        let (store, backend) = try await store()
        var rebuilt = 0
        store.onUpdate = { rebuilt += 1 }
        store.startListening()
        _ = try await backend.purchase(ProductID.monthly)
        backend.push(backend.record)
        await settle(store) { rebuilt > 0 }
        #expect(rebuilt > 0)
        #expect(store.entitlement == .subscribed)
    }

    @Test func lifetimePurchaseUnlocksForever() async throws {
        let (store, _) = try await store()
        let outcome = try await store.purchase(ProductID.lifetime)
        #expect(outcome == .purchased)
        #expect(store.entitlement == .lifetime)
        #expect(store.activeRenewingProductID == nil)
    }

    @Test func pendingAndCancelledPurchasesChangeNothing() async throws {
        let (store, backend) = try await store()
        backend.nextPurchase = .pending
        #expect(try await store.purchase(ProductID.yearly) == .pending)
        backend.nextPurchase = .cancelled
        #expect(try await store.purchase(ProductID.yearly) == .cancelled)
        #expect(store.entitlement == .free)
    }

    @Test func introOfferEligibility() async throws {
        let (store, _) = try await store()
        #expect(store.isEligibleForTrial)
        _ = try await store.purchase(ProductID.yearly)
        #expect(!store.isEligibleForTrial)

        let lapsed = FakePurchaseBackend(now: Self.now)
        lapsed.eligibility = .ineligible
        let (again, _) = try await self.store(lapsed)
        #expect(!again.isEligibleForTrial)
    }

    @Test func lifetimeWhileSubscribedKeepsBothAndFlagsCancel() async throws {
        let (store, _) = try await store()
        _ = try await store.purchase(ProductID.yearly)
        _ = try await store.purchase(ProductID.lifetime)
        #expect(store.entitlement == .lifetime)
        await store.refresh()
        #expect(store.entitlement == .lifetime)
        #expect(store.activeRenewingProductID == ProductID.yearly)
    }

    // MARK: Trial length from the offer (review I-1, 08/10/2026)

    @Test func trialDaysComeFromTheIntroOffer() async throws {
        let (store, _) = try await store()
        #expect(store.trialDays == 14)
        #expect(store.isEligibleForTrial)
    }

    @Test func oneWeekOfferReadsSevenDays() async throws {
        let reminders = FakeTrialReminders()
        let (store, _) = try await store(FakePurchaseBackend(trialPeriod: (1, .week), now: Self.now), reminders: reminders)
        #expect(store.trialDays == 7)
        #expect(store.isEligibleForTrial)
        _ = try await store.purchase(ProductID.yearly)
        guard case .trial(let ends) = store.entitlement else { Issue.record("no trial"); return }
        let reminder = try #require(reminders.scheduled.last)
        let expected = TrialTimeline(billingDate: ends, trialLength: 7, calendar: .current).reminderDate
        #expect(abs(reminder.at.timeIntervalSince(expected)) < 86_400 * 0.5)
    }

    @Test func noIntroOfferMeansNoTrial() async throws {
        let (store, _) = try await store(FakePurchaseBackend(trialPeriod: nil, now: Self.now))
        #expect(store.trialDays == nil)
        #expect(!store.isEligibleForTrial)
    }

    // MARK: Trial reminder (task 5.12)

    @Test func trialPurchaseSchedulesTheDayTwelveReminder() async throws {
        let reminders = FakeTrialReminders()
        let (store, _) = try await store(reminders: reminders)
        _ = try await store.purchase(ProductID.yearly)
        let reminder = try #require(reminders.scheduled.last)
        guard case .trial(let ends) = store.entitlement else { Issue.record("no trial"); return }
        #expect(reminder.billing == ends)
        #expect(store.trialDays == 14)
        let expected = TrialTimeline(billingDate: ends, trialLength: 14, calendar: .current).reminderDate
        #expect(abs(reminder.at.timeIntervalSince(expected)) < 86_400 * 0.5)
        #expect(reminder.price == "$49.99")
    }

    @Test func turningOffAutoRenewCancelsTheReminder() async throws {
        let reminders = FakeTrialReminders()
        let (store, backend) = try await store(reminders: reminders)
        store.startListening()
        _ = try await store.purchase(ProductID.yearly)
        let cancelsBefore = reminders.cancels
        var cancelled = backend.record
        cancelled.pro?.willRenew = false
        cancelled.subscriptions = cancelled.subscriptions.map { var plan = $0; plan.willRenew = false; return plan }
        backend.push(cancelled)
        await settle(store) { store.activeRenewingProductID == nil }
        #expect(store.activeRenewingProductID == nil)
        #expect(reminders.cancels > cancelsBefore)
    }

    // MARK: No store (no RevenueCat key, owner 09/10/2026): free plan, never a crash

    @Test func noBackendMeansFreeAndUnavailable() async throws {
        let store = StoreService(backend: nil)
        #expect(!store.isAvailable)
        store.startListening()
        await store.refresh()
        #expect(store.entitlement == .free)
        #expect(!store.isEligibleForTrial)
        await #expect(throws: StoreError.self) { try await store.loadProducts() }
        await #expect(throws: StoreError.self) { try await store.purchase(ProductID.yearly) }
        await #expect(throws: StoreError.self) { try await store.restore() }
        #expect(store.offers.isEmpty)
    }

    /// Plans that fail to load leave the store empty (the paywall then offers "Try again").
    @Test func failedOffersLeaveNoPlans() async throws {
        let backend = FakePurchaseBackend(now: Self.now)
        backend.failsOffers = true
        let store = StoreService(backend: backend, now: { Self.now })
        await #expect(throws: (any Error).self) { try await store.loadProducts() }
        #expect(store.offers.isEmpty)
        backend.failsOffers = false
        try await store.loadProducts()
        #expect(store.offers.count == 3)
    }

    /// RevenueCat's error codes, as the paywall tells them (owner report 09/10/2026, TestFlight: "This item
    /// is not available."). The code itself goes to the log only.
    @Test func revenueCatErrorsMapToWhatThePaywallSays() {
        func failure(_ code: Int, _ info: [String: Any] = [:]) -> PurchaseFailure {
            RevenueCatBackend.failure(NSError(domain: RevenueCatBackend.errorDomain, code: code, userInfo: info))
        }
        #expect(failure(5).reason == .planUnavailable)  // productNotAvailableForPurchaseError
        #expect(failure(10).reason == .network)  // networkError
        #expect(failure(35).reason == .network)  // offlineConnectionError
        #expect(failure(2).reason == .other)  // storeProblemError
        #expect(failure(3).reason == .other)  // purchaseNotAllowedError
        #expect(RevenueCatBackend.failure(StoreError.productUnavailable).reason == .planUnavailable)
        #expect(RevenueCatBackend.failure(NSError(domain: "Elsewhere", code: 7)).reason == .other)
        // The log line names RevenueCat's code and the store error under it; never her data.
        let logged = failure(5, ["readable_error_code": "PRODUCT_NOT_AVAILABLE_FOR_PURCHASE",
                                 "rc_root_error": ["domain": "StoreKit.StoreKitError", "code": 3, "localizedDescription": "x"]])
        #expect(logged.code == "RevenueCat 5 PRODUCT_NOT_AVAILABLE_FOR_PURCHASE, root StoreKit.StoreKitError 3")
    }

    /// A purchase that fails is logged and reaches the caller as a `PurchaseFailure`; nothing changes.
    @Test func failedPurchaseChangesNothing() async throws {
        let (store, backend) = try await store()
        backend.failsPurchase = PurchaseFailure(reason: .planUnavailable, code: "test")
        await #expect(throws: PurchaseFailure(reason: .planUnavailable, code: "test")) {
            try await store.purchase(ProductID.yearly)
        }
        #expect(store.entitlement == .free)
        #expect(store.offers.count == 3)
    }

    /// The store took the purchase but the "pro" entitlement is not on (RevenueCat set up without it):
    /// not counted as bought.
    @Test func purchaseWithoutTheEntitlementIsNotBought() async throws {
        let (store, backend) = try await store()
        backend.nextPurchase = .purchased(.empty)
        #expect(try await store.purchase(ProductID.monthly) == .notActive)
        #expect(store.entitlement == .free)
    }

    /// Read again past the cache after a plan the store can't sell: a store with nothing left empties the
    /// plans (the paywall then says "Plans aren't available right now").
    @Test func reloadAfterUnavailableEmptiesWhenNothingIsSold() async throws {
        let (store, backend) = try await store()
        await store.reloadAfterUnavailablePlan()
        #expect(backend.refreshes == 1)
        #expect(store.offers.count == 3)
        backend.offerList.removeAll { $0.kind == .yearly }
        await store.reloadAfterUnavailablePlan()
        #expect(store.offers.map(\.kind) == [.monthly, .lifetime])
        backend.offerList = []
        await store.reloadAfterUnavailablePlan()
        #expect(backend.refreshes == 3)
        #expect(store.offers.isEmpty)
    }

    /// The public key from build settings: only a real App Store key configures RevenueCat.
    @Test func publicKeyNeedsARealValue() {
        #expect(RevenueCatKey.validated(nil) == nil)
        #expect(RevenueCatKey.validated("") == nil)
        #expect(RevenueCatKey.validated("$(REVENUECAT_PUBLIC_KEY)") == nil)
        #expect(RevenueCatKey.validated("appl_XXXXXXXXXXXXXXXXXXXXXXXXXXX") == nil)
        #expect(RevenueCatKey.validated("sk_live_secret") == nil)
        #expect(RevenueCatKey.validated(" appl_AbCdEf123 ") == "appl_AbCdEf123")
    }
}
