import Foundation
import Observation
import GentleWalkCore

/// Schedules the "trial ends" notification (always sent, task 5.12); the notification service does it.
@MainActor protocol TrialReminderScheduling: AnyObject {
    func scheduleTrialReminder(at date: Date, billingDate: Date, price: String)
    func cancelTrialReminder()
}

enum PurchaseOutcome: Equatable, Sendable { case purchased, pending, cancelled }

enum StoreError: Error {
    /// No purchase layer: no RevenueCat key in this build, or a unit test.
    case unavailable
    case productUnavailable
}

/// Purchases in one place (task 5.8; RevenueCat since 09/10/2026). The source of truth is the "pro"
/// entitlement of the customer record (`CustomerRules`), read at launch, after a purchase or restore, and
/// on every change the purchase layer pushes. Without a purchase layer the app is simply free.
@Observable @MainActor final class StoreService {
    /// The plans on sale, yearly first; empty until loaded, or when the store cannot be reached.
    private(set) var offers: [StoreOffer] = []
    private(set) var entitlement: Entitlement = .free
    /// A yearly or monthly plan that will renew. Set even with lifetime, so Me and the paywall can
    /// warn that it keeps renewing until cancelled (I2).
    private(set) var activeRenewingProductID: String?
    private(set) var renewalDate: Date?
    private(set) var isEligibleForTrial = false
    /// Free days of the yearly plan's introductory offer as App Store Connect sets it (review I-1,
    /// 08/10/2026); nil when the yearly plan has no free-trial offer, which means no trial anywhere.
    private(set) var trialDays: Int?

    @ObservationIgnored private let backend: PurchaseBackend?
    @ObservationIgnored private weak var trialReminders: TrialReminderScheduling?
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private var updates: Task<Void, Never>?
    @ObservationIgnored private var introEligibility: IntroEligibility = .unknown
    /// Called after a pushed change was applied (refund, Ask to Buy, renewal, expiry), so the screens
    /// built from the entitlement are rebuilt.
    @ObservationIgnored var onUpdate: (() -> Void)?

    /// - Parameters:
    ///   - backend: RevenueCat in the app (`RevenueCatBackend.configured()`); nil = no store, free plan.
    ///   - now: the clock an ended period is measured against.
    init(backend: PurchaseBackend?, trialReminders: TrialReminderScheduling? = nil, now: @escaping () -> Date = Date.init) {
        self.backend = backend
        self.trialReminders = trialReminders
        self.now = now
    }

    /// False when this build has no purchase layer: the paywall shows "Plans aren't available right now".
    var isAvailable: Bool { backend != nil }

    func offer(_ kind: PlanKind) -> StoreOffer? { offers.first { $0.kind == kind } }

    func setTrialReminders(_ scheduler: TrialReminderScheduling?) { trialReminders = scheduler }

    /// Listens for renewals, refunds, expiry and purchases made elsewhere. Call once at launch.
    func startListening() {
        guard updates == nil, let backend else { return }
        let stream = backend.customerUpdates()
        updates = Task { [weak self] in
            for await customer in stream {
                guard let self else { return }
                apply(customer)
                onUpdate?()
            }
        }
    }

    func loadProducts() async throws {
        guard let backend else { throw StoreError.unavailable }
        let list = try await backend.offers()
        offers = list.sorted { $0.kind < $1.kind }
        let yearly = offer(.yearly)
        trialDays = yearly?.freeTrialDays
        if let yearly, yearly.freeTrialDays != nil {
            introEligibility = await backend.introEligibility(for: yearly.id)
        } else {
            introEligibility = .noOffer
        }
        await refresh()
    }

    func purchase(_ productID: String) async throws -> PurchaseOutcome {
        guard let backend else { throw StoreError.unavailable }
        guard offers.contains(where: { $0.id == productID }) else { throw StoreError.productUnavailable }
        switch try await backend.purchase(productID) {
        case .purchased(let customer):
            apply(customer)
            return .purchased
        case .pending:
            return .pending
        case .cancelled:
            return .cancelled
        }
    }

    /// Restore purchase: the purchase layer asks the App Store, then the record is re-read.
    func restore() async throws {
        guard let backend else { throw StoreError.unavailable }
        apply(try await backend.restore())
    }

    /// Re-reads the customer record. Offline with nothing cached: what the app already knew stays.
    func refresh() async {
        guard let backend, let customer = try? await backend.customer() else { return }
        apply(customer)
    }

    /// Everything the screens read comes from one record at one moment.
    private func apply(_ customer: CustomerSnapshot) {
        let now = now()
        entitlement = CustomerRules.entitlement(customer, now: now)
        let renewal = CustomerRules.renewal(customer, now: now)
        activeRenewingProductID = renewal?.productID
        renewalDate = renewal?.date
        isEligibleForTrial = CustomerRules.isEligibleForTrial(customer, trialDays: trialDays, store: introEligibility)
        updateTrialReminder()
    }

    private func updateTrialReminder() {
        guard case .trial(let ends) = entitlement, activeRenewingProductID != nil,
              let price = offer(.yearly)?.displayPrice else {
            trialReminders?.cancelTrialReminder()
            return
        }
        // The reminder is counted back from the billing date, so a trial already running still gets it
        // if the offer has since been removed from the store (its length then does not matter).
        let length = trialDays ?? TrialTimeline.reminderDaysBefore
        let timeline = TrialTimeline(billingDate: ends, trialLength: length, calendar: .current)
        trialReminders?.scheduleTrialReminder(at: timeline.reminderDate, billingDate: ends, price: price)
    }
}
