import SwiftUI
import GentleWalkCore

// Sections of S20 Me (task 6.9). Each is its own view with narrow inputs.

/// A titled settings card. Its one link ("Edit", "Change", "How to cancel") sits on the title's
/// line, which saves a row per card (review U8); it drops below the title when the text is large.
struct SettingsCard<Content: View>: View {
    let title: LocalizedStringResource
    var actionTitle: LocalizedStringResource? = nil
    var action: (() -> Void)? = nil
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline) {
                    heading
                    Spacer(minLength: 12)
                    link
                }
                VStack(alignment: .leading, spacing: 4) {
                    heading
                    link
                }
            }
            content
        }
        .foregroundStyle(Palette.text)
        .cardStyle()
    }

    private var heading: some View {
        Text(title).typeRole(.cardTitle).accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder private var link: some View {
        if let actionTitle, let action {
            Button(actionTitle, action: action).buttonStyle(.textLink).fixedSize()
        }
    }
}

/// Subscription on top: what the user has, when it renews, how to cancel (3.1.2).
struct SubscriptionSection: View {
    let entitlement: Entitlement
    let renewingProductID: String?
    let renewalDate: Date?
    let yearlyPrice: String?
    let onSeePlans: () -> Void
    let onHowToCancel: () -> Void

    /// Trial and subscription show "How to cancel" beside the title.
    private var cancels: Bool {
        switch entitlement {
        case .trial, .subscribed: true
        default: false
        }
    }

    var body: some View {
        SettingsCard(title: "Subscription", actionTitle: cancels ? "How to cancel" : nil, action: onHowToCancel) {
            switch entitlement {
            case .trial(let ends):
                let date = ends.formatted(.dateTime.month(.abbreviated).day())
                if let yearlyPrice {
                    Text("Free trial · ends \(date), then \(yearlyPrice) a year").typeRole(.body)
                } else {
                    Text("Free trial · ends \(date)").typeRole(.body)
                }
            case .subscribed:
                if let renewalDate {
                    Text("Gentle Walk Pro · renews \(renewalDate.formatted(.dateTime.month(.abbreviated).day()))").typeRole(.body)
                } else {
                    Text("Gentle Walk Pro").typeRole(.body)
                }
            case .lifetime:
                Text("Lifetime access · no renewals").typeRole(.body)
                if renewingProductID != nil {
                    let date = renewalDate?.formatted(.dateTime.month(.abbreviated).day()) ?? ""
                    Text("Your \(renewingProductID == ProductID.monthly ? String(localized: "monthly") : String(localized: "yearly")) plan still renews on \(date)")
                        .typeRole(.body).fontWeight(.semibold)
                    Button("Cancel it", action: onHowToCancel).buttonStyle(.textLink)
                }
            case .free:
                Text("Free plan: a walk each weekday, the New York journey, and the first leg of every other journey.").typeRole(.body)
                Button("See Pro plans", action: onSeePlans).buttonStyle(.secondaryAction)
            }
        }
    }
}

struct BodySection: View {
    let limits: Set<BodyLimit>
    let onEdit: () -> Void

    var body: some View {
        SettingsCard(title: "Your body", actionTitle: "Edit", action: onEdit) {
            if limits.isEmpty {
                Text("Nothing to go easy on").typeRole(.body)
            } else {
                LimitChips(limits: limits)
            }
        }
    }
}

/// Pick two rest days from a list (no drag and drop). Pro only; free is Saturday and Sunday.
struct WeekSection: View {
    let restDays: Set<Weekday>
    let onChange: (Set<Weekday>) -> Void
    @State private var editing = false
    @State private var draft: Set<Weekday> = []

    private let order: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

    var body: some View {
        SettingsCard(title: "Your week", actionTitle: editing ? nil : "Change", action: {
            draft = restDays
            editing = true
        }) {
            Text("Rest days: \(names(restDays))").typeRole(.body)
            if editing {
                ForEach(order, id: \.self) { day in
                    SelectableCard(title: LocalizedStringResource(stringLiteral: name(day)), isSelected: draft.contains(day)) {
                        if draft.contains(day) { draft.remove(day) } else if draft.count < RestDays.maximum { draft.insert(day) }
                    }
                }
                Button("Save") {
                    onChange(draft)
                    editing = false
                }
                .buttonStyle(.primaryAction)
            }
        }
    }

    private func name(_ day: Weekday) -> String { Calendar.current.weekdaySymbols[day.rawValue - 1] }
    private func names(_ days: Set<Weekday>) -> String {
        order.filter(days.contains).map(name).formatted(.list(type: .and))
    }
}

/// Voice, voice louder than music, music style (or Coming soon), captions.
struct WorkoutAudioSection: View {
    let defaults: UserDefaults
    let musicStyles: [MusicStyle]
    @AppStorage("voiceLouder") private var voiceLouder = true
    @AppStorage("captionsOn") private var captionsOn = true
    @AppStorage("musicOff") private var musicOff = false

    var body: some View {
        SettingsCard(title: "During a session") {
            Toggle("Captions", isOn: $captionsOn).typeRole(.body).frame(minHeight: Metrics.minTouchTarget)
            SoundControls(showsMusic: !musicStyles.isEmpty && !musicOff)
            if let style = musicStyles.first {
                Toggle(isOn: Binding(get: { !musicOff }, set: { musicOff = !$0 })) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Music").typeRole(.body)
                        Text(verbatim: style.name).typeRole(.caption)
                    }
                }
                .frame(minHeight: Metrics.minTouchTarget)
                // Only with music there is something for the voice to be louder than (review D44).
                if !musicOff {
                    Toggle("Voice louder than music", isOn: $voiceLouder).typeRole(.body).frame(minHeight: Metrics.minTouchTarget)
                }
            } else {
                HStack {
                    Text("Music").typeRole(.body)
                    Spacer()
                    Text("Coming soon").typeRole(.body)
                }
                .frame(minHeight: Metrics.minTouchTarget)
            }
        }
        .tint(Palette.secondary)
    }
}

/// Text size with A− / A+ (no slider).
struct DisplaySection: View {
    @Binding var textSize: TextSizeOverride

    var body: some View {
        SettingsCard(title: "Display") {
            HStack(spacing: Metrics.touchSpacing) {
                Text("Text size").typeRole(.body)
                Spacer()
                Button { textSize.decrease() } label: { Text(verbatim: "A−") }
                    .buttonStyle(PillButtonStyle())
                    .accessibilityLabel(Text("Smaller text"))
                Button { textSize.increase() } label: { Text(verbatim: "A+") }
                    .buttonStyle(PillButtonStyle())
                    .accessibilityLabel(Text("Larger text"))
            }
            Text("Reduce motion follows your iPhone setting in Settings → Accessibility.").typeRole(.caption)
        }
    }
}

struct HealthSection: View {
    let connected: Bool
    let onConnect: () -> Void

    var body: some View {
        SettingsCard(title: "Apple Health") {
            if connected {
                Label("Connected", systemImage: "checkmark.circle.fill").typeRole(.body).foregroundStyle(Palette.secondary)
            } else {
                Text("Not connected").typeRole(.body)
                Button("Connect Apple Health", action: onConnect).buttonStyle(.secondaryAction)
            }
        }
    }
}

struct OutdoorSection: View {
    let defaults: UserDefaults
    @AppStorage("outdoorLocationChoice") private var choice = ""

    var body: some View {
        SettingsCard(title: "Outdoor walks") {
            Toggle(isOn: Binding(get: { choice == "location" }, set: { choice = $0 ? "location" : "steps" })) {
                VStack(alignment: .leading) {
                    Text("Use location for outdoor walks").typeRole(.body)
                    Text("Only while you walk. Stays on this phone.").typeRole(.caption)
                }
            }
            .tint(Palette.secondary)
        }
    }
}

struct HelpSection: View {
    let onRestore: () -> Void
    let onPrivacy: () -> Void

    /// A list of rows (icon, words, chevron) with hairlines between them, instead of four
    /// underlined links with large gaps (owner, 30/09/2026).
    var body: some View {
        SettingsCard(title: "Help") {
            VStack(spacing: 0) {
                SettingsRow(title: "Restore purchase", symbol: "arrow.clockwise", action: onRestore)
                Divider()
                SettingsLinkRow(title: "Contact us", symbol: "envelope", url: LegalLinks.contactUs)
                Divider()
                SettingsLinkRow(title: "Terms of Use", symbol: "doc.text", url: LegalLinks.termsOfUse)
                Divider()
                SettingsRow(title: "Privacy", symbol: "hand.raised", action: onPrivacy)
            }
            Text("Gentle Walk is for general fitness. It isn't medical advice.")
                .typeRole(.caption).foregroundStyle(Palette.textMuted)
                .padding(.top, 4)
        }
    }
}

/// "Delete all my data" confirmation: says plainly what goes and what stays in Apple Health.
struct DeleteDataConfirmation: View {
    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer()
            ScreenHeader(title: "Delete all your data?")
            Text("This removes your answers, sessions, journey progress and settings from this phone. It can't be undone.")
                .typeRole(.body)
            Text("Workouts already saved in Apple Health stay there. You can remove them in the Health app.").typeRole(.body)
            Text("Your subscription is not affected. Manage it in Settings.").typeRole(.body)
            Spacer()
            Button("Delete everything", action: onDelete).buttonStyle(.dangerAction)
            Button("Keep my data", action: onCancel).buttonStyle(.secondaryAction)
        }
        .foregroundStyle(Palette.text)
        .padding(Metrics.screenMargin)
        .screenBackground()
    }
}

/// Edit body limits (same chips as S06).
struct BodyLimitsEditor: View {
    @State var limits: Set<BodyLimit>
    let onSave: (Set<BodyLimit>) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(title: "Anything we should go easy on?", subtitle: "We'll only show moves that fit.")
                FlowLayout(spacing: Metrics.touchSpacing) {
                    ForEach(OnboardingCopy.limitOrder, id: \.rawValue) { limit in
                        Button { if limits.contains(limit) { limits.remove(limit) } else { limits.insert(limit) } } label: {
                            Text(OnboardingCopy.chip(limit))
                        }
                        .buttonStyle(PillButtonStyle(isSelected: limits.contains(limit)))
                    }
                }
                Button("Save") {
                    onSave(limits)
                    dismiss()
                }
                .buttonStyle(.primaryAction)
            }
            .padding(Metrics.screenMargin)
        }
        .screenBackground()
    }
}

/// One settings row: an icon in a soft circle, the words, and a chevron; the whole row is the target.
struct SettingsRow: View {
    let title: LocalizedStringResource
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) { SettingsRowLabel(title: title, symbol: symbol, trailing: "chevron.right") }
            .buttonStyle(.plain)
    }
}

/// The same row opening a web page (arrow out instead of a chevron).
struct SettingsLinkRow: View {
    let title: LocalizedStringResource
    let symbol: String
    let url: URL

    var body: some View {
        Link(destination: url) { SettingsRowLabel(title: title, symbol: symbol, trailing: "arrow.up.right") }
            .buttonStyle(.plain)
    }
}

private struct SettingsRowLabel: View {
    let title: LocalizedStringResource
    let symbol: String
    let trailing: String

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        HStack(spacing: 14) {
            if !typeSize.isAccessibilitySize {
                Image(systemName: symbol)
                    .typeRole(.body)
                    .foregroundStyle(Palette.secondary)
                    .frame(width: 36, height: 36)
                    .background(Palette.secondary.opacity(0.12), in: .circle)
                    .accessibilityHidden(true)
            }
            Text(title).typeRole(.body).foregroundStyle(Palette.text)
            Spacer(minLength: 8)
            Image(systemName: trailing)
                .typeRole(.caption).fontWeight(.semibold)
                .foregroundStyle(Palette.textMuted)
                .accessibilityHidden(true)
        }
        .frame(minHeight: Metrics.minTouchTarget)
        .contentShape(.rect)
    }
}
