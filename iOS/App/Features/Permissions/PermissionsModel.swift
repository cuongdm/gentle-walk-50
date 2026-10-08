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

/// S16a/S16b (task 5.14, one per screen since 08/10/2026): each button opens Apple's dialog; granted shows a tick.
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

    /// Reminders allowed earlier (the offer after "Not yet"): the card shows them on.
    func readReminders() async {
        if notifications is SystemNotificationAuthorizer, await SystemPermission.reminders() == .allowed { remindersAllowed = true }
    }

    func connectHealth() async {
        healthConnected = await health?.requestAuthorization() ?? false
    }

    func allowReminders() async {
        remindersAllowed = await notifications?.requestAuthorization() ?? false
    }

    /// The one button of a permission screen (App Review I-2, owner 08/10/2026): asks Apple and says
    /// whether it was granted. Not granted ("Don't Allow", or blocked earlier so Apple shows nothing): the
    /// flow moves on with the feature off; she can turn it on later in Me.
    func ask(_ ask: PermissionAsk) async -> Bool {
        switch ask {
        case .reminders:
            await allowReminders()
            return remindersAllowed
        case .health:
            await connectHealth()
            return healthConnected
        }
    }
}
