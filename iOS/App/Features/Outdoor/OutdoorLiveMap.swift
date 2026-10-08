import MapKit
import SwiftUI
import GentleWalkCore

/// The live map of an outdoor walk (30/09/2026, like a running app): the route drawn as she walks,
/// a start mark and her position, the map following her until she pans it ("Recenter" brings it
/// back), a tracking badge so she knows the walk is being recorded, and distance · time · steps
/// along the foot (steps, not a runner's pace: owner S1, 02/10/2026). The route never leaves the phone and is never shared.
struct OutdoorLiveMap: View {
    let route: [RoutePoint]
    /// GPS has a position (otherwise "Finding GPS…").
    let hasFix: Bool
    let miles: Double
    /// Session time so far.
    let seconds: Double
    /// Steps so far; nil when steps are not counted (the strip then shows two numbers).
    var steps: Int?
    var height: CGFloat = 320

    /// Before the first recorded point: the phone's own location, close up (never a whole country).
    @State private var position: MapCameraPosition = .userLocation(
        fallback: .camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 40.7812, longitude: -73.9665),
                                    distance: 1_500)))
    @State private var following = true

    private var coordinates: [CLLocationCoordinate2D] {
        route.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }

    var body: some View {
        Map(position: $position, interactionModes: [.pan, .zoom]) {
            if coordinates.count > 1 {
                // A white edge under the green line keeps it readable on any street colour.
                MapPolyline(coordinates: coordinates)
                    .stroke(.white, style: StrokeStyle(lineWidth: 9, lineCap: .round, lineJoin: .round))
                MapPolyline(coordinates: coordinates)
                    .stroke(Palette.secondary, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
            }
            if let start = coordinates.first {
                Annotation("Start", coordinate: start, anchor: .center) { StartMark() }
                    .annotationTitles(.hidden)
            }
            if let here = coordinates.last {
                Annotation("You", coordinate: here, anchor: .center) { HereMark() }
                    .annotationTitles(.hidden)
            } else {
                // No recorded point yet: the system's blue dot while GPS settles.
                UserAnnotation()
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .onMapCameraChange(frequency: .onEnd) { _ in
            // Her own pan or zoom stops the following until she taps Recenter.
            if position.positionedByUser { following = false }
        }
        .onChange(of: route.last?.timestamp) { follow() }
        .onAppear { follow() }
        .overlay(alignment: .topLeading) {
            TrackingBadge(hasFix: hasFix).padding(10)
        }
        .overlay(alignment: .topTrailing) {
            if !following, !coordinates.isEmpty {
                Button {
                    following = true
                    follow()
                } label: {
                    Label("Recenter", systemImage: "location.fill")
                        .typeRole(.caption).fontWeight(.semibold)
                        .foregroundStyle(Palette.text)
                        .padding(.horizontal, 12)
                        .frame(minHeight: 44)
                        .background(Palette.surface.opacity(0.95), in: .capsule)
                        .shadow(color: .black.opacity(0.12), radius: 4, y: 1)
                }
                .buttonStyle(.plain)
                .padding(10)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            LiveStatsStrip(miles: miles, seconds: seconds, steps: steps)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: min(180, height), maxHeight: height)
        .clipShape(.rect(cornerRadius: Metrics.cardRadius, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    /// Keeps her position in the middle, close enough to see the streets (about 600 m across).
    private func follow() {
        guard following, let here = coordinates.last else { return }
        withAnimation(.easeInOut(duration: 0.6)) {
            position = .camera(MapCamera(centerCoordinate: here, distance: 900))
        }
    }
}

/// "● Tracking your walk" (green, pulsing) or "Finding GPS…" (amber) on the map's corner.
struct TrackingBadge: View {
    let hasFix: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "circle.fill")
                .font(.system(size: 10))
                .foregroundStyle(hasFix ? Palette.secondary : Palette.sun)
                .symbolEffect(.pulse, options: .repeating, isActive: hasFix && !reduceMotion)
                .accessibilityHidden(true)
            Text(hasFix ? "Tracking your walk" : "Finding GPS…")
                .typeRole(.caption).fontWeight(.semibold)
                .foregroundStyle(Palette.text)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Palette.surface.opacity(0.95), in: .capsule)
        .shadow(color: .black.opacity(0.12), radius: 4, y: 1)
        .accessibilityElement(children: .combine)
    }
}

/// Distance · time · steps in large figures along the map's foot.
struct LiveStatsStrip: View {
    let miles: Double
    let seconds: Double
    var steps: Int?

    var body: some View {
        HStack(spacing: 0) {
            stat(CompleteContent.miles(miles), String(localized: "distance"))
            Divider().frame(height: 34)
            stat(WalkPlayerModel.clock(Int(seconds)), String(localized: "time"))
            if let steps {
                Divider().frame(height: 34)
                stat(steps.formatted(), String(localized: "steps"))
            }
        }
        .padding(.vertical, 10)
        .background(.regularMaterial)
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(verbatim: value).typeRole(.cardTitle).fontWeight(.bold).monospacedDigit()
                .foregroundStyle(Palette.text).lineLimit(1).minimumScaleFactor(0.7)
            Text(verbatim: label).typeRole(.caption).foregroundStyle(Palette.textMuted).lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

/// Where the walk began: a small sage ring.
private struct StartMark: View {
    var body: some View {
        Circle().fill(.white)
            .overlay { Circle().strokeBorder(Palette.secondary, lineWidth: 4) }
            .frame(width: 18, height: 18)
            .accessibilityHidden(true)
    }
}

/// Where she is now: a filled dot with a soft halo.
private struct HereMark: View {
    var body: some View {
        ZStack {
            Circle().fill(Palette.secondary.opacity(0.25)).frame(width: 40, height: 40)
            Circle().fill(Palette.secondary)
                .overlay { Circle().strokeBorder(.white, lineWidth: 3) }
                .frame(width: 20, height: 20)
        }
        .accessibilityHidden(true)
    }
}
