import Foundation
import Observation
import StoreKit
import GentleWalkCore

/// Schedules the "trial ends" notification (always sent, task 5.12); the notification service does it.
@MainActor protocol TrialReminderScheduling: AnyObject {
    func scheduleTrialReminder(at date: Date, billingDate: Date, price: String)
    func cancelTrialReminder()
}

enum PurchaseOutcome: Equatable, Sendable { case purchased, pending, cancelled }

enum StoreError: Error { case productUnavailable, unverified }

/// StoreKit 2 in one place (task 5.8). The source of truth is `Transaction.currentEntitlements`,
/// refreshed at launch, after a purchase or restore, and on every `Transaction.updates` event.
@Observable @MainActor final class StoreService {
    private(set) var products: [String: Product] = [:]
    private(set) var entitlement: Entitlement = .free
    /// A yearly or monthly plan that will renew. Set even with lifetime, so Me and the paywall can
    /// warn that it keeps renewing until cancelled (I2).
    private(set) var activeRenewingProductID: String?
    private(set) var renewalDate: Date?
    private(set) var isEligibleForTrial = true

    @ObservationIgnored private let sync: () async throws -> Void
    @ObservationIgnored private let purchaser: Purchaser
    @ObservationIgnored private weak var trialReminders: TrialReminderScheduling?
    @ObservationIgnored private var updates: Task<Void, Never>?
    /// Called after a `Transaction.updates` event was applied (refund, Ask to Buy, renewal), so
    /// the screens built from the entitlement are rebuilt.
    @ObservationIgnored var onUpdate: (() -> Void)?

    /// - Parameters:
    ///   - sync: `AppStore.sync()` in the app; tests pass a no-op (it asks for an Apple ID).
    ///   - purchaser: Apple's purchase sheet in the app; the StoreKit test session in tests.
    init(sync: @escaping () async throws -> Void = { try await AppStore.sync() },
         purchaser: @escaping Purchaser = StoreService.appStorePurchaser,
         trialReminders: TrialReminderScheduling? = nil) {
        self.sync = sync
        self.purchaser = purchaser
        self.trialReminders = trialReminders
    }

    func setTrialReminders(_ scheduler: TrialReminderScheduling?) { trialReminders = scheduler }

    /// Listens for renewals, refunds and purchases made elsewhere. Call once at launch.
    func startListening() {
        guard updates == nil else { return }
        updates = Task { [weak self] in
            for await update in Transaction.updates {
                if case .verified(let transaction) = update { await transaction.finish() }
                await self?.refresh()
                self?.onUpdate?()
            }
        }
    }

    func loadProducts() async throws {
        let list = try await Product.products(for: ProductID.all)
        products = Dictionary(list.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        await refresh()
    }

    func purchase(_ productID: String) async throws -> PurchaseOutcome {
        guard let product = products[productID] else { throw StoreError.productUnavailable }
        switch try await purchaser(product) {
        case .purchased(let transaction):
            await transaction.finish()
            await refresh(including: transaction)
            return .purchased
        case .pending:
            return .pending
        case .cancelled:
            return .cancelled
        }
    }

    /// Result of the purchase step, before entitlements are refreshed.
    enum PurchaseStep: Sendable { case purchased(Transaction), pending, cancelled }
    typealias Purchaser = @MainActor (Product) async throws -> PurchaseStep

    /// Apple's purchase sheet. Tests pass `SKTestSession.buyProduct`, because the sheet cannot
    /// appear in a unit-test host.
    static let appStorePurchaser: Purchaser = { product in
        switch try await product.purchase() {
        case .success(let verification):
            guard case .verified(let transaction) = verification else { throw StoreError.unverified }
            return .purchased(transaction)
        case .pending:
            return .pending
        case .userCancelled:
            return .cancelled
        @unknown default:
            return .cancelled
        }
    }

    /// Restore purchase: asks the App Store to sync, then re-reads entitlements.
    func restore() async throws {
        try await sync()
        await refresh()
    }

    /// - Parameter purchased: a transaction that just completed; `currentEntitlements` can lag a
    ///   moment behind a purchase, so it is counted directly.
    func refresh(including purchased: Transaction? = nil) async {
        var snapshots: [TransactionSnapshot] = []
        var seen: Set<UInt64> = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                snapshots.append(TransactionSnapshot(transaction))
                seen.insert(transaction.id)
            }
        }
        if let purchased, !seen.contains(purchased.id) { snapshots.append(TransactionSnapshot(purchased)) }
        var resolved = EntitlementRules.resolve(snapshots, now: .now)
        let renewal = await readRenewal()
        // Apple still retrying the payment in the grace period: Pro stays (its transaction already
        // reads as expired; review 02/10/2026).
        if renewal?.inGracePeriod == true, resolved == .free { resolved = .subscribed }
        entitlement = resolved
        // Assigned once, after every await: a refresh running alongside (Transaction.updates after the
        // same purchase) can no longer leave them nil halfway (review 02/10/2026).
        activeRenewingProductID = renewal?.productID
        renewalDate = renewal?.date
        if renewal == nil {
            // Status not readable yet (right after a purchase): an active, unrevoked plan renews.
            let now = Date.now
            let active = snapshots.first { snapshot in
                ProductID.subscriptions.contains(snapshot.productID) && snapshot.revocationDate == nil
                    && (snapshot.expirationDate ?? .distantPast) > now
            }
            activeRenewingProductID = active?.productID
            renewalDate = active?.expirationDate
        }
        isEligibleForTrial = await trialEligibility()
        updateTrialReminder()
    }

    private struct Renewal { var productID: String?; var date: Date?; var inGracePeriod: Bool }

    /// Which plan in the group will renew, when, and whether Apple is in the billing grace period.
    /// nil when the status cannot be read yet.
    private func readRenewal() async -> Renewal? {
        guard let subscription = products[ProductID.yearly]?.subscription ?? products[ProductID.monthly]?.subscription,
              let statuses = try? await subscription.status, !statuses.isEmpty else { return nil }
        var result = Renewal(productID: nil, date: nil, inGracePeriod: false)
        for status in statuses where [.subscribed, .inGracePeriod, .inBillingRetryPeriod].contains(status.state) {
            if status.state == .inGracePeriod { result.inGracePeriod = true }
            guard case .verified(let renewal) = status.renewalInfo, renewal.willAutoRenew else { continue }
            result.productID = renewal.autoRenewPreference ?? renewal.currentProductID
            if case .verified(let transaction) = status.transaction {
                result.date = renewal.renewalDate ?? transaction.expirationDate
            }
        }
        return result
    }

    /// The free trial is offered once per subscription group: StoreKit's flag, and no earlier plan.
    private func trialEligibility() async -> Bool {
        guard let yearly = products[ProductID.yearly]?.subscription else { return false }
        guard await yearly.isEligibleForIntroOffer else { return false }
        for await result in Transaction.all {
            if case .verified(let transaction) = result, ProductID.subscriptions.contains(transaction.productID) { return false }
        }
        return true
    }

    private func updateTrialReminder() {
        guard case .trial(let ends) = entitlement, activeRenewingProductID != nil,
              let price = products[ProductID.yearly]?.displayPrice else {
            trialReminders?.cancelTrialReminder()
            return
        }
        let timeline = TrialTimeline(start: ends.addingTimeInterval(-14 * 86_400), trialLength: 14, calendar: .current)
        trialReminders?.scheduleTrialReminder(at: timeline.reminderDate, billingDate: ends, price: price)
    }
}
