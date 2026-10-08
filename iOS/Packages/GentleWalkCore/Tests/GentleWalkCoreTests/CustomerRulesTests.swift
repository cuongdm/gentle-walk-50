import Foundation
import Testing
@testable import GentleWalkCore

/// Entitlement, renewal and trial eligibility from the purchase layer's customer record (RevenueCat
/// `CustomerInfo` in the app; owner 09/10/2026). Replaces the rules over StoreKit transactions.
@Suite struct CustomerRulesTests {
    static let now = TestSupport.date("2026-10-01T12:00:00Z")
    static let later = TestSupport.date("2026-10-15T12:00:00Z")
    static let earlier = TestSupport.date("2026-09-20T12:00:00Z")

    static func pro(_ productID: String = ProductID.yearly, active: Bool = true, trial: Bool = false,
                    expires: Date? = later, willRenew: Bool = true) -> ProAccess {
        ProAccess(productID: productID, isActive: active, isTrial: trial, expirationDate: expires, willRenew: willRenew)
    }

    static func subscription(_ productID: String = ProductID.yearly, active: Bool = true, willRenew: Bool = true,
                             expires: Date? = later) -> SubscriptionState {
        SubscriptionState(productID: productID, isActive: active, willRenew: willRenew, expiresDate: expires)
    }

    static func customer(_ pro: ProAccess?, _ subscriptions: [SubscriptionState] = [],
                         purchased: Set<String> = []) -> CustomerSnapshot {
        CustomerSnapshot(pro: pro, subscriptions: subscriptions, purchasedProductIDs: purchased)
    }

    // MARK: Entitlement

    static let cases: [(CustomerSnapshot, Entitlement)] = [
        (.empty, .free),
        // Yearly inside its free trial: Pro until the first billing date.
        (customer(pro(trial: true)), .trial(ends: later)),
        (customer(pro()), .subscribed),
        (customer(pro(ProductID.monthly)), .subscribed),
        // One payment: no expiry, wins over a running trial (the entitlement points at it).
        (customer(pro(ProductID.lifetime, expires: nil, willRenew: false)), .lifetime),
        // Refunded or expired: the entitlement is no longer active.
        (customer(pro(active: false)), .free),
        (customer(pro(ProductID.lifetime, active: false, expires: nil, willRenew: false)), .free),
        // A stale "active" record whose period has already ended (offline, old cache) never counts.
        (customer(pro(expires: earlier)), .free),
        (customer(pro(trial: true, expires: earlier)), .free),
        // Cancelled but still inside the paid period: Pro until it ends.
        (customer(pro(willRenew: false)), .subscribed),
    ]

    @Test(arguments: cases)
    func entitlement(_ customer: CustomerSnapshot, _ expected: Entitlement) {
        #expect(CustomerRules.entitlement(customer, now: Self.now) == expected)
    }

    // MARK: Renewal (Me, the trial reminder, the 3.1.2 warning on One payment)

    @Test func renewingPlanAndDate() {
        let renewal = CustomerRules.renewal(Self.customer(Self.pro(), [Self.subscription()]), now: Self.now)
        #expect(renewal == CustomerRules.Renewal(productID: ProductID.yearly, date: Self.later))
    }

    /// Lifetime bought while the yearly plan still renews: the entitlement shows lifetime, the
    /// subscription list still shows the plan that keeps charging (I2).
    @Test func lifetimeWhileSubscribedStillReportsTheRenewingPlan() {
        let customer = Self.customer(Self.pro(ProductID.lifetime, expires: nil, willRenew: false), [Self.subscription()],
                                     purchased: [ProductID.yearly, ProductID.lifetime])
        #expect(CustomerRules.entitlement(customer, now: Self.now) == .lifetime)
        #expect(CustomerRules.renewal(customer, now: Self.now)?.productID == ProductID.yearly)
    }

    @Test func noRenewalWhenAutoRenewIsOffOrExpired() {
        #expect(CustomerRules.renewal(Self.customer(Self.pro(willRenew: false), [Self.subscription(willRenew: false)]),
                                      now: Self.now) == nil)
        #expect(CustomerRules.renewal(Self.customer(nil, [Self.subscription(active: false, expires: Self.earlier)]),
                                      now: Self.now) == nil)
        #expect(CustomerRules.renewal(Self.customer(nil, [Self.subscription(expires: Self.earlier)]), now: Self.now) == nil)
        #expect(CustomerRules.renewal(.empty, now: Self.now) == nil)
    }

    /// Right after a purchase the subscription list can lag behind the entitlement: a renewing
    /// subscription entitlement still names its plan and date.
    @Test func renewalFallsBackToTheEntitlement() {
        let renewal = CustomerRules.renewal(Self.customer(Self.pro(ProductID.monthly)), now: Self.now)
        #expect(renewal == CustomerRules.Renewal(productID: ProductID.monthly, date: Self.later))
        #expect(CustomerRules.renewal(Self.customer(Self.pro(ProductID.lifetime, expires: nil, willRenew: false)),
                                      now: Self.now) == nil)
    }

    // MARK: Trial eligibility (once per subscription group, only with a free-trial offer)

    @Test func trialNeedsAnOfferAndTheStoresYes() {
        #expect(CustomerRules.isEligibleForTrial(.empty, trialDays: 14, store: .eligible))
        #expect(!CustomerRules.isEligibleForTrial(.empty, trialDays: nil, store: .eligible))
        #expect(!CustomerRules.isEligibleForTrial(.empty, trialDays: 14, store: .ineligible))
        #expect(!CustomerRules.isEligibleForTrial(.empty, trialDays: 14, store: .noOffer))
    }

    /// An earlier plan in the group means no second trial, whatever the store answered.
    @Test func anEarlierPlanEndsTheTrialOffer() {
        let lapsed = Self.customer(nil, [Self.subscription(active: false, willRenew: false, expires: Self.earlier)],
                                   purchased: [ProductID.yearly])
        #expect(!CustomerRules.isEligibleForTrial(lapsed, trialDays: 14, store: .eligible))
        #expect(!CustomerRules.isEligibleForTrial(lapsed, trialDays: 14, store: .unknown))
        let monthlyOnly = Self.customer(nil, purchased: [ProductID.monthly])
        #expect(!CustomerRules.isEligibleForTrial(monthlyOnly, trialDays: 14, store: .unknown))
    }

    /// The store could not tell: a customer with no plan history gets the trial, as the App Store will.
    @Test func unknownAnswerFollowsTheHistory() {
        #expect(CustomerRules.isEligibleForTrial(.empty, trialDays: 14, store: .unknown))
        let lifetimeOnly = Self.customer(nil, purchased: [ProductID.lifetime])
        #expect(CustomerRules.isEligibleForTrial(lifetimeOnly, trialDays: 14, store: .unknown))
    }
}
