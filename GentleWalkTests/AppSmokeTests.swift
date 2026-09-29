import Testing
@testable import GentleWalk

/// Keeps the test target non-empty until the first real app tests land (task 1.5).
@Suite struct AppSmokeTests {
    @Test @MainActor func rootViewBuilds() {
        _ = RootView(notificationDelegate: NotificationDelegate()).body
    }
}
