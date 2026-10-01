import SwiftUI
import GentleWalkCore

/// S15 Workout complete. Fixed order: leaves (2 s), title, three numbers, self comparison,
/// journey bar, new postcard, "How did that feel?", Done and Share with family.
struct CompleteView: View {
    let content: CompleteContent
    let onFeeling: (Feeling) -> Void
    let onDone: () -> Void
    var onOpenPostcard: (Journey.Stop) -> Void = { _ in }
    /// Outdoors with GPS: the route map (not shared).
    var route: [RoutePoint] = []
    /// Outdoors: today's chair moves are still waiting (minutes), with "Do them now".
    var chairMovesMinutes: Int?
    var onChairMoves: () -> Void = {}
    /// "Do it again" (milestone 10); nil when this session cannot be replayed on her plan.
    var onAgain: (() -> Void)?

    @State private var feeling: Feeling?

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    CompleteHero(title: content.title, subtitle: content.subtitle, level: content.reachedLevel)
                    CompleteStats(minutes: content.minutes, milesText: content.milesText, milesLabel: content.milesLabel,
                                  activeDays: content.activeDays)
                    TreeMilestoneLine(activeDays: content.activeDays)
                        .cardStyle()
                    if route.count > 1 {
                        RouteMapView(route: route)
                    }
                    if let comparison = content.comparison {
                        Text(verbatim: comparison).typeRole(.body).foregroundStyle(Palette.text)
                    }
                    if let line = content.journeyLine {
                        JourneyProgressBar(line: line, progress: content.journeyProgress)
                    }
                    if let stop = content.newPostcard {
                        NewPostcardCard(stop: stop, onOpen: { onOpenPostcard(stop) })
                    }
                    if let chairMovesMinutes {
                        ChairMovesWaitingCard(minutes: chairMovesMinutes, onDoNow: onChairMoves)
                    }
                    FeelingQuestion(selection: feeling) { value in
                        feeling = value
                        onFeeling(value)
                    }
                    Button("Done", action: onDone).buttonStyle(.primaryAction)
                    ShareCardButton(content: content)
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
            FallingLeaves()
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
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(Palette.surface, in: .rect(cornerRadius: Metrics.cardRadius))
        .accessibilityElement(children: .combine)
    }
}

/// "2.6 mi to Brooklyn Bridge" over a secondary progress bar.
struct JourneyProgressBar: View {
    let line: String
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(verbatim: line).typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
            ProgressView(value: progress).tint(Palette.secondary).scaleEffect(x: 1, y: 2, anchor: .center)
                .accessibilityHidden(true)
            // Why a chair session moves the journey (clarity review D16).
            Text("Every minute you move adds miles to your journey.").typeRole(.caption).foregroundStyle(Palette.textMuted)
        }
        .cardStyle()
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
            FlowLayout(spacing: Metrics.touchSpacing) {
                option(.tooEasy, "Too easy")
                option(.justRight, "Just right")
                option(.tooHard, "Too hard")
            }
            if selection != nil {
                Text("Got it. We'll adjust tomorrow.").typeRole(.body).foregroundStyle(Palette.text)
            }
        }
    }

    private func option(_ feeling: Feeling, _ title: LocalizedStringResource) -> some View {
        Button { onSelect(feeling) } label: { Text(title) }
            .buttonStyle(PillButtonStyle(isSelected: selection == feeling))
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
                ArtImage(art: .walkerCelebrate, height: 132).frame(width: 110)
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
