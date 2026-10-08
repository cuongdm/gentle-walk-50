import Foundation

/// The free trial the App Store offers on the yearly plan, read from StoreKit and turned into days
/// (review I-1, 08/10/2026). The paywall, the trial timeline and the trial reminder all use this
/// number, so the screen never promises a trial length App Store Connect does not offer (3.1.2(a)).
public enum TrialOffer {
    /// `Product.SubscriptionPeriod.Unit`, without StoreKit (the core is Foundation only).
    public enum Unit: Sendable, CaseIterable { case day, week, month, year }

    /// Days in a free-trial period of `value` × `unit`: 1 week = 7, 2 weeks = 14. A month counts as 30
    /// days and a year as 365, so the copy names a whole number of days. nil when the period is empty.
    public static func days(value: Int, unit: Unit) -> Int? {
        guard value > 0 else { return nil }
        switch unit {
        case .day: return value
        case .week: return value * 7
        case .month: return value * 30
        case .year: return value * 365
        }
    }
}
