import Foundation
import Observation
import GentleWalkCore

/// One plan card on S08. Every price and period comes from the store (`StoreOffer`, 3.1.2(c));
/// screenshots pass the same shape filled from the local StoreKit file's prices.
struct PlanOption: Identifiable, Equatable, Sendable {
    typealias Kind = PlanKind

    var id: String
    var kind: Kind
    /// Billed amount, e.g. "$49.99". Always the most prominent price on the card.
    var price: String
    /// "$4.17 a month", yearly only, smaller than the price.
    var monthlyEquivalent: String?

    var title: LocalizedStringResource {
        switch kind {
        case .yearly: "Yearly"
        case .monthly: "Monthly"
        case .lifetime: "One payment"
        }
    }

    /// "$49.99 a year" · "$9.99 a month" · "$99.99 once".
    var priceWithPeriod: String {
        switch kind {
        case .yearly: String(localized: "\(price) a year")
        case .monthly: String(localized: "\(price) a month")
        case .lifetime: String(localized: "\(price) once")
        }
    }
}

/// S08 Paywall (tasks 5.9, 5.10; simple paywall, plan 08/10/2026 task 2.12): which plan is chosen, the
/// title that says her goal back, the trial timeline, the button and the terms under it. Yearly shows
/// alone, chosen; "See other plans" opens Monthly and One payment in place. One payment is never
/// chosen first.
@Observable @MainActor final class PaywallModel {
    private(set) var options: [PlanOption]
    var selectedID: String
    /// The store's eligibility and a free-trial offer on the yearly plan: without an offer there is no trial.
    let isEligibleForTrial: Bool
    /// Free days of the yearly plan's introductory offer, from the store (review I-1, 08/10/2026); nil
    /// when the yearly plan has no free-trial offer.
    let trialDays: Int?
    /// A renewing plan the user already has: the one-payment card warns it keeps renewing (I2).
    let activeRenewingProductID: String?
    /// Today → reminder → first charge, for the offered trial length; nil when there is no trial.
    let trial: TrialTimeline?
    /// Her main goal from onboarding (owner 08/10/2026: one goal, said back on the paywall).
    let goal: Goal
    /// "See other plans" opened. Closing it ("Fewer plans") goes back to Yearly, the only plan then shown.
    var showsAllPlans = false {
        didSet { if !showsAllPlans, let yearly { selectedID = yearly.id } }
    }

    init(options: [PlanOption], isEligibleForTrial: Bool, trialDays: Int?, activeRenewingProductID: String? = nil,
         goal: Goal = .notSure, now: Date = .now, calendar: Calendar = .current) {
        self.options = options
        self.trialDays = trialDays
        self.isEligibleForTrial = isEligibleForTrial && trialDays != nil
        self.activeRenewingProductID = activeRenewingProductID
        self.goal = goal
        selectedID = options.first { $0.kind == .yearly }?.id ?? options.first?.id ?? ""
        trial = trialDays.map { TrialTimeline(start: now, trialLength: $0, calendar: calendar) }
        // No yearly plan in the store: show every plan there is.
        if options.first(where: { $0.kind == .yearly }) == nil { showsAllPlans = true }
    }

    var selected: PlanOption? { options.first { $0.id == selectedID } }
    var yearly: PlanOption? { options.first { $0.kind == .yearly } }

    /// Yearly alone until "See other plans".
    var visibleOptions: [PlanOption] { showsAllPlans ? options : options.filter { $0.kind == .yearly } }

    /// The trial timeline shows only for the yearly plan when the trial is offered.
    var showsTrial: Bool { isEligibleForTrial && selected?.kind == .yearly }

    /// "Your 12 weeks to feel steadier, free for 14 days"; "Pick what suits you" over all three plans.
    var title: LocalizedStringResource {
        if showsAllPlans { return "Pick what suits you" }
        guard isEligibleForTrial, let trialDays else { return Self.goalTitle(goal) }
        return "\(String(localized: Self.goalTitle(goal))), free for \(trialDays) days"
    }

    /// Her goal said back as the 12 weeks (no health promise: 1.4.1, steady-claims.md).
    static func goalTitle(_ goal: Goal) -> LocalizedStringResource {
        switch goal {
        case .steadier: "Your 12 weeks to feel steadier"
        case .chairs: "Your 12 weeks to get up from chairs more easily"
        case .lessPain: "Your 12 weeks of gentle, seated-first moves"
        case .moreEnergy: "Your 12 weeks to get moving every day"
        case .grandkids: "Your 12 weeks to keep up with the grandkids"
        case .loseWeight: "Your 12 weeks of short daily walks"
        case .notSure: "Your 12 weeks, at your own pace"
        }
    }

    /// "Start my free trial": a beginning she owns (uxpeak A/B, review M11); otherwise the button names
    /// the plan and its billed price ("Subscribe for $9.99 a month").
    var buttonTitle: LocalizedStringResource {
        guard let selected else { return "Continue" }
        switch selected.kind {
        case .yearly where showsTrial: return "Start my free trial"
        case .yearly: return "Subscribe for \(selected.price) a year"
        case .monthly: return "Subscribe for \(selected.price) a month"
        case .lifetime: return "Pay \(selected.price) once"
        }
    }

    var billingDateText: String { trial?.billingDate.formatted(.dateTime.month(.abbreviated).day()) ?? "" }

    /// The day the trial reminder is sent, as a date like the billing day.
    var reminderDateText: String { trial?.reminderDate.formatted(.dateTime.month(.abbreviated).day()) ?? "" }

    /// Plain terms under the button: what is charged, when, and that it renews until she cancels at
    /// least 24 hours before (3.1.2(c)).
    var disclosure: String {
        guard let selected else { return "" }
        switch selected.kind {
        case .yearly where showsTrial:
            let days = trialDays ?? 0
            return String(localized: "Free for \(days) days, then \(selected.price) a year. Renews until you cancel, at least 24 hours before renewal.")
        case .yearly:
            return String(localized: "\(selected.price) charged today, then every year. Renews until you cancel, at least 24 hours before renewal.")
        case .monthly:
            return String(localized: "\(selected.price) every month. Renews until you cancel, at least 24 hours before renewal.")
        case .lifetime:
            return String(localized: "\(selected.price) charged today, one time. No renewals.")
        }
    }

    var showsRenewingWarning: Bool { activeRenewingProductID != nil }

    /// The small line under a plan's name: the free days and monthly cost on Yearly, "No free days" on
    /// Monthly while the trial is on offer, "Yours to keep, no renewals" on One payment.
    func note(for option: PlanOption) -> String? {
        switch option.kind {
        case .yearly:
            let monthly = option.monthlyEquivalent
            guard isEligibleForTrial, showsAllPlans, let days = trialDays else { return monthly }
            return monthly.map { String(localized: "\(days) days free · \($0)") } ?? String(localized: "\(days) days free")
        case .monthly: return isEligibleForTrial ? String(localized: "No free days") : nil
        case .lifetime: return String(localized: "Yours to keep, no renewals")
        }
    }

    /// Builds cards from the store's plans (price text from the store, never typed in code). The yearly
    /// card's "$4.17 a month" is its real billed price divided by 12, in the same currency.
    static func options(from offers: [StoreOffer], locale: Locale = .autoupdatingCurrent) -> [PlanOption] {
        offers.sorted { $0.kind < $1.kind }.map { offer in
            var monthly: String?
            if offer.kind == .yearly, let perMonth = monthlyPrice(of: offer, locale: locale) {
                monthly = String(localized: "\(perMonth) a month")
            }
            return PlanOption(id: offer.id, kind: offer.kind, price: offer.displayPrice, monthlyEquivalent: monthly)
        }
    }

    /// A twelfth of the yearly price, rounded to the cent like the store rounds prices; nil without a currency.
    static func monthlyPrice(of offer: StoreOffer, locale: Locale) -> String? {
        guard let code = offer.currencyCode else { return nil }
        return (offer.price / 12).formatted(.currency(code: code).locale(locale))
    }
}

/// Links on every purchase screen (3.1.2). Terms: Apple's standard EULA until the owner decides
/// otherwise (task 5.10 default). Privacy: shown in the app; the web copy comes with task 9.1.
enum LegalLinks {
    static let termsOfUse = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    static let supportEmail = "cuongdm@live.com"
    static let contactUs = URL(string: "mailto:\(supportEmail)")!
}
