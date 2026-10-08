import Foundation

/// The "pro" entitlement as the purchase layer reports it (RevenueCat `EntitlementInfo` in the app).
public struct ProAccess: Equatable, Sendable {
    /// The product that grants it now; the one-time purchase when she has both.
    public var productID: String
    public var isActive: Bool
    /// Inside the yearly plan's free trial.
    public var isTrial: Bool
    /// End of the trial or paid period (the first billing date in a trial); nil for the one-time purchase.
    public var expirationDate: Date?
    public var willRenew: Bool

    public init(productID: String, isActive: Bool, isTrial: Bool, expirationDate: Date?, willRenew: Bool) {
        self.productID = productID; self.isActive = isActive; self.isTrial = isTrial
        self.expirationDate = expirationDate; self.willRenew = willRenew
    }
}

/// One auto-renewing plan she has bought, active or not (RevenueCat `SubscriptionInfo`).
public struct SubscriptionState: Equatable, Sendable {
    public var productID: String
    public var isActive: Bool
    public var willRenew: Bool
    public var expiresDate: Date?

    public init(productID: String, isActive: Bool, willRenew: Bool, expiresDate: Date?) {
        self.productID = productID; self.isActive = isActive; self.willRenew = willRenew; self.expiresDate = expiresDate
    }
}

/// The parts of the purchase layer's customer record the rules need (RevenueCat `CustomerInfo`, mapped
/// in the app; the core stays Foundation only). Anonymous: no name, email or account.
public struct CustomerSnapshot: Equatable, Sendable {
    /// The "pro" entitlement; nil when she never had it.
    public var pro: ProAccess?
    /// Every subscription she has bought, so a lifetime buyer whose yearly plan still renews is warned.
    public var subscriptions: [SubscriptionState]
    /// Every product ever bought, for the once-per-group free trial.
    public var purchasedProductIDs: Set<String>

    public init(pro: ProAccess?, subscriptions: [SubscriptionState], purchasedProductIDs: Set<String>) {
        self.pro = pro; self.subscriptions = subscriptions; self.purchasedProductIDs = purchasedProductIDs
    }

    /// No purchase layer (no key, offline at first launch) or nothing bought yet.
    public static let empty = CustomerSnapshot(pro: nil, subscriptions: [], purchasedProductIDs: [])
}

/// The store's answer to "would the free trial apply?" (RevenueCat `IntroEligibilityStatus`).
public enum IntroEligibility: Sendable, Equatable { case eligible, ineligible, noOffer, unknown }

/// Pro, the renewing plan and the trial offer from the customer record (owner 09/10/2026: RevenueCat
/// entitlement "pro" is the source of truth). Lifetime wins; an ended period never counts, even when an
/// old cached record still says active.
public enum CustomerRules {
    public static func entitlement(_ customer: CustomerSnapshot, now: Date) -> Entitlement {
        guard let pro = customer.pro, pro.isActive else { return .free }
        guard let ends = pro.expirationDate else { return .lifetime }
        if pro.productID == ProductID.lifetime { return .lifetime }
        guard ends > now else { return .free }
        return pro.isTrial ? .trial(ends: ends) : .subscribed
    }

    /// A plan that will charge again, and when.
    public struct Renewal: Equatable, Sendable {
        public var productID: String
        public var date: Date?

        public init(productID: String, date: Date?) { self.productID = productID; self.date = date }
    }

    /// The yearly or monthly plan that renews (set even beside lifetime, I2); nil when nothing renews.
    public static func renewal(_ customer: CustomerSnapshot, now: Date) -> Renewal? {
        let renewing = customer.subscriptions.filter { plan in
            plan.isActive && plan.willRenew && (plan.expiresDate.map { $0 > now } ?? false)
        }
        if let plan = renewing.max(by: { ($0.expiresDate ?? .distantPast) < ($1.expiresDate ?? .distantPast) }) {
            return Renewal(productID: plan.productID, date: plan.expiresDate)
        }
        // Right after a purchase the subscription list can lag behind the entitlement.
        if let pro = customer.pro, pro.isActive, pro.willRenew, pro.productID != ProductID.lifetime,
           let ends = pro.expirationDate, ends > now {
            return Renewal(productID: pro.productID, date: ends)
        }
        return nil
    }

    /// The free trial is offered once per subscription group: a free-trial offer on the yearly plan, the
    /// store's yes (or no answer and no history), and no earlier plan.
    public static func isEligibleForTrial(_ customer: CustomerSnapshot, trialDays: Int?, store: IntroEligibility) -> Bool {
        guard trialDays != nil else { return false }
        let hadPlan = !customer.subscriptions.isEmpty || !customer.purchasedProductIDs.isDisjoint(with: ProductID.subscriptions)
        switch store {
        case .eligible, .unknown: return !hadPlan
        case .ineligible, .noOffer: return false
        }
    }
}
