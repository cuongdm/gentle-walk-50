import SwiftUI
import UIKit
import UserNotifications

/// What iOS says about the app's notifications, and the way to its Settings page. A reminder the
/// iPhone blocks never comes, so the screens say so instead of showing it on (review 02/10/2026).
enum SystemPermission {
    enum Reminders: Equatable { case allowed, notAsked, blocked }

    static func reminders() async -> Reminders {
        switch await UNUserNotificationCenter.current().notificationSettings().authorizationStatus {
        case .authorized, .provisional, .ephemeral: .allowed
        case .notDetermined: .notAsked
        default: .blocked
        }
    }

    /// The app's page in iOS Settings (notifications, location, language).
    @MainActor static func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

/// "Reminders are off on this iPhone · Turn on" under the reminder switch when iOS blocks them.
struct BlockedRemindersNote: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Reminders are off on this iPhone.", systemImage: "bell.slash.fill")
                .typeRole(.body).foregroundStyle(Palette.text)
            Button("Turn on in Settings", action: SystemPermission.openSettings)
                .buttonStyle(.smallTextLink)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Palette.sun.opacity(0.18), in: .rect(cornerRadius: 14))
    }
}
