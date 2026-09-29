import Foundation

/// Notification categories registered with the system (task 7.9).
enum NotificationCategory {
    /// Walk reminder with "Start walk" and "Rest today".
    static let reminder = "WALK_REMINDER"
    static let landmark = "LANDMARK"
    static let general = "GENERAL"
}

enum NotificationAction {
    static let startWalk = "START_WALK"
    static let restToday = "REST_TODAY"
    /// `UNNotificationDefaultActionIdentifier`: the notification itself was tapped.
    static let defaultTap = "com.apple.UNNotificationDefaultActionIdentifier"
}

/// What the app does when the user taps a notification or one of its buttons.
@MainActor protocol DeepLinkTarget: AnyObject {
    func openTodaySession()
    func markRestToday()
    func openJourney()
    func openToday()
}

/// Notification response → app destination (task 6.12).
enum DeepLink: Equatable, Sendable {
    /// "Start walk": straight to today's session preview (S10).
    case startTodaySession
    /// "Rest today": marks today as rest in the background, the app stays closed.
    case restToday
    /// Landmark notification: the journey (S18).
    case journey
    /// Anything else: Today.
    case today

    init(category: String, action: String) {
        switch (category, action) {
        case (NotificationCategory.reminder, NotificationAction.startWalk): self = .startTodaySession
        case (NotificationCategory.reminder, NotificationAction.restToday): self = .restToday
        case (NotificationCategory.landmark, _): self = .journey
        default: self = .today
        }
    }

    var opensApp: Bool { self != .restToday }

    @MainActor func handle(with target: DeepLinkTarget) {
        switch self {
        case .startTodaySession: target.openTodaySession()
        case .restToday: target.markRestToday()
        case .journey: target.openJourney()
        case .today: target.openToday()
        }
    }
}
