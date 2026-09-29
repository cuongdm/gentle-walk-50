import SwiftUI
import GentleWalkCore

/// One special card at a time (spec "Trạng thái đặc biệt").
struct SpecialCard: View {
    let card: TodaySpecialCard
    let actions: TodayActions

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            switch card {
            case .pain(let area):
                Text("You've mentioned \(Text(area.painName)) pain 3 times this week. We've switched you to seated moves. Consider checking with your doctor.")
                    .typeRole(.body)
            case .shorter:
                Text("We made today a little shorter. Build up at your pace.").typeRole(.body)
            case .movedDown(let level):
                Text("We moved you back to \(Text(level.title)) for now.").typeRole(.body)
            case .connectHealth:
                Text("Count your steps automatically").typeRole(.cardTitle)
                HStack(spacing: Metrics.touchSpacing) {
                    Button("Connect", action: actions.onConnectHealth).buttonStyle(PillButtonStyle(isSelected: true))
                    Button("Not now", action: actions.onDismissCard).buttonStyle(.textLink)
                }
            case .fewerReminders:
                Text("You're doing this on your own now. Want fewer reminders?").typeRole(.body)
                FlowLayout(spacing: Metrics.touchSpacing) {
                    Button("Just on quiet days") { actions.onFewerReminders(true) }.buttonStyle(PillButtonStyle(isSelected: true))
                    Button("Keep them daily") { actions.onFewerReminders(false) }.buttonStyle(PillButtonStyle())
                }
            }
        }
        .foregroundStyle(Palette.text)
        .cardStyle()
        .overlay { RoundedRectangle(cornerRadius: Metrics.cardRadius).strokeBorder(Palette.sky, lineWidth: 2) }
    }
}

extension BodyArea {
    /// Word used in "You've mentioned knee pain…".
    var painName: LocalizedStringResource {
        switch self {
        case .knees: "knee"
        case .hips: "hip"
        case .lowerBack: "back"
        case .shoulders: "shoulder"
        case .neck: "neck"
        case .ankles: "ankle"
        case .other: "some"
        }
    }
}

/// "1.8 of 5 mi to Brooklyn Bridge" with a small map.
struct JourneyMiniCard: View {
    let line: String
    let progress: Double
    var journeyID = "jr.ny"
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            HStack(spacing: 14) {
                ArtImage(name: Art.coverName(journeyID: journeyID), height: 72, fallbackSymbol: "map").frame(width: 96)
                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: line).typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
                        .multilineTextAlignment(.leading)
                    ProgressView(value: progress).tint(Palette.secondary).accessibilityHidden(true)
                }
                Image(systemName: "chevron.right").foregroundStyle(Palette.textMuted).accessibilityHidden(true)
            }
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}

/// Seven days with the kind of session and planned rest days; the free plan shows plain dots.
struct WeekStrip: View {
    let days: [TodayDay]
    let isPro: Bool
    let line: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                ForEach(days) { day in
                    VStack(spacing: 4) {
                        Text(verbatim: day.date.formatted(.dateTime.weekday(.narrow)))
                            .typeRole(.caption).foregroundStyle(Palette.text)
                        Image(systemName: symbol(for: day))
                            // Free plan: a small muted dot for days still open (the spec shows no session kind).
                            .font(isPlainDot(day) ? .system(size: 8) : nil)
                            .foregroundStyle(day.mark == .active ? Palette.onStrongFill : isPlainDot(day) ? Palette.textMuted : Palette.text)
                            .frame(width: 36, height: 36)
                            .background(day.mark == .active ? Palette.secondary : Palette.surface, in: .circle)
                            .overlay { Circle().strokeBorder(Palette.textMuted.opacity(0.3)) }
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(Text(verbatim: accessibility(for: day)))
                }
            }
            Text(verbatim: line).typeRole(.body).foregroundStyle(Palette.text)
        }
        .cardStyle()
    }

    private func isPlainDot(_ day: TodayDay) -> Bool { !isPro && day.mark == .open }

    private func symbol(for day: TodayDay) -> String {
        if day.mark == .rest { return "moon.zzz" }
        if day.mark == .active { return "checkmark" }
        guard isPro else { return "circle.fill" }
        switch day.main {
        case .chair: return "chair.fill"
        case .stretch: return "figure.flexibility"
        case .walk, .longWalk: return "figure.walk"
        case nil: return "moon.zzz"
        }
    }

    private func accessibility(for day: TodayDay) -> String {
        let name = day.date.formatted(.dateTime.weekday(.wide))
        switch day.mark {
        case .active: return String(localized: "\(name), done")
        case .rest: return String(localized: "\(name), rest day")
        case .open: return name
        }
    }
}

/// Up to three short extras; Pro ones carry the Pro badge for free users.
struct ExtrasRow: View {
    let extras: [TodayExtra]
    let isPro: Bool
    let onStart: (WorkoutRequest) -> Void
    let onLocked: () -> Void
    /// Opens "All sessions" (milestone 10), open to every plan.
    var onSeeAll: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Extras").typeRole(.cardTitle).foregroundStyle(Palette.text)
                Spacer()
                Button("See all", action: onSeeAll).buttonStyle(.smallTextLink)
                    .accessibilityLabel(Text("See all sessions"))
            }
            ForEach(extras) { extra in
                Button { isPro ? onStart(extra.request) : onLocked() } label: {
                    HStack(spacing: 12) {
                        Image(systemName: extra.symbol).foregroundStyle(Palette.secondary).accessibilityHidden(true)
                        Text(verbatim: extra.title).typeRole(.body).foregroundStyle(Palette.text)
                        Spacer(minLength: 0)
                        if !isPro { ProBadge() }
                    }
                    .frame(minHeight: Metrics.minTouchTarget)
                    .cardStyle(padding: 12)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
