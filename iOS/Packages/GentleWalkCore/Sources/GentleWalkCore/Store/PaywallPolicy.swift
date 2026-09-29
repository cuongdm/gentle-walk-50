import Foundation

/// Where the app might offer Pro.
public enum PaywallTrigger: String, CaseIterable, Sendable {
    /// End of onboarding (S07 → S08).
    case onboarding
    /// The card after the New York journey is done.
    case finishedNewYork
    /// The user tapped something marked Pro.
    case lockedContent
    /// Opening the app. Never an invitation point.
    case appOpen
    /// Inside a workout. Never an invitation point.
    case duringWorkout
}

/// When Pro may be offered (task 5.11, plan "Vị trí paywall"): only at three points, never on app
/// open or during a workout, and a three-day rest after "Maybe later" unless the user asks by
/// tapping locked content.
public enum PaywallPolicy {
    public static let coolDown: TimeInterval = 3 * 86_400

    public static func shouldShow(trigger: PaywallTrigger, entitlement: Entitlement, lastDismissed: Date?, now: Date) -> Bool {
        guard !entitlement.isPro else { return false }
        switch trigger {
        case .appOpen, .duringWorkout:
            return false
        case .lockedContent, .onboarding:
            return true
        case .finishedNewYork:
            guard let lastDismissed else { return true }
            return now.timeIntervalSince(lastDismissed) >= coolDown
        }
    }
}
