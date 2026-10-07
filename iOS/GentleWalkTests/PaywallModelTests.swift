import Foundation
import Testing
@testable import GentleWalk

/// Paywall words and dates (review M11, 02/10/2026).
@MainActor @Suite struct PaywallModelTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        calendar.locale = Locale(identifier: "en_US")
        return calendar
    }

    private func model(eligible: Bool, selected kind: PlanOption.Kind = .yearly) -> PaywallModel {
        let options = [PlanOption(id: "y", kind: .yearly, price: "$39.99", monthlyEquivalent: nil),
                       PlanOption(id: "m", kind: .monthly, price: "$7.99", monthlyEquivalent: nil)]
        let start = calendar.date(from: DateComponents(year: 2026, month: 10, day: 2, hour: 9))!
        let model = PaywallModel(options: options, isEligibleForTrial: eligible, now: start, calendar: calendar)
        model.selectedID = kind == .yearly ? "y" : "m"
        return model
    }

    @Test func trialButtonIsStartMyFreeTrial() {
        #expect(String(localized: model(eligible: true).buttonTitle) == "Start my free trial")
        #expect(String(localized: model(eligible: true, selected: .monthly).buttonTitle) == "Continue")
        #expect(String(localized: model(eligible: false).buttonTitle) == "Continue")
    }

    /// Owner S2: the badge follows the store prices, never typed in.
    @Test func lowestMonthlyComesFromThePrices() {
        #expect(PaywallModel.isLowestMonthly(yearlyPrice: 39.99, monthlyPrice: 7.99))
        #expect(!PaywallModel.isLowestMonthly(yearlyPrice: 120, monthlyPrice: 9.99))
    }

    @Test func reminderIsTwoDaysBeforeBilling() {
        let model = model(eligible: true)
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: model.trial.reminderDate),
                                           to: calendar.startOfDay(for: model.trial.billingDate)).day
        #expect(days == 2)
        #expect(model.reminderDateText == model.trial.reminderDate.formatted(.dateTime.month(.abbreviated).day()))
    }
}
