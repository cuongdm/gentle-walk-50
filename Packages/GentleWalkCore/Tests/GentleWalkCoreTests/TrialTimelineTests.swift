import Foundation
import Testing
@testable import GentleWalkCore

@Suite struct TrialTimelineTests {
    @Test(arguments: ["America/New_York", "Asia/Ho_Chi_Minh"])
    func billingIsFourteenDaysLaterAndTheReminderComesOnDayTwelveAtTen(_ zone: String) {
        let cal = TestSupport.calendar(zone)
        let trial = TrialTimeline(start: TestSupport.local(cal, 2026, 9, 27, 19, 45), trialLength: 14, calendar: cal)
        let billing = cal.dateComponents([.year, .month, .day], from: trial.billingDate)
        #expect(billing == DateComponents(year: 2026, month: 10, day: 11))
        let reminder = cal.dateComponents([.month, .day, .hour, .minute], from: trial.reminderDate)
        #expect(reminder == DateComponents(month: 10, day: 9, hour: 10, minute: 0))
    }

    @Test func daylightSavingChangeKeepsTheLocalDayAndTime() {
        let cal = TestSupport.newYork  // clocks go back on Nov 1, 2026
        let trial = TrialTimeline(start: TestSupport.local(cal, 2026, 10, 20, 9, 0), trialLength: 14, calendar: cal)
        #expect(cal.dateComponents([.month, .day, .hour], from: trial.billingDate) == DateComponents(month: 11, day: 3, hour: 9))
        #expect(cal.dateComponents([.month, .day, .hour], from: trial.reminderDate) == DateComponents(month: 11, day: 1, hour: 10))
    }

    @Test func bannerShowsFromDayTen() {
        let cal = TestSupport.newYork
        let start = TestSupport.local(cal, 2026, 9, 27, 19, 45)
        let trial = TrialTimeline(start: start, trialLength: 14, calendar: cal)
        #expect(!trial.bannerWindow.contains(TestSupport.local(cal, 2026, 10, 6, 23, 59)))
        #expect(trial.bannerWindow.contains(TestSupport.local(cal, 2026, 10, 7, 0, 1)))
        #expect(trial.bannerWindow.contains(TestSupport.local(cal, 2026, 10, 11, 8, 0)))
        #expect(!trial.bannerWindow.contains(TestSupport.local(cal, 2026, 10, 12, 8, 0)))
    }
}
