import SwiftUI

/// S16 Permissions: only once, right after the first Complete. Never before the first workout.
struct PermissionsView: View {
    let model: PermissionsModel
    /// "A gentle reminder after your morning coffee" — follows the moment picked on S07.
    let reminderTitle: String
    let onDone: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScreenHeader(title: "Two quick things")
                PermissionCard(
                    title: String(localized: "See your everyday steps"),
                    detail: String(localized: "We read your steps from Apple Health to show your all-day activity in Progress. Your journey moves with the minutes you spend here. Your data stays on this phone.\n\nNext, Apple asks what to share: tap “Turn On All”, then “Allow”. Or tap “Don’t Allow” to skip."),
                    button: "Connect Apple Health", isGranted: model.healthConnected) {
                        Task { await model.connectHealth() }
                    }
                PermissionCard(
                    title: reminderTitle,
                    detail: String(localized: "One message a day at most. Never on days you've already walked or rest days."),
                    button: "Allow reminders", isGranted: model.remindersAllowed) {
                        Task { await model.allowReminders() }
                    }
                Button(model.healthConnected && model.remindersAllowed ? "Continue" : "Not now", action: onDone)
                    .buttonStyle(.textLink)
                    .frame(maxWidth: .infinity)
            }
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        .screenBackground()
    }
}

private struct PermissionCard: View {
    let title: String
    let detail: String
    let button: LocalizedStringResource
    let isGranted: Bool
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(verbatim: title).typeRole(.cardTitle).foregroundStyle(Palette.text)
            Text(verbatim: detail).typeRole(.body).foregroundStyle(Palette.text)
            if isGranted {
                Label("Done", systemImage: "checkmark.circle.fill")
                    .typeRole(.body).fontWeight(.semibold)
                    .foregroundStyle(Palette.secondary)
                    .frame(minHeight: Metrics.minTouchTarget)
            } else {
                Button(action: action) { Text(button) }.buttonStyle(.secondaryAction)
            }
        }
        .cardStyle()
    }
}
