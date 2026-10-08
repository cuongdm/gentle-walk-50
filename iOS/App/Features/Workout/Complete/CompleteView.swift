import SwiftUI
import GentleWalkCore

/// S15 Workout complete. Fixed order: leaves (2 s), title, three numbers, "How did that feel?", the
/// 2-week check invite (week 0), one footnote card (tree and journey), self comparison, new postcard,
/// Done (pinned) and Share with family. On an iPhone SE the invite's buttons sit above Done on the
/// first walk (plan 08/10/2026 task 1.9).
struct CompleteView: View {
    let content: CompleteContent
    let onFeeling: (Feeling) -> Void
    let onDone: () -> Void
    var onOpenPostcard: (Journey.Stop) -> Void = { _ in }
    /// Outdoors with GPS: the route map (not shared).
    var route: [RoutePoint] = []
    /// The route also went to Apple Health: the app itself keeps only the distance (owner 01/10/2026).
    var routeInHealth = false
    /// Outdoors: today's chair moves are still waiting (minutes), with "Do them now".
    var chairMovesMinutes: Int?
    var onChairMoves: () -> Void = {}
    /// "Do it again" (milestone 10); nil when this session cannot be replayed on her plan.
    var onAgain: (() -> Void)?
    /// "Next time: Sit-to-stand, 1 × 10." after a ladder step up (Pro, steady program task 4.12).
    var levelUpLine: String?
    /// Week 0: "Want to see where you start? 30 seconds." until she does it or taps Later.
    var selfCheckInvite: SelfCheckInvite?

    struct SelfCheckInvite {
        let onStart: () -> Void
        let onLater: () -> Void
    }

    @State private var feeling: Feeling?
    @State private var inviteDismissed = false
    @Environment(\.dynamicTypeSize) private var typeSize
    /// Done stays in view at the bottom: an outdoor Complete runs two screens, and Done was only at
    /// the end (owner 01/10/2026). In the list at accessibility sizes, where a pinned bar would take
    /// too much of the screen.
    private var pinsDone: Bool { !typeSize.isAccessibilitySize }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    CompleteHero(title: content.title, subtitle: content.subtitle, level: content.reachedLevel,
                                 isCalm: content.variant == .stoppedForPain, sessionLine: content.sessionLine)
                    CompleteStats(minutes: content.minutes, milesText: content.milesText, milesLabel: content.milesLabel,
                                  activeDays: content.activeDays,
                                  milesIcon: content.variant == .outdoors ? .walk : .journey)
                    // Right under the numbers, so a postcard never pushes it below Done (review M3).
                    // After stopping for pain the answer is already known: no "too easy?" question.
                    if content.variant != .stoppedForPain {
                        FeelingQuestion(selection: feeling) { value in
                            feeling = value
                            onFeeling(value)
                        }
                    }
                    // The next thing to do comes before the numbers' details (task 1.9).
                    if let invite = selfCheckInvite, !inviteDismissed {
                        SelfCheckInviteCard(onStart: invite.onStart, onLater: {
                            inviteDismissed = true
                            invite.onLater()
                        })
                    }
                    // The next postcard as a tilted card with its stamp, then the tree line (Claude Design).
                    if let next = content.nextStop, let miles = content.milesToNext {
                        // The postcard opened today has its own big card below: no second copy here.
                        NextPostcardRow(next: next, milesToGo: miles,
                                        lastStop: content.newPostcard == nil ? content.lastStop : nil)
                    } else if let journeyLine = content.journeyLine {
                        CompleteJourneyLine(text: journeyLine, progress: content.journeyProgress)
                    }
                    CompleteTreeLine(activeDays: content.activeDays)
                    if route.count > 1 {
                        VStack(alignment: .leading, spacing: 6) {
                            RouteMapView(route: route)
                            if routeInHealth {
                                Label("Your route is saved in Apple Health.", systemImage: "heart.text.square")
                                    .typeRole(.caption).foregroundStyle(Palette.textMuted)
                            }
                        }
                    }
                    if let comparison = content.comparison {
                        Text(verbatim: comparison).typeRole(.body).foregroundStyle(Palette.text)
                    }
                    if let levelUpLine {
                        LevelUpLine(text: levelUpLine)
                    }
                    if let stop = content.newPostcard {
                        NewPostcardCard(stop: stop, onOpen: { onOpenPostcard(stop) })
                    }
                    if let chairMovesMinutes {
                        ChairMovesWaitingCard(minutes: chairMovesMinutes, onDoNow: onChairMoves)
                    }
                    if !pinsDone {
                        Button("Done", action: onDone).buttonStyle(.primaryAction)
                    }
                    if content.variant != .stoppedForPain { ShareCardButton(content: content) }
                    if let onAgain {
                        Button("Do it again", action: onAgain)
                            .buttonStyle(.smallTextLink)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(Metrics.screenMargin)
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
            }
            .pinnedActions(pinsDone) {
                Button("Done", action: onDone).buttonStyle(.primaryAction)
            }
            if content.variant != .stoppedForPain { FallingLeaves(isBigDay: content.cheerContext.map(FallingLeaves.bigDay) ?? false) }
        }
        .screenBackground()
    }
}

/// A ladder step up, said as a hint for next time (never a task).
struct LevelUpLine: View {
    let text: String

    var body: some View {
        Label { Text(verbatim: text) } icon: { Image(systemName: "arrow.up.circle.fill").foregroundStyle(Palette.secondary) }
            .typeRole(.body)
            .foregroundStyle(Palette.text)
            .cardStyle()
    }
}

/// "Want to see where you start? 30 seconds." · Let's do it · Later (week 0, after the first session).
struct SelfCheckInviteCard: View {
    let onStart: () -> Void
    let onLater: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Want to see where you start?").typeRole(.cardTitle)
            Text("Thirty seconds with your chair. In two weeks, do it again and compare with yourself.").typeRole(.body)
            // One row, so "Later" is in view with "Let's do it" (stacked at large text sizes).
            ViewThatFits(in: .horizontal) {
                HStack(spacing: Metrics.touchSpacing) { letsDoIt; later }
                VStack(spacing: 4) { letsDoIt; later }
            }
        }
        .foregroundStyle(Palette.text)
        .cardStyle(padding: 12)
        .overlay { RoundedRectangle(cornerRadius: Metrics.cardRadius).strokeBorder(Palette.sky, lineWidth: 2) }
    }

    private var letsDoIt: some View {
        Button("Let's do it", action: onStart).buttonStyle(PillButtonStyle(isSelected: true))
    }

    private var later: some View {
        Button("Later", action: onLater).buttonStyle(.textLink)
    }
}

/// "New postcard: Bethesda Fountain" · Open.
struct NewPostcardCard: View {
    let stop: Journey.Stop
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 10) {
                ArtImage(name: Art.postcardName(stopID: stop.id), fallbackName: Art.coverName(stopID: stop.id), height: 150)
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("New postcard").typeRole(.caption).foregroundStyle(Palette.textMuted)
                        Text(verbatim: stop.name).typeRole(.cardTitle).foregroundStyle(Palette.text)
                    }
                    Spacer(minLength: 0)
                    Label("Open", systemImage: "chevron.right").labelStyle(.titleAndIcon)
                        .typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
                }
            }
            // A real postcard: white border, a slight tilt and a soft shadow.
            .padding(10)
            .background(Palette.surface, in: .rect(cornerRadius: Metrics.cardRadius + 6))
            .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
            .overlay(alignment: .topTrailing) { PostcardStamp().offset(x: 8, y: -10) }
            .rotationEffect(.degrees(-1.5))
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

/// "How did that feel?" · Too easy · Just right · Too hard → "Got it. We'll adjust tomorrow."
struct FeelingQuestion: View {
    let selection: Feeling?
    let onSelect: (Feeling) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How did that feel?").typeRole(.cardTitle).foregroundStyle(Palette.text)
            // One row of three equal answers (they wrapped onto two lines); stacked at large text sizes.
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) { options }
                VStack(spacing: 8) { options }
            }
            if selection != nil {
                Text("Got it. We'll adjust tomorrow.").typeRole(.body).foregroundStyle(Palette.text)
            }
        }
    }

    @ViewBuilder private var options: some View {
        option(.tooEasy, "Too easy")
        option(.justRight, "Just right")
        option(.tooHard, "Too hard")
    }

    private func option(_ feeling: Feeling, _ title: LocalizedStringResource) -> some View {
        Button { onSelect(feeling) } label: { Text(title) }
            .buttonStyle(PillButtonStyle(isSelected: selection == feeling, fills: true))
            .accessibilityAddTraits(selection == feeling ? .isSelected : [])
    }
}

/// The coach cheering beside the title, so the numbers, the feeling question and Done are in view
/// without scrolling (review U4). A new tree level replaces her with the level's badge and line.
/// Stacked at accessibility text sizes.
struct CompleteHero: View {
    let title: String
    let subtitle: String?
    let level: TreeLevel?
    /// Stopped for pain: the coach resting, not cheering.
    var isCalm = false
    /// "SESSION 13 · DONE" above the title.
    var sessionLine: String?

    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .title) private var badgeSize: CGFloat = 76

    var body: some View {
        let layout = typeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
            : AnyLayout(HStackLayout(alignment: .center, spacing: 16))
        layout {
            if let level {
                Image(systemName: level.symbol)
                    .font(.system(size: badgeSize * 0.5))
                    .foregroundStyle(Palette.secondary)
                    .frame(width: badgeSize, height: badgeSize)
                    .background(Palette.secondary.opacity(0.15), in: .circle)
                    .accessibilityHidden(true)
            } else {
                ArtImage(art: isCalm ? .walkerRest : .walkerCelebrate, height: 132).frame(width: 110)
            }
            VStack(alignment: .leading, spacing: 4) {
                if let sessionLine, level == nil {
                    Text(verbatim: sessionLine.uppercased()).typeRole(.caption).fontWeight(.semibold).tracking(1.2)
                        .foregroundStyle(Palette.accent)
                }
                if let level {
                    Text("You reached \(Text(level.title)). Your tree grows with every active day.").typeRole(.body)
                        .fontWeight(.semibold).foregroundStyle(Palette.secondary)
                }
                ScreenHeaderText(title: title, subtitle: subtitle)
            }
            // Never cut the cheer short with "…" beside the badge (longer lines of task 3.6).
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// Leaves drifting down for two seconds with a short happy chime; the chime alone with Reduce Motion.
/// The season picks what falls (blossoms, leaves, autumn leaves, snowflakes) and a big day (a best, a
/// week or a stage done) lets more of them fall (plan 08/10/2026 task 3.6).
struct FallingLeaves: View {
    var isBigDay = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date()
    @State private var visible = true
    @State private var cheered = false

    /// Moments that get the fuller fall.
    static func bigDay(_ context: CheerContext) -> Bool {
        [.personalBest, .weekDone, .stageDone].contains(context)
    }

    /// Two shapes and two colours per season, from the palette.
    private static func pieces(_ season: Season) -> [(symbol: String, color: Color)] {
        switch season {
        case .spring: [("camera.macro", Palette.accent), ("leaf.fill", Palette.secondary)]
        case .summer: [("leaf.fill", Palette.secondary), ("sun.max.fill", Palette.sun)]
        case .autumn: [("leaf.fill", Palette.accent), ("leaf.fill", Palette.sun)]
        case .winter: [("snowflake", Palette.sky), ("leaf.fill", Palette.secondary)]
        }
    }

    var body: some View {
        // A ZStack so the chime runs even when no leaves are drawn (Reduce Motion).
        ZStack { leaves }.task {
            guard !cheered else { return }
            cheered = true
            CueSounds.shared.cheer()
        }
    }

    @ViewBuilder private var leaves: some View {
        if !reduceMotion && visible {
            let pieces = Self.pieces(Greetings.season(start, calendar: .current))
            let count = isBigDay ? 24 : 14
            TimelineView(.animation) { context in
                let t = context.date.timeIntervalSince(start)
                Canvas { graphics, size in
                    let resolved = pieces.map { piece in
                        var image = graphics.resolve(Image(systemName: piece.symbol))
                        image.shading = .color(piece.color)
                        return image
                    }
                    for index in 0..<count {
                        let seed = Double(index)
                        let x = size.width * ((seed * 0.137).truncatingRemainder(dividingBy: 1)) + sin(t * 2 + seed) * 18
                        let fall = 0.6 + (seed * 0.29).truncatingRemainder(dividingBy: 0.4)
                        let y = -30 + (size.height * 0.7) * min(1, t / 2) * fall
                        graphics.opacity = max(0, 1 - t / 2.2)
                        graphics.draw(resolved[index.isMultiple(of: 3) ? 1 : 0], at: CGPoint(x: x, y: y))
                    }
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .task {
                try? await Task.sleep(for: .seconds(2.3))
                visible = false
            }
        }
    }
}
