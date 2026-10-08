import SwiftUI
import UserNotifications
import GentleWalkCore

/// App entry point. The notification delegate is set before the first scene so a reminder tap
/// that launched the app reaches it.
@main
struct GentleWalkApp: App {
    /// Kept for the whole run; the notification center holds its delegate weakly.
    private static let notificationDelegate = NotificationDelegate()

    init() {
        UNUserNotificationCenter.current().delegate = Self.notificationDelegate
        MainTabView.useLargerTabLabels()
    }

    var body: some Scene {
        WindowGroup {
            RootView(notificationDelegate: Self.notificationDelegate)
        }
    }
}
