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

    @State private var feeling: Feeling?

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let level = content.reachedLevel {
                        LevelUpBadge(level: level)
                    }
                    ScreenHeaderText(title: content.title, subtitle: content.subtitle)
                    CompleteStats(minutes: content.minutes, milesText: content.milesText, milesLabel: content.milesLabel,
                                  activeDays: content.activeDays)
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
                }
                .padding(Metrics.screenMargin)
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
        }
        .cardStyle()
    }
}

/// "New postcard: Bethesda Fountain" · Open.
struct NewPostcardCard: View {
    let stop: Journey.Stop
    let onOpen: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            IllustrationPlaceholder(symbol: "photo.artframe", tint: Palette.sun, height: 72)
                .frame(width: 96)
            VStack(alignment: .leading, spacing: 2) {
                Text("New postcard").typeRole(.caption).foregroundStyle(Palette.textMuted)
                Text(verbatim: stop.name).typeRole(.cardTitle).foregroundStyle(Palette.text)
            }
            Spacer(minLength: 0)
            Button("Open", action: onOpen).buttonStyle(PillButtonStyle())
        }
        .cardStyle()
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

/// Tree level reached: big badge in the middle, "You reached Sprout".
struct LevelUpBadge: View {
    let level: TreeLevel

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: level.symbol)
                .font(.system(size: 64, weight: .regular))
                .foregroundStyle(Palette.secondary)
                .frame(width: 120, height: 120)
                .background(Palette.secondary.opacity(0.15), in: .circle)
                .accessibilityHidden(true)
            Text("You reached \(Text(level.title))").typeRole(.cardTitle).foregroundStyle(Palette.text)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Leaves drifting down for two seconds; nothing with Reduce Motion.
struct FallingLeaves: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date()
    @State private var visible = true

    var body: some View {
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
