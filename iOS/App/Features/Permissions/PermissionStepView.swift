import SwiftUI

/// Which permission a step asks for (plan 08/10/2026 task 1.6): one per screen, reminders first.
enum PermissionAsk: String, Sendable {
    case reminders, health

    /// "1 of 2" in the corner.
    var number: Int { self == .reminders ? 1 : 2 }
}

/// S16a / S16b: one permission per screen, right after the first session, never before (5.1.1). The
/// reason in the app's own words first, then Apple's dialog. The main button names the feature, not
/// "Allow" (decision D8); "Not now" stays (decision D5, Review Notes say every permission is optional).
/// Once granted: a green line and "Continue". At accessibility text sizes the buttons scroll with the page.
struct PermissionStepView: View {
    let ask: PermissionAsk
    let model: PermissionsModel
    let moment: DailyMoment
    let minutes: Int
    let onReminderTime: (DailyMoment, Int) -> Void
    /// Goes on: "Not now", "Continue", or a "Don't Allow" in Apple's dialog.
    let onDone: () -> Void
    var onBack: (() -> Void)? = nil

    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var asking = false

    private var isGranted: Bool { ask == .reminders ? model.remindersAllowed : model.healthConnected }
    private var pins: Bool { !typeSize.isAccessibilitySize }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                header
                switch ask {
                case .reminders:
                    ScreenHeader(title: "A nudge for your daily walk?",
                                 subtitle: "One message a day at most. Never on rest days.")
                    DailyMomentPicker(moment: moment, minutes: minutes,
                                      onChoose: { onReminderTime($0, $0.suggestedMinutes) },
                                      onStep: { onReminderTime(moment, ReminderTime.step(minutes, by: $0)) },
                                      onSet: { onReminderTime(moment, $0) },
                                      showsQuestion: false)
                case .health:
                    ScreenHeader(title: "See your everyday steps?",
                                 subtitle: "Progress shows your all-day steps. Your journey moves either way.")
                    ArtImage(art: .momentFriends, height: 110, fallbackSymbol: "heart.fill")
                    if !isGranted { HealthSheetCallout() }
                    Text("Your data stays on this phone.").typeRole(.caption).foregroundStyle(Palette.textMuted)
                }
                if isGranted { GrantedLine(ask: ask) }
                if !pins { actions }
            }
            .padding(.horizontal, Metrics.screenMargin)
            .padding(.bottom, Metrics.screenMargin)
            .readableColumn()
        }
        .scrollBounceBehavior(.basedOnSize)
        .pinnedActions(pins) { actions }
        .screenBackground()
    }

    /// "Back" on the second step, "1 of 2" on the right.
    private var header: some View {
        HStack {
            if let onBack {
                Button(action: onBack) { Label("Back", systemImage: "chevron.left") }.buttonStyle(.smallTextLink)
            }
            Spacer()
            Text("\(ask.number) of 2").typeRole(.caption).fontWeight(.semibold).foregroundStyle(Palette.text)
                .frame(minHeight: Metrics.minTouchTarget)
        }
    }

    @ViewBuilder private var actions: some View {
        if isGranted {
            Button("Continue", action: onDone).buttonStyle(.primaryAction)
        } else {
            Button(ask == .reminders ? "Set my reminder" : "Connect Apple Health") {
                guard !asking else { return }
                asking = true
                Task {
                    if ask == .reminders { await model.allowReminders() } else { await model.connectHealth() }
                    asking = false
                    // "Don't Allow" goes on to the next step: never ask twice.
                    if !isGranted { onDone() }
                }
            }
            .buttonStyle(.primaryAction)
            Button("Not now", action: onDone).buttonStyle(.textLink).frame(maxWidth: .infinity)
        }
    }
}

/// Apple's Health sheet keeps Allow greyed out until a switch is on: the one step people miss, so it
/// is a callout, not small grey print.
private struct HealthSheetCallout: View {
    var body: some View {
        Label("Next, Apple asks what to share: tap **Turn On All**, then **Allow**. Or tap **Don't Allow** to skip.",
              systemImage: "hand.tap.fill")
            .typeRole(.body)
            .foregroundStyle(Palette.text)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.sky.opacity(0.22), in: .rect(cornerRadius: 14))
    }
}

/// "Reminders on" / "Apple Health connected" in green once granted.
private struct GrantedLine: View {
    let ask: PermissionAsk

    var body: some View {
        Label {
            Text(ask == .reminders ? "Reminders on" : "Apple Health connected")
        } icon: {
            Image(systemName: "checkmark.circle.fill")
        }
        .typeRole(.body).fontWeight(.semibold)
        .foregroundStyle(Palette.text)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: Metrics.minTouchTarget, alignment: .leading)
        .background(Palette.secondary.opacity(0.15), in: .rect(cornerRadius: Metrics.buttonRadius))
    }
}
