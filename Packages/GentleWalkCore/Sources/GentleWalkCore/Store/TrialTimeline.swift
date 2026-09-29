import Foundation

/// Trial dates shown before and during the trial (task 2.13): billing date on the paywall and S16,
/// a reminder two days before, and the Today banner from day 10.
public struct TrialTimeline: Equatable, Sendable {
    public let start: Date
    public let billingDate: Date
    public let reminderDate: Date
    /// From the start of day 10 until billing.
    public let bannerWindow: DateInterval

    public static let reminderDaysBefore = 2
    public static let reminderHour = 10
    public static let bannerFromDay = 10

    /// Day arithmetic uses the user's calendar, so a daylight saving change keeps the local day and time.
    public init(start: Date, trialLength: Int, calendar: Calendar) {
        self.start = start
        let billing = calendar.date(byAdding: .day, value: trialLength, to: start) ?? start
        billingDate = billing
        let reminderDay = calendar.date(byAdding: .day, value: trialLength - Self.reminderDaysBefore, to: start) ?? start
        reminderDate = calendar.date(bySettingHour: Self.reminderHour, minute: 0, second: 0, of: reminderDay) ?? reminderDay
        let bannerDay = calendar.date(byAdding: .day, value: Self.bannerFromDay, to: start) ?? start
        let bannerStart = min(calendar.startOfDay(for: bannerDay), billing)
        bannerWindow = DateInterval(start: bannerStart, end: billing)
    }
}
