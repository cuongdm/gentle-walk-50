import UserNotifications

/// Routes notification taps and buttons to the app (task 6.12). Set as the center's delegate at
/// launch so a tap that opened the app is not lost.
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, @unchecked Sendable {
    @MainActor weak var target: DeepLinkTarget?
    @MainActor private var pending: DeepLink?

    @MainActor func attach(_ target: DeepLinkTarget) {
        self.target = target
        if let pending {
            pending.handle(with: target)
            self.pending = nil
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let link = DeepLink(category: response.notification.request.content.categoryIdentifier, action: response.actionIdentifier)
        await MainActor.run {
            if let target { link.handle(with: target) } else { pending = link }
        }
    }

    /// While the app is open, reminders still show as a banner.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async
        -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
