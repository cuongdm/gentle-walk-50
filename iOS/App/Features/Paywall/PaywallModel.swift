import Foundation
import Observation
import StoreKit
import GentleWalkCore

/// One plan card on S08. Every price and period comes from `Product` (3.1.2(c)); screenshots pass
/// the same shape filled from the local StoreKit file.
struct PlanOption: Identifiable, Equatable, Sendable {
    enum Kind: Equatable, Sendable { case yearly, monthly, lifetime }

    var id: String
    var kind: Kind
    /// Billed amount, e.g. "$39.99". Always the most prominent price on the card.
    var price: String
    /// "$3.33 a month", yearly only, smaller than the price.
    var monthlyEquivalent: String?
    /// "Lowest monthly cost" on the yearly card, only when the store prices make it true
    /// (owner S2, 02/10/2026, past the "no hype" copy rule).
    var isLowestMonthly = false

    var title: LocalizedStringResource {
        switch kind {
        case .yearly: "Yearly"
        case .monthly: "Monthly"
        case .lifetime: "One payment"
        }
    }

    /// "$39.99 a year" · "$7.99 a month" · "$79.99 once".
    var priceWithPeriod: String {
        switch kind {
        case .yearly: String(localized: "\(price) a year")
        case .monthly: String(localized: "\(price) a month")
        case .lifetime: String(localized: "\(price) once")
        }
    }
}

/// S08 Paywall (tasks 5.9, 5.10): which plan is chosen, the trial timeline, button title and the
/// disclosure under it. Yearly with a trial is chosen first; one payment is last and never chosen first.
@Observable @MainActor final class PaywallModel {
    private(set) var options: [PlanOption]
    var selectedID: String
    let isEligibleForTrial: Bool
    /// A renewing plan the user already has: the one-payment card warns it keeps renewing (I2).
    let activeRenewingProductID: String?
    let trial: TrialTimeline

    init(options: [PlanOption], isEligibleForTrial: Bool, activeRenewingProductID: String? = nil,
         now: Date = .now, calendar: Calendar = .current) {
        self.options = options
        self.isEligibleForTrial = isEligibleForTrial
        self.activeRenewingProductID = activeRenewingProductID
        selectedID = options.first { $0.kind == .yearly }?.id ?? options.first?.id ?? ""
        trial = TrialTimeline(start: now, trialLength: 14, calendar: calendar)
    }

    var selected: PlanOption? { options.first { $0.id == selectedID } }
    var yearly: PlanOption? { options.first { $0.kind == .yearly } }

    /// The trial timeline shows only for the yearly plan when the trial is offered.
    var showsTrial: Bool { isEligibleForTrial && selected?.kind == .yearly }

    var title: LocalizedStringResource {
        // Names Pro, so the "Pro" badges elsewhere connect to this screen (clarity review D4).
        isEligibleForTrial ? "Gentle Walk Pro: free for 14 days" : "Gentle Walk Pro"
    }

    /// "Start my free trial": a beginning she owns, not a subscription (uxpeak A/B, review M11).
    var buttonTitle: LocalizedStringResource { showsTrial ? "Start my free trial" : "Continue" }

    var billingDateText: String { trial.billingDate.formatted(.dateTime.month(.abbreviated).day()) }

    /// The day the trial reminder is sent, as a date like the billing day.
    var reminderDateText: String { trial.reminderDate.formatted(.dateTime.month(.abbreviated).day()) }

    /// Plain terms under the button: what is charged, when, and that it renews (3.1.2(c)).
    var disclosure: String {
        guard let selected else { return "" }
        let renewal = String(localized: "Renews automatically unless you cancel at least 24 hours before the renewal date.")
        switch selected.kind {
        case .yearly where showsTrial:
            return String(localized: "Free for 14 days, then \(selected.price) a year from \(billingDateText). \(renewal)")
        case .yearly:
            return String(localized: "\(selected.price) charged today, then every year. \(renewal)")
        case .monthly:
            return String(localized: "\(selected.price) charged today, then every month. \(renewal)")
        case .lifetime:
            return String(localized: "\(selected.price) charged today, one time. No renewals.")
        }
    }

    var showsRenewingWarning: Bool { activeRenewingProductID != nil }

    /// Builds cards from StoreKit products (price text from `displayPrice`, never typed in code).
    /// The yearly plan costs less per month than the monthly plan.
    static func isLowestMonthly(yearlyPrice: Decimal, monthlyPrice: Decimal) -> Bool {
        yearlyPrice / 12 < monthlyPrice
    }

    static func options(from products: [String: Product]) -> [PlanOption] {
        var result: [PlanOption] = []
        if let yearly = products[ProductID.yearly] {
            let monthly = (yearly.price / 12).formatted(yearly.priceFormatStyle)
            let lowest = products[ProductID.monthly].map { isLowestMonthly(yearlyPrice: yearly.price, monthlyPrice: $0.price) } ?? false
            result.append(PlanOption(id: yearly.id, kind: .yearly, price: yearly.displayPrice,
                                     monthlyEquivalent: String(localized: "\(monthly) a month"), isLowestMonthly: lowest))
        }
        if let monthly = products[ProductID.monthly] {
            result.append(PlanOption(id: monthly.id, kind: .monthly, price: monthly.displayPrice))
        }
        if let lifetime = products[ProductID.lifetime] {
            result.append(PlanOption(id: lifetime.id, kind: .lifetime, price: lifetime.displayPrice))
        }
        return result
    }
}

/// Links on every purchase screen (3.1.2). Terms: Apple's standard EULA until the owner decides
/// otherwise (task 5.10 default). Privacy: shown in the app; the web copy comes with task 9.1.
enum LegalLinks {
    static let termsOfUse = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    static let supportEmail = "cuongdm@live.com"
    static let contactUs = URL(string: "mailto:\(supportEmail)")!
}
