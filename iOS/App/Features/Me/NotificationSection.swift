import SwiftUI
import UIKit
import GentleWalkCore

/// Me → Notifications (task 7.11): the reminder moment and time, how often, and the four
/// switches (self-check reminders: steady program task 4.15). "New journeys" is off until the user turns it on (4.5.4).
struct NotificationSection: View {
    let app: AppModel
    @State private var changingTime = false
    @State private var permission: SystemPermission.Reminders?

    var body: some View {
        let profile = app.profile ?? .empty
        // "Change time" on the title's line, like Edit and Change on the other cards (one row less).
        SettingsCard(title: "Notifications", actionTitle: "Change time", action: { changingTime = true }) {
            Toggle(isOn: binding(\.walkReminders)) {
                IconToggleLabel(icon: .reminder, title: "Walk reminder",
                                detail: "\(String(localized: OnboardingCopy.title(profile.reminderMoment))), \(DailyMomentPicker.time(profile.reminderMinutes))")
            }
            if permission == .blocked { BlockedRemindersNote() }
            Text("How often").typeRole(.body).fontWeight(.semibold)
            HStack(spacing: Metrics.touchSpacing) {
                frequencyButton(.daily, "Daily", current: profile.frequency)
                frequencyButton(.quietDays, "Only if I haven't moved", current: profile.frequency)
            }
            Toggle(isOn: binding(\.journeyMilestones)) { IconToggleLabel(icon: .journey, title: "When I reach a new postcard") }
            Toggle(isOn: binding(\.weeklyRecap)) { IconToggleLabel(icon: .progress, title: "Weekly recap") }
            // On by default; the reminder says nothing about health on the lock screen (task 4.15).
            Toggle(isOn: binding(\.selfCheckReminders)) { IconToggleLabel(icon: .selfCheck, title: "Self-check reminders") }
            Toggle(isOn: binding(\.newJourneys)) {
                IconToggleLabel(icon: .newJourneys, title: "New journeys", detail: String(localized: "Occasional news about new routes."))
            }
        }
        // Each switch says "On" or "Off" in words (control states, owner 08/10/2026).
        .toggleStyle(.onOffWord)
        .tint(Palette.secondary)
        // Read again each time Me shows (she may have changed it in Settings).
        .task { permission = await SystemPermission.reminders() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            Task { permission = await SystemPermission.reminders() }
        }
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
                                  onStep: { minutes = ReminderTime.step(minutes, by: $0) },
                                  onSet: { minutes = $0 })
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
