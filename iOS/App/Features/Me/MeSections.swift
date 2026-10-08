import SwiftUI
import UIKit
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
                    Text("\(AppBrand.name) Pro · renews \(renewalDate.formatted(.dateTime.month(.abbreviated).day()))").typeRole(.body)
                } else {
                    Text("\(AppBrand.name) Pro").typeRole(.body)
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

/// "Walking level: In place since Oct 20 · Started at Seated" (plan 08/10/2026 task 0.6): the same
/// current level Today and Preview use, and where she began.
struct WalkingLevelSummary: Equatable {
    var level: WalkLevel
    /// When the level last changed; nil while she is still at her start level.
    var since: Date?
    var start: WalkLevel
}

struct WalkingLevelLine: View {
    let summary: WalkingLevelSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let since = summary.since {
                Text("Walking level: \(Text(summary.level.title)) since \(since.formatted(.dateTime.month(.abbreviated).day()))")
                    .typeRole(.body)
                Text("Started at \(Text(summary.start.title))").typeRole(.caption).foregroundStyle(Palette.textMuted)
            } else {
                Text("Walking level: \(Text(summary.level.title))").typeRole(.body)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct BodySection: View {
    let limits: Set<BodyLimit>
    var walking: WalkingLevelSummary? = nil
    let onEdit: () -> Void

    var body: some View {
        SettingsCard(title: "Your body", actionTitle: "Edit", action: onEdit) {
            if let walking { WalkingLevelLine(summary: walking) }
            if limits.isEmpty {
                Text("Nothing to go easy on").typeRole(.body)
            } else {
                LimitChips(limits: limits)
            }
        }
    }
}

/// "Your 12 weeks": where she is, the plan, and "Start a new 12 weeks" (steady program task 4.14). Starting
/// again keeps her 2-week checks.
struct ProgramSection: View {
    let strip: ProgramStripState
    let onOpen: () -> Void
    let onRestart: () -> Void

    @State private var confirming = false

    var body: some View {
        SettingsCard(title: "Your 12 weeks", actionTitle: "See plan", action: onOpen) {
            Text(verbatim: strip.title).typeRole(.body).fontWeight(.semibold)
            Text(verbatim: strip.detail).typeRole(.caption).foregroundStyle(Palette.textMuted)
            Button("Start a new 12 weeks") { confirming = true }.buttonStyle(.secondaryAction)
        }
        .confirmationDialog("Start a new 12 weeks?", isPresented: $confirming, titleVisibility: .visible) {
            Button("Start from week 1", action: onRestart)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your 2-week checks and your progress stay.")
        }
    }
}

/// Pick two rest days from a list (no drag and drop). Pro only; free is Saturday and Sunday.
struct WeekSection: View {
    let restDays: Set<Weekday>
    var isPro = true
    var onSeePlans: () -> Void = {}
    let onChange: (Set<Weekday>) -> Void
    @State private var editing = false
    @State private var draft: Set<Weekday> = []

    private let order: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

    var body: some View {
        // On the free plan the card shows too, with the way to Pro (moving rest days is a Pro feature;
        // free users never learned it existed; review 02/10/2026).
        SettingsCard(title: "Your week", actionTitle: editing ? nil : (isPro ? "Change" : "Change with Pro"), action: {
            guard isPro else { return onSeePlans() }
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
        SettingsCard(title: "Sound and captions") {
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

/// Appearance (Auto · Light · Dark) and text size with A− / A+ (no slider).
struct DisplaySection: View {
    @Binding var textSize: TextSizeOverride
    @Binding var appearance: AppearanceChoice

    var body: some View {
        SettingsCard(title: "Display") {
            Text("Appearance").typeRole(.body)
            HStack(spacing: 8) {
                ForEach(AppearanceChoice.allCases) { choice in
                    Button { appearance = choice } label: { Text(choice.title) }
                        .buttonStyle(PillButtonStyle(isSelected: appearance == choice, fills: true))
                        .accessibilityAddTraits(appearance == choice ? .isSelected : [])
                }
            }
            if appearance == .auto {
                Text("Auto follows your iPhone: light by day, dark at night if you've set it.")
                    .typeRole(.caption).foregroundStyle(Palette.textMuted)
            }
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

/// A small heading over a group of cards in Me.
struct SettingsGroupHeader: View {
    let title: LocalizedStringResource

    var body: some View {
        Text(title)
            .typeRole(.body).fontWeight(.semibold)
            .foregroundStyle(Palette.textMuted)
            .padding(.top, 10)
            .accessibilityAddTraits(.isHeader)
    }
}

/// Language and units in one card (owner 02/10/2026). The language follows the iPhone, English when
/// the app does not have it; a pick here shows from the next launch (iOS applies a language when the
/// app opens) and is the same preference as the app's page in iOS Settings → Language. Each language name
/// is in its own language. Units: distance (used for journeys and outdoor walks), weight and height
/// (kept for where they appear: the app does not ask for them).
struct LanguageUnitsSection: View {
    @Binding var units: UnitPreferences
    /// The stored pick, so a pick waiting for the next launch can be undone.
    @State private var picked = AppLanguage.picked()
    @State private var showsReopen = false

    var body: some View {
        SettingsCard(title: "Language and units") {
            if AppLanguage.selectable.count > 1 {
                choiceRow("Language") {
                    ForEach(AppLanguage.selectable) { language in
                        pill(isOn: picked == language, label: Text(verbatim: language.nativeName)) {
                            guard language != picked else { return }
                            picked = language
                            AppLanguage.choose(language)
                            showsReopen = language != AppLanguage.current
                        }
                    }
                }
                if picked != AppLanguage.current {
                    Label { Text(verbatim: picked.reopenHint) } icon: { Image(systemName: "arrow.clockwise") }
                        .typeRole(.caption).foregroundStyle(Palette.text)
                }
                Divider()
            }
            // One line per unit, short symbols on the buttons (the full name is what VoiceOver reads):
            // three label-over-buttons rows made Me a screen longer (owner 02/10/2026).
            choiceRow("Distance") {
                ForEach(UnitPreferences.Distance.allCases) { value in
                    pill(isOn: units.distance == value, label: Text(value.symbol), spoken: value.title) { units.distance = value }
                }
            }
            choiceRow("Weight") {
                ForEach(UnitPreferences.Weight.allCases) { value in
                    pill(isOn: units.weight == value, label: Text(value.symbol), spoken: value.title) { units.weight = value }
                }
            }
            choiceRow("Height") {
                ForEach(UnitPreferences.Height.allCases) { value in
                    pill(isOn: units.height == value, label: Text(value.symbol), spoken: value.title) { units.height = value }
                }
            }
            Text("Journeys and outdoor walks use your distance unit.")
                .typeRole(.caption).foregroundStyle(Palette.textMuted)
        }
        // In the picked language itself: whoever picks it can read it.
        .alert(Text(verbatim: picked.nativeName), isPresented: $showsReopen) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(verbatim: picked.reopenHint)
        }
    }

    /// The label and its buttons on one line; the label over the buttons when they do not fit
    /// (long language names, large text).
    private func choiceRow<Pills: View>(_ title: LocalizedStringResource, @ViewBuilder pills: () -> Pills) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                Text(title).typeRole(.body).fontWeight(.semibold).fixedSize()
                Spacer(minLength: 8)
                HStack(spacing: 8) { pills() }.fixedSize()
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(title).typeRole(.body).fontWeight(.semibold)
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) { pills() }
                    VStack(spacing: 8) { pills() }
                }
            }
        }
    }

    private func pill(isOn: Bool, label: Text, spoken: LocalizedStringResource? = nil,
                      action: @escaping () -> Void) -> some View {
        Button(action: action) { label.frame(minWidth: 44) }
            .buttonStyle(PillButtonStyle(isSelected: isOn))
            .accessibilityLabel(spoken.map { Text($0) } ?? label)
            .accessibilityAddTraits(isOn ? .isSelected : [])
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

/// Location for outdoor walks. Turning it on asks iOS when it never asked; when iOS blocks it, the
/// card says so with the way to Settings (the switch read "on" and did nothing; review 02/10/2026).
struct OutdoorSection: View {
    let defaults: UserDefaults
    let location: LocationService
    @AppStorage(OutdoorLocationChoice.defaultsKey) private var choice = ""
    /// Read when Me shows, when the app comes back from Settings, and after Apple's dialog.
    @State private var denied = false

    var body: some View {
        SettingsCard(title: "Outdoor walks") {
            Toggle(isOn: Binding(get: { choice == "location" }, set: { on in
                choice = on ? "location" : "steps"
                if on { Task { _ = await location.requestPermissionAndWait(); denied = location.isDenied } }
            })) {
                VStack(alignment: .leading) {
                    // The same choice as in Outdoor prep: map and distance, or steps only (task 1.17).
                    Text("Map and distance").typeRole(.body)
                    Text("Uses your location while you walk. Off: steps only.").typeRole(.caption)
                }
            }
            .tint(Palette.secondary)
            if choice == "location", denied {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Location is off for \(AppBrand.name) on this iPhone.", systemImage: "location.slash.fill")
                        .typeRole(.body).foregroundStyle(Palette.text)
                    Button("Turn on in Settings", action: SystemPermission.openSettings)
                        .buttonStyle(.smallTextLink)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Palette.sun.opacity(0.18), in: .rect(cornerRadius: 14))
            }
        }
        .task { denied = location.isDenied }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            denied = location.isDenied
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
            Text("\(AppBrand.name) is for general fitness. It isn't medical advice.")
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
                // The two onboarding screens, as two groups (plan 08/10/2026 task 2.13).
                Text("Sore spots").typeRole(.cardTitle).foregroundStyle(Palette.text).accessibilityAddTraits(.isHeader)
                BodyLimitChips(limits: BodyLimitChips.soreSpots, selected: limits, onToggle: toggle)
                Text("Anything else").typeRole(.cardTitle).foregroundStyle(Palette.text).accessibilityAddTraits(.isHeader)
                BodyLimitChips(limits: BodyLimitChips.everyday, selected: limits, onToggle: toggle)
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

    private func toggle(_ limit: BodyLimit) {
        if limits.contains(limit) { limits.remove(limit) } else { limits.insert(limit) }
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
