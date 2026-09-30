import MapKit
import SwiftUI
import GentleWalkCore

/// Small map of the outdoor route on Complete, line in secondary. Never part of the share card.
struct RouteMapView: View {
    let route: [RoutePoint]

    var body: some View {
        let coordinates = route.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        Map(initialPosition: .automatic, interactionModes: []) {
            MapPolyline(coordinates: coordinates)
                .stroke(Palette.secondary, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .frame(height: 180)
        .clipShape(.rect(cornerRadius: Metrics.cardRadius))
        .accessibilityLabel(Text("Map of today's walk"))
    }
}

/// After an outdoor walk: "Your chair moves for today · 4 min" · Do them now · Later.
struct ChairMovesWaitingCard: View {
    let minutes: Int
    let onDoNow: () -> Void
    @State private var later = false

    var body: some View {
        if !later {
            VStack(alignment: .leading, spacing: 10) {
                Text("Your chair moves for today · \(minutes) min").typeRole(.cardTitle)
                HStack(spacing: Metrics.touchSpacing) {
                    Button("Do them now", action: onDoNow).buttonStyle(PillButtonStyle(isSelected: true))
                    Button("Later") { later = true }.buttonStyle(.textLink)
                }
                Text("You'll find them later in All sessions.").typeRole(.caption).foregroundStyle(Palette.textMuted)
            }
            .foregroundStyle(Palette.text)
            .cardStyle()
        }
    }
}
