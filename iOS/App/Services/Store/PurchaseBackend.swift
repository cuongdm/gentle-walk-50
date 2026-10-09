import Foundation
import GentleWalkCore

/// The three ways to pay for Pro, in the order the paywall lists them.
enum PlanKind: Int, CaseIterable, Comparable, Sendable {
    case yearly, monthly, lifetime

    static func < (lhs: PlanKind, rhs: PlanKind) -> Bool { lhs.rawValue < rhs.rawValue }

    /// The plan a product ID stands for, when the store gives no package type.
    init?(productID: String) {
        switch productID {
        case ProductID.yearly: self = .yearly
        case ProductID.monthly: self = .monthly
        case ProductID.lifetime: self = .lifetime
        default: return nil
        }
    }
}

/// One plan on sale, as the store prices it (3.1.2(c): never typed in code).
struct StoreOffer: Identifiable, Equatable, Sendable {
    /// The App Store product ID.
    var id: String
    var kind: PlanKind
    /// The billed amount the store formats for her storefront, e.g. "$49.99".
    var displayPrice: String
    var price: Decimal
    /// ISO 4217 code of `price` (nil only when the store gives none).
    var currencyCode: String?
    /// Days of a free-trial introductory offer (review I-1); nil without one.
    var freeTrialDays: Int?
}

/// What a purchase did, before the screens are rebuilt.
enum BackendPurchase: Equatable, Sendable {
    case purchased(CustomerSnapshot)
    /// Ask to Buy or a bank check: it starts once approved (the update stream brings it).
    case pending
    case cancelled
}

/// A purchase that did not go through, sorted by what the paywall can truthfully say about it (owner
/// report 09/10/2026: TestFlight showed Apple's "This item is not available." and the app then said
/// "check your connection").
struct PurchaseFailure: Error, Equatable, Sendable {
    enum Reason: Equatable, Sendable {
        /// The store won't sell this plan here or now: not on sale in her App Store country, taken off sale,
        /// or not yet live (RevenueCat `productNotAvailableForPurchaseError`, from StoreKit's
        /// `notAvailableInStorefront` or `Product.PurchaseError.productUnavailable`).
        case planUnavailable
        /// No connection to the App Store or to the purchase service.
        case network
        /// Anything else the store reported (`storeProblemError`, purchases turned off, …).
        case other
    }

    var reason: Reason
    /// For the log only: the purchase layer's code and the store error under it. Never her data.
    var code: String
}

/// The purchase layer behind `StoreService` (owner 09/10/2026): RevenueCat in the app
/// (`RevenueCatBackend`, the only file that imports it), a fake in unit tests, so no test hits the network.
@MainActor protocol PurchaseBackend: AnyObject {
    /// The plans on sale; a plan the store does not have is left out. Throws when it sells none.
    /// - Parameter refresh: read past the cache (after the store said a plan can't be bought).
    func offers(refresh: Bool) async throws -> [StoreOffer]
    /// The customer record (the last one known when offline).
    func customer() async throws -> CustomerSnapshot
    /// Changes pushed by the store: renewals, refunds, expiry, purchases made elsewhere.
    func customerUpdates() -> AsyncStream<CustomerSnapshot>
    /// Throws `PurchaseFailure` when the purchase did not go through (cancelled and pending are results).
    func purchase(_ productID: String) async throws -> BackendPurchase
    /// Restore purchases: asks the App Store for her purchases, then returns the record.
    func restore() async throws -> CustomerSnapshot
    /// Whether the introductory offer of a subscription would apply to her.
    func introEligibility(for productID: String) async -> IntroEligibility
}
