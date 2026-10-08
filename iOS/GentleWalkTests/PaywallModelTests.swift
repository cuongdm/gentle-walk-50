import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

/// Paywall words and dates (review M11, 02/10/2026) and the simple paywall (plan 08/10/2026 task 2.12:
/// the title says her goal back, Yearly alone until "See other plans").
@MainActor @Suite struct PaywallModelTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        calendar.locale = Locale(identifier: "en_US")
        return calendar
    }

    private var start: Date { calendar.date(from: DateComponents(year: 2026, month: 10, day: 2, hour: 9))! }

    private func model(eligible: Bool, trialDays: Int? = 14, selected kind: PlanOption.Kind = .yearly,
                       goal: Goal = .steadier) -> PaywallModel {
        let options = [PlanOption(id: "y", kind: .yearly, price: "$39.99", monthlyEquivalent: "$3.33 a month"),
                       PlanOption(id: "m", kind: .monthly, price: "$7.99", monthlyEquivalent: nil),
                       PlanOption(id: "l", kind: .lifetime, price: "$79.99", monthlyEquivalent: nil)]
        let model = PaywallModel(options: options, isEligibleForTrial: eligible, trialDays: trialDays, goal: goal,
                                 now: start, calendar: calendar)
        if kind != .yearly {
            model.showsAllPlans = true
            model.selectedID = kind == .monthly ? "m" : "l"
        }
        return model
    }

    @Test func buttonSaysWhatHappens() {
        #expect(String(localized: model(eligible: true).buttonTitle) == "Start my free trial")
        #expect(String(localized: model(eligible: true, selected: .monthly).buttonTitle) == "Subscribe for $7.99 a month")
        #expect(String(localized: model(eligible: false).buttonTitle) == "Subscribe for $39.99 a year")
        #expect(String(localized: model(eligible: true, selected: .lifetime).buttonTitle) == "Pay $79.99 once")
    }

    /// The title says her goal back; the free days only when the trial is offered.
    @Test func titleFollowsTheGoal() {
        #expect(String(localized: model(eligible: true).title) == "Your 12 weeks to feel steadier, free for 14 days")
        #expect(String(localized: model(eligible: false).title) == "Your 12 weeks to feel steadier")
        #expect(String(localized: model(eligible: true, goal: .chairs).title).hasPrefix("Your 12 weeks to get up from chairs"))
        // Every goal has its own title.
        let titles = Set(Goal.allCases.map { String(localized: PaywallModel.goalTitle($0)) })
        #expect(titles.count == Goal.allCases.count)
    }

    /// Yearly alone at first; "See other plans" shows all three; "Fewer plans" goes back to Yearly.
    @Test func otherPlansOpenInPlace() {
        let model = model(eligible: true)
        #expect(model.visibleOptions.map(\.kind) == [.yearly])
        #expect(model.showsTrial)
        model.showsAllPlans = true
        #expect(model.visibleOptions.map(\.kind) == [.yearly, .monthly, .lifetime])
        #expect(String(localized: model.title) == "Pick what suits you")
        model.selectedID = "m"
        #expect(!model.showsTrial)
        model.showsAllPlans = false
        #expect(model.selected?.kind == .yearly)
    }

    /// The terms under the button name the billed price, when, and how renewal works (3.1.2).
    @Test func disclosureNamesPriceAndRenewal() {
        #expect(model(eligible: true).disclosure.contains("$39.99 a year"))
        #expect(model(eligible: true).disclosure.contains("24 hours before renewal"))
        #expect(model(eligible: true, selected: .monthly).disclosure.hasPrefix("$7.99 every month"))
        #expect(model(eligible: true, selected: .lifetime).disclosure.contains("No renewals"))
    }

    /// 1.4.1: no health promises in the goal titles.
    @Test func titlesNeverPromiseHealth() {
        for goal in Goal.allCases {
            let title = String(localized: PaywallModel.goalTitle(goal)).lowercased()
            for banned in ["prevent", "fall", "pain relief", "cure", "treat", "lose weight"] {
                #expect(!title.contains(banned), "\(goal): \(title)")
            }
        }
    }

    @Test func reminderIsTwoDaysBeforeBilling() throws {
        let model = model(eligible: true)
        let trial = try #require(model.trial)
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: trial.reminderDate),
                                           to: calendar.startOfDay(for: trial.billingDate)).day
        #expect(days == 2)
        #expect(model.reminderDateText == trial.reminderDate.formatted(.dateTime.month(.abbreviated).day()))
    }

    // MARK: Trial length from StoreKit (review I-1, 08/10/2026)

    /// A one-week offer in App Store Connect: every phrase and date says 7 days, none says 14.
    @Test func trialLengthFollowsTheOffer() throws {
        let model = model(eligible: true, trialDays: 7)
        #expect(String(localized: model.title) == "Your 12 weeks to feel steadier, free for 7 days")
        #expect(model.disclosure.hasPrefix("Free for 7 days, then $39.99 a year."))
        let trial = try #require(model.trial)
        #expect(calendar.dateComponents([.day], from: start, to: trial.billingDate).day == 7)
        model.showsAllPlans = true
        let yearly = try #require(model.yearly)
        #expect(model.note(for: yearly) == "7 days free · $3.33 a month")
        for text in [String(localized: model.title), model.disclosure, model.note(for: yearly) ?? ""] {
            #expect(!text.contains("14"), "\(text)")
        }
    }

    /// No free-trial offer on the yearly plan: no trial title, timeline, free-days note or trial button.
    @Test func noOfferMeansNoTrial() throws {
        let model = model(eligible: true, trialDays: nil)
        #expect(!model.isEligibleForTrial)
        #expect(!model.showsTrial)
        #expect(model.trial == nil)
        #expect(String(localized: model.title) == "Your 12 weeks to feel steadier")
        #expect(String(localized: model.buttonTitle) == "Subscribe for $39.99 a year")
        #expect(model.disclosure.hasPrefix("$39.99 charged today"))
        model.showsAllPlans = true
        let yearly = try #require(model.yearly)
        #expect(model.note(for: yearly) == "$3.33 a month")
        let monthly = try #require(model.options.first { $0.kind == .monthly })
        #expect(model.note(for: monthly) == nil)
    }

    /// The 14-day offer in GentleWalk.storekit reads as it did before.
    @Test func fourteenDayOfferNotes() throws {
        let model = model(eligible: true)
        model.showsAllPlans = true
        let yearly = try #require(model.yearly)
        #expect(model.note(for: yearly) == "14 days free · $3.33 a month")
        let monthly = try #require(model.options.first { $0.kind == .monthly })
        #expect(model.note(for: monthly) == "No free days")
    }
}
