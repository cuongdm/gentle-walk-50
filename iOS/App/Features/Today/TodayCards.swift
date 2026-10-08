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
                // Apple's sheet keeps Allow greyed out until a switch is on: say so before it opens.
                Text("Next, Apple asks what to share: tap “Turn On All”, then “Allow”. Or tap “Don’t Allow” to skip.")
                    .typeRole(.caption).foregroundStyle(Palette.textMuted)
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

/// "Your journey · New York City", then "1.8 of 5 mi · 0.4 mi to Times Square" (clarity review D7).
struct JourneyMiniCard: View {
    var title = ""
    let line: String
    let progress: Double
    var journeyID = "jr.ny"
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            HStack(spacing: 14) {
                ArtImage(name: Art.coverName(journeyID: journeyID), height: 72, fallbackSymbol: "map").frame(width: 96)
                VStack(alignment: .leading, spacing: 6) {
                    if !title.isEmpty {
                        Text(verbatim: String(localized: "Your journey · \(title)")).typeRole(.caption).foregroundStyle(Palette.textMuted)
                    }
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
                        // "Today" when the word is short enough for a seventh of the card; a longer one
                        // ("Hôm nay") gives way to the weekday in bold, the ring already marks the day
                        // (shrinking it made it unreadable).
                        let todayWord = String(localized: "Today")
                        let label = day.isToday && todayWord.count <= 6 ? todayWord : day.date.formatted(.dateTime.weekday(.abbreviated))
                        Text(verbatim: label)
                            .typeRole(.caption).fontWeight(day.isToday ? .bold : .regular).foregroundStyle(Palette.text)
                            .lineLimit(1).minimumScaleFactor(0.7)
                        Image(systemName: symbol(for: day))
                            // Free plan: a small muted dot for days still open (the spec shows no session kind).
                            .font(isPlainDot(day) ? .system(size: 8) : nil)
                            .foregroundStyle(day.mark == .active ? Palette.onStrongFill : isPlainDot(day) ? Palette.textMuted : Palette.text)
                            .frame(width: 36, height: 36)
                            .background(day.mark == .active ? Palette.secondary : Palette.surface, in: .circle)
                            .overlay {
                                Circle().strokeBorder(day.isToday ? Palette.primary : Palette.textMuted.opacity(0.3),
                                                      lineWidth: day.isToday ? 2.5 : 1)
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(Text(verbatim: accessibility(for: day)))
                }
            }
            Text(verbatim: line).typeRole(.body).foregroundStyle(Palette.text)
            if !isPro {
                Text("Grey dots are days still open.").typeRole(.caption).foregroundStyle(Palette.textMuted)
            }
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

/// Up to three short extras as a row of small cards (owner 01/10/2026: three full-width cards at
/// the foot made Today long); Pro ones carry the Pro badge for free users. A line says what they
/// are (review U12), and each shows its painting and Video mark like All sessions. A list again at
/// accessibility text sizes.
struct ExtrasRow: View {
    let extras: [TodayExtra]
    let isPro: Bool
    let onStart: (WorkoutRequest) -> Void
    let onLocked: () -> Void
    /// Opens "All sessions" (milestone 10), open to every plan.
    var onSeeAll: () -> Void = {}

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Short extras").typeRole(.cardTitle).foregroundStyle(Palette.text)
                Spacer()
                Button("See all", action: onSeeAll).buttonStyle(.smallTextLink)
                    .accessibilityLabel(Text("See all sessions"))
            }
            Text("Short sessions for any moment. Each one counts as an active day.")
                .typeRole(.caption).foregroundStyle(Palette.textMuted)
            if typeSize.isAccessibilitySize {
                ForEach(extras) { extra in
                    SessionCard(title: extra.title, detail: String(localized: "\(extra.minutes) min"), art: extra.art,
                                isLocked: !isPro, hasVideo: extra.hasVideo) { open(extra) }
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 10) {
                        ForEach(extras) { extra in
                            ExtraTile(extra: extra, isLocked: !isPro) { open(extra) }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollClipDisabled()
            }
        }
    }

    private func open(_ extra: TodayExtra) {
        isPro ? onStart(extra.request) : onLocked()
    }
}

/// One extra: painting, title, minutes and marks, about 150 pt wide so a third card peeks in on a
/// small phone and says the row scrolls.
struct ExtraTile: View {
    let extra: TodayExtra
    let isLocked: Bool
    let action: () -> Void

    @ScaledMetric(relativeTo: .body) private var width: CGFloat = 150

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                // Round marks on the painting's corner: the word badges would cover the picture at 150 pt.
                ArtImage(art: extra.art, height: 84)
                    .overlay(alignment: .topTrailing) {
                        HStack(spacing: 4) {
                            if extra.hasVideo { mark("play.fill", fill: Palette.secondary, ink: Palette.onStrongFill) }
                            if isLocked { mark("lock.fill", fill: Palette.sun, ink: Palette.onLightFill) }
                        }
                        .padding(6)
                    }
                Text(verbatim: extra.title).typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2, reservesSpace: true)
                Text(verbatim: String(localized: "\(extra.minutes) min")).typeRole(.caption).foregroundStyle(Palette.textMuted)
            }
            .padding(8)
            .frame(width: width, alignment: .leading)
            .background(Palette.surface, in: .rect(cornerRadius: Metrics.cardRadius, style: .continuous))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: spoken))
        .accessibilityAddTraits(.isButton)
    }

    private func mark(_ symbol: String, fill: Color, ink: Color) -> some View {
        Image(systemName: symbol)
            .font(.caption.weight(.bold))
            .foregroundStyle(ink)
            .frame(width: 26, height: 26)
            .background(fill, in: .circle)
    }

    /// "Morning stretch, 9 min, with video, Pro, locked".
    private var spoken: String {
        var parts = [extra.title, String(localized: "\(extra.minutes) min")]
        if extra.hasVideo { parts.append(String(localized: "With video")) }
        if isLocked { parts.append(String(localized: "Pro, locked")) }
        return parts.joined(separator: ", ")
    }
}

/// "Week 3 of 12 · Stage 1 · Steady base" with "Plan ›" (steady program task 4.3, design screen 2). After a
/// long break: "Pick up at week 5" (never "lost" or "start over").
struct ProgramStripCard: View {
    let strip: ProgramStripState
    let onOpen: () -> Void
    let onPickUp: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: onOpen) {
                HStack(spacing: 12) {
                    Image(systemName: "figure.stand").typeRole(.cardTitle).foregroundStyle(Palette.secondary)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(verbatim: strip.title).typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
                        Text(verbatim: strip.detail).typeRole(.caption).foregroundStyle(Palette.textMuted)
                    }
                    Spacer(minLength: 0)
                    HStack(spacing: 4) {
                        Text("Plan")
                        Image(systemName: "chevron.right").accessibilityHidden(true)
                    }
                    .typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
                }
                .frame(minHeight: Metrics.minTouchTarget)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityHint(Text("Opens your 12-week plan"))
            if let week = strip.pickUpWeek {
                Button(String(localized: "Pick up at week \(week)"), action: onPickUp)
                    .buttonStyle(PillButtonStyle(isSelected: true))
            }
        }
        .cardStyle(padding: 12)
    }
}

/// The 2-week self-check on Today: coming up (one quiet line), or ready with "Start" (task 4.3).
struct SelfCheckCard: View {
    let status: SelfCheckStatus
    let title: String
    let onStart: () -> Void
    let onLater: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "chair.fill").typeRole(.cardTitle).foregroundStyle(Palette.secondary).accessibilityHidden(true)
                Text(verbatim: title).typeRole(.body).fontWeight(.semibold)
            }
            switch status {
            case .dueIn:
                Text("30 seconds of sit-to-stands. You compare only with yourself.").typeRole(.caption)
                    .foregroundStyle(Palette.textMuted)
            case .invite:
                Text("Thirty seconds with your chair. In two weeks, do it again and compare with yourself.").typeRole(.body)
                HStack(spacing: Metrics.touchSpacing) {
                    Button("Let's do it", action: onStart).buttonStyle(PillButtonStyle(isSelected: true))
                    Button("Later", action: onLater).buttonStyle(.textLink)
                }
            case .due, .overdue:
                Text("30 seconds of sit-to-stands. You compare only with yourself.").typeRole(.body)
                Button("Start my check", action: onStart).buttonStyle(.secondaryAction)
            case .none:
                EmptyView()
            }
        }
        .foregroundStyle(Palette.text)
        .cardStyle()
    }
}
