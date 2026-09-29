import Foundation
import Observation
import UserNotifications

/// Apple Health permission, asked only from S16 (task 6.7 provides the real one).
@MainActor protocol HealthAuthorizing: AnyObject {
    var hasAskedForAuthorization: Bool { get }
    func requestAuthorization() async -> Bool
}

/// Notification permission, asked only from S16 (after the first workout).
@MainActor protocol NotificationAuthorizing: AnyObject {
    func requestAuthorization() async -> Bool
}

/// The system notification prompt.
@MainActor final class SystemNotificationAuthorizer: NotificationAuthorizing {
    func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }
}

/// S16 "Two quick things" (task 5.14): each button opens Apple's dialog; a granted card shows a tick.
@Observable @MainActor final class PermissionsModel {
    private(set) var healthConnected = false
    private(set) var remindersAllowed = false

    @ObservationIgnored private let health: HealthAuthorizing?
    @ObservationIgnored private let notifications: NotificationAuthorizing?

    init(health: HealthAuthorizing?, notifications: NotificationAuthorizing?,
         healthConnected: Bool = false, remindersAllowed: Bool = false) {
        self.health = health
        self.notifications = notifications
        self.healthConnected = healthConnected
        self.remindersAllowed = remindersAllowed
    }

    func connectHealth() async {
        healthConnected = await health?.requestAuthorization() ?? false
    }

    func allowReminders() async {
        remindersAllowed = await notifications?.requestAuthorization() ?? false
    }
}
