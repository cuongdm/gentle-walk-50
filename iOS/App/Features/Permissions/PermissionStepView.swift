import SwiftUI

/// Which permission a step asks for (plan 08/10/2026 task 1.6): one per screen, reminders first.
enum PermissionAsk: String, Sendable {
    case reminders, health

    /// "1 of 2" in the corner.
    var number: Int { self == .reminders ? 1 : 2 }

    /// The feature asked for, with its icon, over the title (plan 08/10/2026 task 3.8).
    var kicker: LocalizedStringResource { self == .reminders ? "Daily reminder" : "Apple Health" }
    var icon: AppIcon { self == .reminders ? .reminder : .health }
}

/// S16a / S16b: one permission per screen, right after the first session, never before (5.1.1). The
/// reason in the app's own words first, then Apple's dialog. The main button names the feature, not
/// "Allow" (decision D8). One button only (App Review I-2, owner 08/10/2026, replaces D5's "Not now"): it
/// always opens Apple's dialog, and "Don't Allow" there moves on with the feature off (Review Notes).
/// Once granted: a green line and "Continue". At accessibility text sizes the buttons scroll with the page.
struct PermissionStepView: View {
    let ask: PermissionAsk
    let model: PermissionsModel
    let moment: DailyMoment
    let minutes: Int
    let onReminderTime: (DailyMoment, Int) -> Void
    /// Goes on: "Continue" once granted, or right after a "Don't Allow" in Apple's dialog.
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
                    kicker
                    ScreenHeader(title: "See your everyday steps?",
                                 subtitle: "Progress shows your all-day steps. Your journey moves either way.")
                    ArtImage(art: .momentFriends, height: 96, fallbackSymbol: "heart.fill")
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

    /// "Back" on the second step, else the feature with its icon ("Daily reminder"); "1 of 2" on the right.
    private var header: some View {
        // One line; at large sizes "1 of 2" goes under the words instead of squeezing them.
        ViewThatFits(in: .horizontal) {
            HStack {
                leading.fixedSize()
                Spacer()
                stepCount
            }
            VStack(alignment: .leading, spacing: 0) {
                leading
                stepCount
            }
        }
    }

    @ViewBuilder private var leading: some View {
        if let onBack {
            Button(action: onBack) { Label("Back", systemImage: "chevron.left") }.buttonStyle(.smallTextLink)
        } else {
            kicker
        }
    }

    private var stepCount: some View {
        Text("\(ask.number) of 2").typeRole(.caption).fontWeight(.semibold).foregroundStyle(Palette.text)
            .frame(minHeight: Metrics.minTouchTarget)
    }

    private var kicker: some View {
        HStack(spacing: 10) {
            // At accessibility sizes the words need the width ("Dail-y re-min-der" broke).
            if !typeSize.isAccessibilitySize { AppIconChip(icon: ask.icon) }
            Text(ask.kicker).typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder private var actions: some View {
        if isGranted {
            Button("Continue", action: onDone).buttonStyle(.primaryAction)
        } else {
            Button(ask == .reminders ? "Set my reminder" : "Connect Apple Health") {
                guard !asking else { return }
                asking = true
                Task {
                    let granted = await model.ask(ask)
                    asking = false
                    // "Don't Allow" goes on to the next step: never ask twice.
                    if !granted { onDone() }
                }
            }
            .buttonStyle(.primaryAction)
        }
    }
}

/// Apple's Health sheet keeps Allow greyed out until a switch is on: the one step people miss, so it
/// is a callout, not small grey print.
private struct HealthSheetCallout: View {
    var body: some View {
        Label { Text("Next, Apple asks what to share: tap **Turn On All**, then **Allow**. Or tap **Don't Allow** to skip.") }
            icon: { AppIconGlyph(icon: .info) }
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
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        // At accessibility sizes the check goes above the words ("connecte / d" broke mid-word beside it
        // on an iPhone SE, review A 09/10/2026).
        let layout = typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
            : AnyLayout(HStackLayout(spacing: 10))
        layout {
            Image(systemName: "checkmark.circle.fill").accessibilityHidden(true)
            Text(ask == .reminders ? "Reminders on" : "Apple Health connected")
                .fixedSize(horizontal: false, vertical: true)
        }
        .typeRole(.body).fontWeight(.semibold)
        .foregroundStyle(Palette.text)
        .padding(.vertical, typeSize.isAccessibilitySize ? 10 : 0)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: Metrics.minTouchTarget, alignment: .leading)
        .background(Palette.secondary.opacity(0.15), in: .rect(cornerRadius: Metrics.buttonRadius))
    }
}
