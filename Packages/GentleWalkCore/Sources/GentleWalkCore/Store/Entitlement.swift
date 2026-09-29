import Foundation

/// What the user may use. Resolved from StoreKit transactions by `EntitlementRules` (task 2.14).
public enum Entitlement: Equatable, Sendable {
    case free
    /// Yearly plan inside its free trial; `ends` is the first billing date.
    case trial(ends: Date)
    case subscribed
    case lifetime

    /// True for every paid state, including the trial.
    public var isPro: Bool { self != .free }
}
