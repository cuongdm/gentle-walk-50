import Foundation
import StoreKit
import StoreKitTest
import Testing
import GentleWalkCore
@testable import GentleWalk

@MainActor final class FakeTrialReminders: TrialReminderScheduling {
    private(set) var scheduled: [(at: Date, billing: Date, price: String)] = []
    private(set) var cancels = 0
    func scheduleTrialReminder(at date: Date, billingDate: Date, price: String) { scheduled.append((date, billingDate, price)) }
    func cancelTrialReminder() { cancels += 1 }
}

/// StoreKit flows against App/GentleWalk.storekit. One shared test session: suites run serialized.
@MainActor @Suite(.serialized) struct StoreServiceTests {
    let session: SKTestSession

    init() throws {
        session = try SKTestSession(contentsOf: TestFixtures.url("GentleWalk", "storekit"))
        session.disableDialogs = true
        session.resetToDefaultState()
        session.clearTransactions()
    }

    func store(reminders: TrialReminderScheduling? = nil) async throws -> StoreService {
        let session = session
        let store = StoreService(sync: {}, purchaser: { product in
            .purchased(try await session.buyProduct(identifier: product.id))
        }, trialReminders: reminders)
        try await store.loadProducts()
        return store
    }

    /// The StoreKit test session applies expiry, refunds and renewal changes asynchronously (slower
    /// on the iOS 27 runtime); in the app the `Transaction.updates` listener refreshes when they land.
    /// Re-read until the expected state shows up, for at most `timeout`.
    func refresh(_ store: StoreService, timeout: Duration = .seconds(5), until done: () -> Bool) async throws {
        let clock = ContinuousClock()
        let deadline = clock.now + timeout
        await store.refresh()
        while !done(), clock.now < deadline {
            try await Task.sleep(for: .milliseconds(200))
            await store.refresh()
        }
    }

    @Test func purchaseYearlyStartsTrial() async throws {
        let store = try await store()
        #expect(store.products.count == 3)
        _ = try await store.purchase(ProductID.yearly)
        guard case .trial = store.entitlement else { Issue.record("expected trial, got \(store.entitlement)"); return }
        #expect(store.activeRenewingProductID == ProductID.yearly)
    }

    @Test func restoreAfterReinstall() async throws {
        _ = try await session.buyProduct(identifier: ProductID.monthly)
        let fresh = try await store()
        try await fresh.restore()
        #expect(fresh.entitlement == .subscribed)
    }

    @Test func expiryDropsToFree() async throws {
        let store = try await store()
        _ = try await store.purchase(ProductID.monthly)
        #expect(store.entitlement == .subscribed)
        try session.expireSubscription(productIdentifier: ProductID.monthly)
        try await refresh(store) { store.entitlement == .free }
        for await r in Transaction.currentEntitlements { if case .verified(let t) = r { print("DIAG current", t.id, t.productID, t.expirationDate as Any, t.revocationDate as Any, Date.now) } }
        for await r in Transaction.all { if case .verified(let t) = r { print("DIAG all", t.id, t.productID, t.purchaseDate, t.expirationDate as Any) } }
        for t in session.allTransactions() { print("DIAG session", t.identifier, t.productIdentifier, t.expirationDate as Any, t.autoRenewingEnabled) }
        print("DIAG entitlement", store.entitlement)
        #expect(store.entitlement == .free)
    }

    @Test func refundRevokesAccess() async throws {
        let store = try await store()
        _ = try await store.purchase(ProductID.lifetime)
        #expect(store.entitlement == .lifetime)
        let transaction = try #require(session.allTransactions().first { $0.productIdentifier == ProductID.lifetime })
        try session.refundTransaction(identifier: transaction.identifier)
        try await refresh(store) { store.entitlement == .free }
        #expect(store.entitlement == .free)
    }

    @Test func lifetimePurchaseUnlocksForever() async throws {
        let store = try await store()
        let outcome = try await store.purchase(ProductID.lifetime)
        #expect(outcome == .purchased)
        #expect(store.entitlement == .lifetime)
        #expect(store.activeRenewingProductID == nil)
    }

    @Test func introOfferEligibility() async throws {
        let store = try await store()
        #expect(store.isEligibleForTrial)
        _ = try await store.purchase(ProductID.yearly)
        try session.expireSubscription(productIdentifier: ProductID.yearly)
        try await Task.sleep(for: .seconds(1))
        await store.refresh()
        #expect(!store.isEligibleForTrial)
    }

    @Test func lifetimeWhileSubscribedKeepsBothAndFlagsCancel() async throws {
        let store = try await store()
        _ = try await store.purchase(ProductID.yearly)
        _ = try await store.purchase(ProductID.lifetime)
        #expect(store.entitlement == .lifetime)
        try await Task.sleep(for: .seconds(1))
        await store.refresh()
        #expect(store.entitlement == .lifetime)
        #expect(store.activeRenewingProductID == ProductID.yearly)
    }

    // MARK: Trial reminder (task 5.12)

    @Test func trialPurchaseSchedulesTheDayTwelveReminder() async throws {
        let reminders = FakeTrialReminders()
        let store = try await store(reminders: reminders)
        _ = try await store.purchase(ProductID.yearly)
        let reminder = try #require(reminders.scheduled.last)
        guard case .trial(let ends) = store.entitlement else { Issue.record("no trial"); return }
        #expect(reminder.billing == ends)
        let expected = TrialTimeline(start: ends.addingTimeInterval(-14 * 86_400), trialLength: 14, calendar: .current).reminderDate
        #expect(abs(reminder.at.timeIntervalSince(expected)) < 86_400 * 0.5)
        #expect(!reminder.price.isEmpty)
    }

    @Test func turningOffAutoRenewCancelsTheReminder() async throws {
        let reminders = FakeTrialReminders()
        let store = try await store(reminders: reminders)
        _ = try await store.purchase(ProductID.yearly)
        let transaction = try #require(session.allTransactions().first { $0.productIdentifier == ProductID.yearly })
        try session.disableAutoRenewForTransaction(identifier: transaction.identifier)
        let cancelsBefore = reminders.cancels
        try await refresh(store) { store.activeRenewingProductID == nil }
        #expect(reminders.cancels > cancelsBefore)
    }
}
