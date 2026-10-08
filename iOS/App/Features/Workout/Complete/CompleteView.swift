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
                                 isCalm: content.variant == .stoppedForPain)
                    CompleteStats(minutes: content.minutes, milesText: content.milesText, milesLabel: content.milesLabel,
                                  activeDays: content.activeDays)
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
                    CompleteFootnote(activeDays: content.activeDays, journeyLine: content.journeyLine,
                                     journeyProgress: content.journeyProgress)
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
            if content.variant != .stoppedForPain { FallingLeaves() }
        }
        .screenBackground()
    }
}

/// Three numbers side by side; stacked at accessibility text sizes.
struct CompleteStats: View {
    let minutes: Int
    let milesText: String
    let milesLabel: String
    let activeDays: Int

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        let layout = typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(spacing: 10)) : AnyLayout(HStackLayout(spacing: 10))
        layout {
            StatTile(value: String(localized: "\(minutes) min"), label: String(localized: "moving"))
            StatTile(value: milesText, label: milesLabel)
            StatTile(value: "\(activeDays)", label: Plural.activeDaysLabel(activeDays))
        }
    }
}

private struct StatTile: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(verbatim: value).typeRole(.cardTitle).fontWeight(.bold).foregroundStyle(Palette.text)
                .lineLimit(1).minimumScaleFactor(0.7)
            Text(verbatim: label).typeRole(.caption).foregroundStyle(Palette.textMuted)
        }
        .frame(maxWidth: .infinity, minHeight: 70)
        .background(Palette.surface, in: .rect(cornerRadius: Metrics.cardRadius))
        .accessibilityElement(children: .combine)
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

/// One quiet card under the feeling question (task 1.9): the tree line ("1 of 7 active days to Sprout")
/// and the journey line ("0.3 of 5 mi · 0.7 mi to Bethesda Fountain"), with why any session counts.
struct CompleteFootnote: View {
    let activeDays: Int
    let journeyLine: String?
    let journeyProgress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let milestone = TreeLevel.milestone(activeDays: activeDays) {
                Label { Text(verbatim: TreeMilestoneLine.text(milestone)) } icon: {
                    Image(systemName: "leaf.fill").foregroundStyle(Palette.secondary)
                }
            }
            if let journeyLine {
                Label { Text(verbatim: journeyLine) } icon: {
                    Image(systemName: "map.fill").foregroundStyle(Palette.secondary)
                }
                ProgressView(value: journeyProgress).tint(Palette.secondary).accessibilityHidden(true)
                // Why a chair session moves the journey (clarity review D16).
                Text("Every minute you move takes you further on your journey.").foregroundStyle(Palette.textMuted)
            }
        }
        .typeRole(.caption)
        .foregroundStyle(Palette.text)
        .accessibilityElement(children: .combine)
        .cardStyle(padding: 12)
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
                if let level {
                    Text("You reached \(Text(level.title)). Your tree grows with every active day.").typeRole(.body)
                        .fontWeight(.semibold).foregroundStyle(Palette.secondary)
                }
                ScreenHeaderText(title: title, subtitle: subtitle)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// Leaves drifting down for two seconds with a short happy chime; the chime alone with Reduce Motion.
struct FallingLeaves: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date()
    @State private var visible = true
    @State private var cheered = false

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
            TimelineView(.animation) { context in
                let t = context.date.timeIntervalSince(start)
                Canvas { graphics, size in
                    for index in 0..<14 {
                        let seed = Double(index)
                        let x = size.width * ((seed * 0.137).truncatingRemainder(dividingBy: 1)) + sin(t * 2 + seed) * 18
                        let fall = 0.6 + (seed * 0.29).truncatingRemainder(dividingBy: 0.4)
                        let y = -30 + (size.height * 0.7) * min(1, t / 2) * fall
                        let symbol = graphics.resolve(Image(systemName: index.isMultiple(of: 3) ? "camera.macro" : "leaf.fill"))
                        graphics.opacity = max(0, 1 - t / 2.2)
                        graphics.draw(symbol, at: CGPoint(x: x, y: y))
                    }
                }
                .foregroundStyle(Palette.secondary)
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
