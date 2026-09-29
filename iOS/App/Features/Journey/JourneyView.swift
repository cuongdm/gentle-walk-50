import SwiftUI
import GentleWalkCore

/// S18 Journey: hand-drawn map (placeholder), where you are, the next stop, postcards.
struct JourneyView: View {
    let snapshot: JourneySnapshot
    let onAllJourneys: () -> Void
    let onPostcard: (Journey.Stop) -> Void
    let onSeePlans: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let journey = snapshot.journey {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(verbatim: journey.title).typeRole(.screenTitle).foregroundStyle(Palette.text)
                                .accessibilityAddTraits(.isHeader)
                            Text("A gentle version of the route").typeRole(.caption).foregroundStyle(Palette.textMuted)
                        }
                        Spacer()
                    }
                    JourneyMap(journey: journey, miles: snapshot.routeMiles, unlocked: snapshot.unlocked)
                    JourneyInfoCard(journey: journey, snapshot: snapshot)
                    if snapshot.isLockedAhead, let next = snapshot.nextStop {
                        LockedStopCard(stopName: next.name, onSeePlans: onSeePlans)
                    }
                    PostcardRow(journey: journey, unlocked: snapshot.unlocked, onOpen: onPostcard)
                    Text("Every minute you move in the app takes you further. Outdoor walks count their real distance.")
                        .typeRole(.body).foregroundStyle(Palette.text)
                }
            }
            .padding(Metrics.screenMargin)
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .screenBackground()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("All journeys", action: onAllJourneys)
            }
        }
    }
}

/// Dashed route with six stops and a little walker at the current mile, over the journey cover.
struct JourneyMap: View {
    let journey: Journey
    let miles: Double
    let unlocked: Set<String>

    var body: some View {
        GeometryReader { proxy in
            let points = stopPoints(in: proxy.size)
            ZStack {
                // The journey's cover, washed out on paper so the route and stops stay easy to see.
                ArtImage(name: Art.coverName(journeyID: journey.id), height: proxy.size.height, fallbackSymbol: "map")
                    .overlay {
                        RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
                            .fill(Palette.artPaper.opacity(0.55))
                    }
                Path { path in
                    guard let first = points.first else { return }
                    path.move(to: first)
                    points.dropFirst().forEach { path.addLine(to: $0) }
                }
                .stroke(Palette.secondary, style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [8, 8]))
                ForEach(Array(zip(journey.stops, points)), id: \.0.id) { stop, point in
                    Circle()
                        .fill(unlocked.contains(stop.id) ? Palette.secondary : Palette.surface)
                        .overlay { Circle().strokeBorder(Palette.secondary, lineWidth: 3) }
                        .frame(width: 22, height: 22)
                        .position(point)
                }
                Image(systemName: "figure.walk.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(Palette.primary, Palette.surface)
                    .position(walkerPoint(points))
            }
        }
        .frame(height: 220)
        .accessibilityElement()
        .accessibilityLabel(Text("Map of \(journey.title)"))
    }

    private func stopPoints(in size: CGSize) -> [CGPoint] {
        let count = max(1, journey.stops.count - 1)
        return journey.stops.enumerated().map { index, _ in
            let x = 30 + (size.width - 60) * CGFloat(index) / CGFloat(count)
            let y = size.height * (index.isMultiple(of: 2) ? 0.65 : 0.35)
            return CGPoint(x: x, y: y)
        }
    }

    private func walkerPoint(_ points: [CGPoint]) -> CGPoint {
        let stops = journey.stops
        guard let first = points.first else { return .zero }
        for index in stops.indices.dropLast() where miles >= stops[index].mile && miles <= stops[index + 1].mile {
            let span = max(0.0001, stops[index + 1].mile - stops[index].mile)
            let t = (miles - stops[index].mile) / span
            let a = points[index], b = points[index + 1]
            return CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t - 26)
        }
        return miles > 0 ? CGPoint(x: points.last!.x, y: points.last!.y - 26) : CGPoint(x: first.x, y: first.y - 26)
    }
}

/// "Central Park to Brooklyn Bridge · 1.8 of 5 mi · Next stop: Times Square · 0.4 mi".
struct JourneyInfoCard: View {
    let journey: Journey
    let snapshot: JourneySnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let subtitle = journey.subtitle {
                Text(verbatim: subtitle).typeRole(.cardTitle)
            }
            Text(verbatim: String(localized: "\(Self.number(snapshot.routeMiles)) of \(CompleteContent.miles(journey.length, trimmed: true))"))
                .typeRole(.body)
            if let next = snapshot.nextStop {
                Text(verbatim: String(localized: "Next stop: \(next.name) · \(CompleteContent.miles(snapshot.milesToNext))"))
                    .typeRole(.body).fontWeight(.semibold)
            } else if snapshot.isComplete {
                Text("You walked the whole route.").typeRole(.body).fontWeight(.semibold)
            }
        }
        .foregroundStyle(Palette.text)
        .cardStyle()
    }

    static func number(_ value: Double) -> String { value.formatted(.number.precision(.fractionLength(0...1))) }
}

/// Opened postcards in colour, the rest as soft frames with the place name.
struct PostcardRow: View {
    let journey: Journey
    let unlocked: Set<String>
    let onOpen: (Journey.Stop) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Postcards").typeRole(.cardTitle).foregroundStyle(Palette.text)
            ScrollView(.horizontal) {
                HStack(spacing: Metrics.touchSpacing) {
                    ForEach(journey.stops) { stop in
                        let open = unlocked.contains(stop.id)
                        Button { if open { onOpen(stop) } } label: {
                            VStack(spacing: 6) {
                                ArtImage(name: Art.postcardName(stopID: stop.id), fallbackName: Art.coverName(stopID: stop.id), height: 96)
                                    // Not reached yet: still in colour, just softer, so it tempts
                                    // rather than greys out; a small lock in the corner.
                                    .saturation(open ? 1 : 0.7)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
                                            .fill(Palette.artPaper.opacity(open ? 0 : 0.28))
                                    }
                                    .overlay(alignment: .bottomTrailing) { if !open { LockBadge().padding(6) } }
                                    .frame(width: 128)
                                Text(verbatim: stop.name).typeRole(.caption).foregroundStyle(Palette.text)
                                    .multilineTextAlignment(.center).frame(width: 128)
                            }
                        }
                        .buttonStyle(.plain)
                        // No `.disabled`: it would grey out the whole card; a tap on a locked one does nothing.
                        .accessibilityLabel(open ? Text("Postcard: \(stop.name)") : Text("\(stop.name), not reached yet"))
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

/// Free user at a locked stop: "Keep going to Laurel Falls" · See plans · Not now. Miles still count.
struct LockedStopCard: View {
    let stopName: String
    let onSeePlans: () -> Void
    @State private var dismissed = false

    var body: some View {
        if !dismissed {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Keep going to \(stopName)").typeRole(.cardTitle)
                    Spacer()
                    ProBadge()
                }
                Text("Your miles keep counting. The rest of this route comes with Gentle Walk Pro.").typeRole(.body)
                HStack(spacing: Metrics.touchSpacing) {
                    Button("See plans", action: onSeePlans).buttonStyle(PillButtonStyle(isSelected: true))
                    Button("Not now") { dismissed = true }.buttonStyle(.textLink)
                }
            }
            .foregroundStyle(Palette.text)
            .cardStyle()
        }
    }
}

/// Lock over a postcard that is not reached yet (the painting shows in grey underneath).
/// A small, light lock on a postcard she has not reached yet.
struct LockBadge: View {
    var body: some View {
        Image(systemName: "lock.fill")
            .font(.caption.weight(.semibold))
            .foregroundStyle(Palette.text.opacity(0.75))
            .padding(7)
            .background(Palette.surface.opacity(0.7), in: .circle)
            .accessibilityHidden(true)
    }
}
