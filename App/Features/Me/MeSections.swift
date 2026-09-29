import SwiftUI
import GentleWalkCore

// Sections of S20 Me (task 6.9). Each is its own view with narrow inputs.

/// A titled settings card.
struct SettingsCard<Content: View>: View {
    let title: LocalizedStringResource
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).typeRole(.cardTitle).accessibilityAddTraits(.isHeader)
            content
        }
        .foregroundStyle(Palette.text)
        .cardStyle()
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

    var body: some View {
        SettingsCard(title: "Subscription") {
            switch entitlement {
            case .trial(let ends):
                let date = ends.formatted(.dateTime.month(.abbreviated).day())
                if let yearlyPrice {
                    Text("Free trial · ends \(date), then \(yearlyPrice) a year").typeRole(.body)
                } else {
                    Text("Free trial · ends \(date)").typeRole(.body)
                }
                Button("How to cancel", action: onHowToCancel).buttonStyle(.textLink)
            case .subscribed:
                if let renewalDate {
                    Text("Gentle Walk Pro · renews \(renewalDate.formatted(.dateTime.month(.abbreviated).day()))").typeRole(.body)
                } else {
                    Text("Gentle Walk Pro").typeRole(.body)
                }
                Button("How to cancel", action: onHowToCancel).buttonStyle(.textLink)
            case .lifetime:
                Text("Lifetime access · no renewals").typeRole(.body)
                if renewingProductID != nil {
                    let date = renewalDate?.formatted(.dateTime.month(.abbreviated).day()) ?? ""
                    Text("Your \(renewingProductID == ProductID.monthly ? String(localized: "monthly") : String(localized: "yearly")) plan still renews on \(date)")
                        .typeRole(.body).fontWeight(.semibold)
                    Button("Cancel it", action: onHowToCancel).buttonStyle(.textLink)
                }
            case .free:
                Text("Free plan: a walk every day, New York and the first stop of every journey.").typeRole(.body)
                Button("See plans", action: onSeePlans).buttonStyle(.secondaryAction)
            }
        }
    }
}

struct BodySection: View {
    let limits: Set<BodyLimit>
    let onEdit: () -> Void

    var body: some View {
        SettingsCard(title: "Your body") {
            if limits.isEmpty {
                Text("Nothing to go easy on").typeRole(.body)
            } else {
                LimitChips(limits: limits)
            }
            Button("Edit", action: onEdit).buttonStyle(.textLink)
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
        SettingsCard(title: "Your week") {
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
            } else {
                Button("Change") {
                    draft = restDays
                    editing = true
                }
                .buttonStyle(.textLink)
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
        SettingsCard(title: "Workout") {
            Toggle("Voice louder than music", isOn: $voiceLouder).typeRole(.body).frame(minHeight: Metrics.minTouchTarget)
            Toggle("Captions", isOn: $captionsOn).typeRole(.body).frame(minHeight: Metrics.minTouchTarget)
            if let style = musicStyles.first {
                Toggle(isOn: Binding(get: { !musicOff }, set: { musicOff = !$0 })) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Music").typeRole(.body)
                        Text(verbatim: style.name).typeRole(.caption)
                    }
                }
                .frame(minHeight: Metrics.minTouchTarget)
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

    var body: some View {
        SettingsCard(title: "Help") {
            Button("Restore purchase", action: onRestore).buttonStyle(.textLink)
            Link("Terms", destination: LegalLinks.termsOfUse).buttonStyle(.textLink)
            Button("Privacy", action: onPrivacy).buttonStyle(.textLink)
            Text("Gentle Walk is for general fitness. It isn't medical advice.").typeRole(.caption)
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
            Text("This removes your answers, workouts, journey progress and settings from this phone. It can't be undone.")
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
