import Foundation
import Testing
@testable import GentleWalkCore

/// The trial length comes from the App Store offer, not from the code (review I-1, 08/10/2026).
@Suite struct TrialOfferTests {
    @Test func periodsBecomeDays() {
        #expect(TrialOffer.days(value: 3, unit: .day) == 3)
        #expect(TrialOffer.days(value: 1, unit: .week) == 7)
        #expect(TrialOffer.days(value: 2, unit: .week) == 14)
        #expect(TrialOffer.days(value: 1, unit: .month) == 30)
        #expect(TrialOffer.days(value: 1, unit: .year) == 365)
    }

    @Test func anEmptyPeriodIsNoTrial() {
        for unit in TrialOffer.Unit.allCases {
            #expect(TrialOffer.days(value: 0, unit: unit) == nil)
        }
    }

    /// The reminder worked out from the billing date matches the one from the start of the trial.
    @Test func timelineFromTheBillingDate() {
        let cal = TestSupport.newYork
        let start = TestSupport.local(cal, 2026, 10, 2, 9, 0)
        let fromStart = TrialTimeline(start: start, trialLength: 7, calendar: cal)
        let fromBilling = TrialTimeline(billingDate: fromStart.billingDate, trialLength: 7, calendar: cal)
        #expect(fromBilling == fromStart)
        #expect(cal.dateComponents([.month, .day, .hour], from: fromBilling.reminderDate) == DateComponents(month: 10, day: 7, hour: 10))
    }
}
