import SwiftUI
import GentleWalkCore

/// S18 map (redesign 29/09/2026): the journey's painting in full colour, a winding route along its
/// lower half with stops placed by their real mile, each stop shown as its own postcard, and the
/// coach's face where she is now.
struct JourneyMap: View {
    let snapshot: JourneySnapshot
    let journey: Journey
    let onPostcard: (Journey.Stop) -> Void

    private var fraction: Double {
        journey.length > 0 ? min(1, max(0, snapshot.routeMiles / journey.length)) : 0
    }

    var body: some View {
        GeometryReader { proxy in
            let rect = CGRect(origin: .zero, size: proxy.size)
            ZStack(alignment: .topLeading) {
                ArtImage(name: Art.coverName(journeyID: journey.id), height: proxy.size.height, fallbackSymbol: "map")
                // A soft shade at the foot so the route reads on any painting.
                LinearGradient(colors: [.clear, Palette.onLightFill.opacity(0.35)], startPoint: .center, endPoint: .bottom)
                    .clipShape(.rect(cornerRadius: Metrics.cardRadius, style: .continuous))
                RouteShape(upTo: 1)
                    .stroke(Palette.artPaper, style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [2, 9]))
                    .shadow(color: Palette.onLightFill.opacity(0.4), radius: 2)
                RouteShape(upTo: fraction)
                    .stroke(Palette.secondary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .shadow(color: Palette.onLightFill.opacity(0.3), radius: 2)
                ForEach(journey.stops) { stop in
                    StopNode(stop: stop, status: snapshot.status(of: stop), onOpen: { onPostcard(stop) })
                        .position(RouteShape.point(at: journey.length > 0 ? stop.mile / journey.length : 0, in: rect))
                }
                // A pin: label and face above the route, a short stem down to her spot, so the
                // face clears the stop nodes on either side.
                WalkerMarker(miles: snapshot.routeMiles)
                    .frame(width: 120, height: WalkerMarker.frameHeight, alignment: .bottom)
                    .position(RouteShape.point(at: fraction, in: rect)
                        .applying(.init(translationX: 0, y: -WalkerMarker.frameHeight / 2)))
                    .allowsHitTesting(false)
            }
        }
        .frame(height: 250)
        // Badges and the miles label live on a fixed-height painting; the list below carries
        // the same facts at full text size.
        .dynamicTypeSize(...DynamicTypeSize.xLarge)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("Map of \(journey.title)"))
    }
}

/// The route: a gentle wave across the lower half of the painting, drawn up to `upTo` (0...1).
struct RouteShape: Shape {
    var upTo: Double

    static let inset: CGFloat = 32

    static func point(at t: Double, in rect: CGRect) -> CGPoint {
        let x = rect.minX + inset + CGFloat(t) * (rect.width - 2 * inset)
        let y = rect.minY + rect.height * 0.70 + sin(CGFloat(t) * .pi * 2.4) * rect.height * 0.13
        return CGPoint(x: x, y: y)
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let steps = max(1, Int(upTo * 80))
        path.move(to: Self.point(at: 0, in: rect))
        for step in 1...steps {
            path.addLine(to: Self.point(at: upTo * Double(step) / Double(steps), in: rect))
        }
        return path
    }
}

/// A stop on the map: its postcard in a ring once reached, a softer postcard with a warm ring for
/// the next one, a small dot further on, a small lock past the free plan.
struct StopNode: View {
    let stop: Journey.Stop
    let status: JourneySnapshot.StopStatus
    let onOpen: () -> Void

    var body: some View {
        switch status {
        case .reached:
            Button(action: onOpen) {
                PostcardCircle(stopID: stop.id, size: 42, isSoft: false)
                    .overlay { Circle().strokeBorder(Palette.artPaper, lineWidth: 3) }
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Palette.onStrongFill, Palette.secondary)
                            .offset(x: 3, y: 3)
                    }
                    .frame(width: 48, height: 48)
                    .contentShape(.circle)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Postcard: \(stop.name)"))
        case .next:
            PostcardCircle(stopID: stop.id, size: 38, isSoft: true)
                .overlay { Circle().strokeBorder(Palette.sun, lineWidth: 3) }
                .shadow(color: Palette.sun.opacity(0.6), radius: 6)
                .accessibilityLabel(Text("Next stop: \(stop.name)"))
        case .ahead:
            Circle().fill(Palette.artPaper)
                .overlay { Circle().strokeBorder(Palette.secondary, lineWidth: 2) }
                .frame(width: 14, height: 14)
                .accessibilityLabel(Text("\(stop.name), not reached yet"))
        case .locked:
            Image(systemName: "lock.fill")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Palette.text.opacity(0.7))
                .frame(width: 20, height: 20)
                .background(Palette.artPaper, in: .circle)
                .accessibilityLabel(Text("\(stop.name), part of Gentle Walk Pro"))
        }
    }
}

/// A stop's postcard cropped to a circle (its journey cover until the postcard is painted).
struct PostcardCircle: View {
    let stopID: String
    let size: CGFloat
    /// Not reached yet: softer colour under a light paper veil.
    let isSoft: Bool

    var body: some View {
        ArtImage(name: Art.postcardName(stopID: stopID), fallbackName: Art.coverName(stopID: stopID), height: size)
            .frame(width: size)
            .saturation(isSoft ? 0.7 : 1)
            .overlay { Circle().fill(Palette.artPaper.opacity(isSoft ? 0.25 : 0)) }
            .clipShape(.circle)
    }
}

/// The coach's face on the route with how far she is: "1.8 mi".
struct WalkerMarker: View {
    let miles: Double

    /// Tall enough for label, face and stem at any text size the map shows.
    static let frameHeight: CGFloat = 200

    var body: some View {
        VStack(spacing: 0) {
            Text(verbatim: String(localized: "You · \(CompleteContent.miles(miles, trimmed: true))"))
                .typeRole(.caption).fontWeight(.bold)
                .foregroundStyle(Palette.onLightFill)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Palette.artPaper, in: .capsule)
                .padding(.bottom, 3)
            Image(Art.walkerWave.rawValue)
                .resizable()
                .scaledToFit()
                .frame(width: 104)
                // The head sits at the top of the painting: keep that part in the circle.
                .frame(width: 46, height: 46, alignment: .top)
                .background(Palette.artPaper)
                .clipShape(.circle)
                .overlay { Circle().strokeBorder(Palette.artPaper, lineWidth: 3) }
                .shadow(color: Palette.onLightFill.opacity(0.3), radius: 4, y: 2)
            Capsule().fill(Palette.artPaper).frame(width: 3, height: 26)
            Circle().fill(Palette.secondary)
                .overlay { Circle().strokeBorder(Palette.artPaper, lineWidth: 2) }
                .frame(width: 10, height: 10)
                .offset(y: 5)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("You are here, \(CompleteContent.miles(miles, trimmed: true))"))
    }
}
