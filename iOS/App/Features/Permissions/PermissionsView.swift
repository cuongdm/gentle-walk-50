import SwiftUI

/// S16 Permissions: only once, right after the first Complete. Never before the first workout.
/// The reminder card is where she picks the moment and time (moved from Your plan, owner 01/10/2026):
/// the time is chosen where the reminder is asked for, and kept whether or not she allows it.
struct PermissionsView: View {
    let model: PermissionsModel
    let moment: DailyMoment
    let minutes: Int
    let onReminderTime: (DailyMoment, Int) -> Void
    let onDone: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScreenHeader(title: "Two quick things")
                PermissionCard(symbol: "bell.fill", tint: Palette.secondary, title: "What's a good moment for your daily walk?",
                               button: "Allow reminders", granted: "Reminders on", isGranted: model.remindersAllowed) {
                    Task { await model.allowReminders() }
                } content: {
                    Text("**One message a day at most**, never on rest days or days you've moved.")
                        .typeRole(.body).foregroundStyle(Palette.text)
                    DailyMomentPicker(moment: moment, minutes: minutes,
                                      onChoose: { onReminderTime($0, $0.suggestedMinutes) },
                                      onStep: { onReminderTime(moment, ReminderTime.step(minutes, by: $0)) },
                                      onSet: { onReminderTime(moment, $0) },
                                      showsQuestion: false)
                }
                PermissionCard(symbol: "heart.fill", tint: Palette.dangerSoft, title: "See your everyday steps",
                               button: "Connect Apple Health", granted: "Apple Health connected", isGranted: model.healthConnected) {
                    Task { await model.connectHealth() }
                } content: {
                    Text("Progress shows your all-day steps. **Your journey moves with or without it.** Your data stays on this phone.")
                        .typeRole(.body).foregroundStyle(Palette.text)
                    if !model.healthConnected {
                        // Apple's sheet keeps Allow greyed out until a switch is on: the one step people
                        // miss, so it is a callout, not small grey print.
                        Label("Next, Apple asks what to share: tap **Turn On All**, then **Allow**. Or tap **Don't Allow** to skip.",
                              systemImage: "hand.tap.fill")
                            .typeRole(.body)
                            .foregroundStyle(Palette.text)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Palette.sky.opacity(0.22), in: .rect(cornerRadius: 14))
                    }
                }
            }
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        // Always in view: the way out never sits under two long cards.
        .pinnedActions(true) {
            // Something granted: a clear "Done" (a "Not now" link read as undoing what she set).
            if model.healthConnected || model.remindersAllowed {
                Button("Done", action: onDone).buttonStyle(.primaryAction)
            } else {
                Button("Not now", action: onDone)
                    .buttonStyle(.textLink)
                    .frame(maxWidth: .infinity)
            }
        }
        .screenBackground()
    }
}

/// One permission: an icon in a soft circle and the title, what it is for, then the button, or a
/// green "Reminders on" once granted.
private struct PermissionCard<Content: View>: View {
    let symbol: String
    let tint: Color
    let title: LocalizedStringResource
    let button: LocalizedStringResource
    let granted: LocalizedStringResource
    let isGranted: Bool
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    @ScaledMetric(relativeTo: .title3) private var iconSize: CGFloat = 44

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: symbol)
                    .font(.title3)
                    .foregroundStyle(tint)
                    .frame(width: iconSize, height: iconSize)
                    .background(tint.opacity(0.15), in: .circle)
                    .accessibilityHidden(true)
                Text(title).typeRole(.cardTitle).foregroundStyle(Palette.text)
                    .accessibilityAddTraits(.isHeader)
            }
            content()
            if isGranted {
                Label { Text(granted) } icon: { Image(systemName: "checkmark.circle.fill") }
                    .typeRole(.body).fontWeight(.semibold)
                    .foregroundStyle(Palette.text)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, minHeight: Metrics.minTouchTarget, alignment: .leading)
                    .background(Palette.secondary.opacity(0.15), in: .rect(cornerRadius: Metrics.buttonRadius))
            } else {
                Button(action: action) { Text(button) }.buttonStyle(.secondaryAction)
            }
        }
        .cardStyle()
    }
}
