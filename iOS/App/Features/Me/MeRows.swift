import SwiftUI
import GentleWalkCore

/// Every row of Me, for its icon (plan 08/10/2026 task 3.4; `claude-design/Me.dc.html`): one picture per
/// row, the goal row shows her goal's own icon.
enum MeRow: CaseIterable {
    case subscription, program, goal, body, setAside, restDays, notifications
    case sound, languageUnits, display, health, outdoors
    case restore, contact, terms, privacy, acknowledgements

    var icon: AppIcon {
        switch self {
        case .subscription: .payment
        case .program: .program
        // Replaced by the goal's own icon on screen (`OnboardingCopy.icon`).
        case .goal: .new
        case .body: .yourBody
        case .setAside: .hurts
        case .restDays: .rest
        case .notifications: .reminder
        case .sound: .sound
        case .languageUnits: .language
        case .display: .appearance
        case .health: .health
        case .outdoors: .outdoors
        case .restore: .restore
        case .contact: .contact
        case .terms: .terms
        case .privacy: .privacy
        case .acknowledgements: .acknowledgements
        }
    }
}

/// The screens a Me row opens (one `navigationDestination(for: MeRoute.self)` in the Me tab).
enum MeRoute: Hashable {
    case program, body, setAside, restDays, notifications, sound, languageUnits, display, health, outdoors
    case acknowledgements
}

/// A group of Me rows on one sheet of card paper, hairlines between them (iOS Settings pattern).
struct MeRowGroup<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            Group(subviews: content) { rows in
                ForEach(rows) { row in
                    row
                    if row.id != rows.last?.id {
                        Divider().padding(.leading, 52)
                    }
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .foregroundStyle(Palette.text)
        .cardStyle(padding: 0)
    }
}

/// One Me row: icon chip · words · value · ›. The whole row is the target (≥ 56 pt); VoiceOver hears
/// "Rest days, Saturday and Sunday, button". Pushes its screen, or runs `action` (a sheet, a web page).
struct MeNavigationRow: View {
    let title: LocalizedStringResource
    let icon: AppIcon
    var value: String? = nil
    var route: MeRoute? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        if let route {
            NavigationLink(value: route) { MeRowLabel(title: title, icon: icon, value: value, trailing: "chevron.right") }
                .buttonStyle(.plain)
        } else {
            Button { action?() } label: { MeRowLabel(title: title, icon: icon, value: value, trailing: "chevron.right") }
                .buttonStyle(.plain)
        }
    }
}

/// The same row opening a web page (arrow out instead of a chevron).
struct MeLinkRow: View {
    let title: LocalizedStringResource
    let icon: AppIcon
    let url: URL

    var body: some View {
        Link(destination: url) { MeRowLabel(title: title, icon: icon, value: nil, trailing: "arrow.up.right") }
            .buttonStyle(.plain)
    }
}

struct MeRowLabel: View {
    let title: LocalizedStringResource
    let icon: AppIcon
    let value: String?
    let trailing: String

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        HStack(spacing: 14) {
            // At accessibility sizes the words need the width; the icon only decorates (review U2).
            if !typeSize.isAccessibilitySize {
                AppIconChip(icon: icon)
            }
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    Text(title).typeRole(.body).fontWeight(.semibold).fixedSize()
                    Spacer(minLength: 8)
                    if let value {
                        Text(verbatim: value).typeRole(.body).foregroundStyle(Palette.textMuted).lineLimit(1)
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).typeRole(.body).fontWeight(.semibold)
                    if let value {
                        Text(verbatim: value).typeRole(.body).foregroundStyle(Palette.textMuted)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .multilineTextAlignment(.leading)
            Image(systemName: trailing)
                .typeRole(.caption).fontWeight(.semibold)
                .foregroundStyle(Palette.textMuted)
                .accessibilityHidden(true)
        }
        .foregroundStyle(Palette.text)
        .padding(.vertical, 6)
        .frame(minHeight: Metrics.minTouchTarget)
        .contentShape(.rect)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title) + Text(verbatim: value.map { ", \($0)" } ?? ""))
        .accessibilityAddTraits(.isButton)
    }
}

/// A screen opened from a Me row: its title, then the card that used to sit on Me (the card's own heading
/// is hidden, the screen title says it).
struct MeDetailScreen<Content: View>: View {
    let title: LocalizedStringResource
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(title: title)
                content
            }
            .environment(\.settingsCardShowsTitle, false)
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        .screenBackground()
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension EnvironmentValues {
    /// Off inside a Me screen whose title already names the card.
    @Entry var settingsCardShowsTitle = true
}

/// What each Me row opens (pushed in the Me tab).
struct MeDetailView: View {
    let route: MeRoute
    let app: AppModel
    @State private var editingBody = false

    var body: some View {
        switch route {
        case .program:
            MeDetailScreen(title: "Your 12 weeks") {
                if let strip = app.today?.programStrip {
                    ProgramSection(strip: strip, onOpen: {
                        app.mePath = []
                        app.tab = .today
                        app.todayPath = [.program]
                    }, onRestart: app.restartProgram)
                }
            }
        case .body:
            MeDetailScreen(title: "Your body") {
                BodySection(limits: app.profile?.limits ?? [], walking: app.walkingLevel, onEdit: { editingBody = true })
            }
            .sheet(isPresented: $editingBody) {
                BodyLimitsEditor(limits: app.profile?.limits ?? []) { limits in
                    app.updateProfile { $0.bodyLimits = OnboardingCopy.limitOrder.filter(limits.contains).map(\.rawValue) }
                }
            }
        case .setAside:
            MeDetailScreen(title: "Moves set aside") {
                let moves = app.setAsideMoves
                if moves.isEmpty {
                    Text("No moves are set aside.").typeRole(.body).foregroundStyle(Palette.text)
                } else {
                    SetAsideSection(moves: moves, onBringBack: app.bringBack)
                }
            }
        case .restDays:
            MeDetailScreen(title: "Your week") {
                WeekSection(restDays: app.restDays, isPro: app.isPro, onSeePlans: { app.offerPlans(.lockedContent) }) { days in
                    app.updateProfile { $0.restDays = days.map(\.rawValue).sorted(by: >) }
                }
            }
        case .notifications:
            MeDetailScreen(title: "Notifications") { NotificationSection(app: app) }
        case .sound:
            MeDetailScreen(title: "Sound and captions") {
                WorkoutAudioSection(defaults: app.defaults, musicStyles: app.music.styles)
            }
        case .languageUnits:
            MeDetailScreen(title: "Language and units") {
                LanguageUnitsSection(units: Binding(get: { app.units }, set: { app.units = $0 }))
            }
        case .display:
            MeDetailScreen(title: "Display") {
                DisplaySection(textSize: Binding(get: { app.textSize }, set: { app.textSize = $0 }),
                               appearance: Binding(get: { app.appearance }, set: { app.appearance = $0 }))
            }
        case .health:
            MeDetailScreen(title: "Apple Health") {
                HealthSection(connected: app.health.isConnected,
                              onConnect: { Task { _ = await app.health.requestAuthorization(); app.reload() } })
            }
        case .outdoors:
            MeDetailScreen(title: "Outdoor walks") { OutdoorSection(defaults: app.defaults, location: app.location) }
        case .acknowledgements:
            AcknowledgementsView()
        }
    }
}
