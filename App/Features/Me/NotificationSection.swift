import SwiftUI
import GentleWalkCore

/// Me → Notifications (task 7.11): the reminder moment and time, how often, and the three
/// switches. "New journeys" is off until the user turns it on (4.5.4).
struct NotificationSection: View {
    let app: AppModel
    @State private var changingTime = false

    var body: some View {
        let profile = app.profile ?? .empty
        SettingsCard(title: "Notifications") {
            Toggle(isOn: binding(\.walkReminders)) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Walk reminder").typeRole(.body)
                    Text(verbatim: "\(String(localized: OnboardingCopy.title(profile.reminderMoment))), \(DailyMomentPicker.time(profile.reminderMinutes))")
                        .typeRole(.caption)
                }
            }
            .frame(minHeight: Metrics.minTouchTarget)
            Button("Change") { changingTime = true }.buttonStyle(.textLink)
            Text("How often").typeRole(.body).fontWeight(.semibold)
            HStack(spacing: Metrics.touchSpacing) {
                frequencyButton(.daily, "Daily", current: profile.frequency)
                frequencyButton(.quietDays, "Just on quiet days", current: profile.frequency)
            }
            Toggle("Journey milestones", isOn: binding(\.journeyMilestones)).typeRole(.body).frame(minHeight: Metrics.minTouchTarget)
            Toggle("Weekly recap", isOn: binding(\.weeklyRecap)).typeRole(.body).frame(minHeight: Metrics.minTouchTarget)
            Toggle(isOn: binding(\.newJourneys)) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("New journeys").typeRole(.body)
                    Text("Occasional news about new routes.").typeRole(.caption)
                }
            }
            .frame(minHeight: Metrics.minTouchTarget)
        }
        .tint(Palette.secondary)
        .sheet(isPresented: $changingTime) {
            ReminderTimeEditor(moment: profile.reminderMoment, minutes: profile.reminderMinutes) { moment, minutes in
                app.updateProfile {
                    $0.reminderMoment = moment.rawValue
                    $0.reminderMinutes = minutes
                }
            }
        }
    }

    private func binding(_ key: WritableKeyPath<NotificationSettings, Bool>) -> Binding<Bool> {
        Binding(get: { app.notificationSettings[keyPath: key] }, set: { app.notificationSettings[keyPath: key] = $0 })
    }

    private func frequencyButton(_ value: ReminderFrequency, _ title: LocalizedStringResource, current: ReminderFrequency) -> some View {
        Button { app.updateProfile { $0.reminderFrequency = value.rawValue } } label: { Text(title) }
            .buttonStyle(PillButtonStyle(isSelected: current == value))
            .accessibilityAddTraits(current == value ? .isSelected : [])
    }
}

/// Moment and time, changed with − / + (no slider, no wheel).
struct ReminderTimeEditor: View {
    @State var moment: DailyMoment
    @State var minutes: Int
    let onSave: (DailyMoment, Int) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DailyMomentPicker(moment: moment, minutes: minutes,
                                  onChoose: { moment = $0; minutes = $0.suggestedMinutes },
                                  onAdjust: { minutes = min(23 * 60 + 45, max(0, minutes + $0)) })
                Button("Save") {
                    onSave(moment, minutes)
                    dismiss()
                }
                .buttonStyle(.primaryAction)
            }
            .padding(Metrics.screenMargin)
        }
        .screenBackground()
    }
}
