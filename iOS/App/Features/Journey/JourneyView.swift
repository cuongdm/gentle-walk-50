import SwiftUI
import GentleWalkCore

/// S18 Journey (redesign 29/09/2026): the painted map with the route and postcards, how far
/// along she is, the next stop with Walk now, and every stop down a line.
struct JourneyView: View {
    let snapshot: JourneySnapshot
    let onAllJourneys: () -> Void
    let onPostcard: (Journey.Stop) -> Void
    let onSeePlans: () -> Void
    var onWalkNow: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let journey = snapshot.journey {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(verbatim: journey.title).typeRole(.screenTitle).foregroundStyle(Palette.text)
                            .accessibilityAddTraits(.isHeader)
                        Text("A gentle version of the route").typeRole(.caption).foregroundStyle(Palette.textMuted)
                    }
                    JourneyMap(snapshot: snapshot, journey: journey, onPostcard: onPostcard)
                    JourneyProgressCard(journey: journey, routeMiles: snapshot.routeMiles)
                    if snapshot.isLockedAhead, let next = snapshot.nextStop {
                        LockedStopCard(stopName: next.name, onSeePlans: onSeePlans)
                    } else if let next = snapshot.nextStop {
                        NextStopCard(stop: next, milesToGo: snapshot.milesToNext, progress: legProgress(to: next, in: journey),
                                     onWalk: onWalkNow)
                    } else if snapshot.isComplete {
                        RouteDoneCard()
                    }
                    RouteList(journey: journey, snapshot: snapshot, onPostcard: onPostcard)
                    Text("Every minute you move in the app takes you further. Outdoor walks count their real distance.")
                        .typeRole(.caption).foregroundStyle(Palette.textMuted)
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

    /// Share of the way from the last stop to the next one.
    private func legProgress(to next: Journey.Stop, in journey: Journey) -> Double {
        let previous = journey.stops.last { $0.mile < next.mile }?.mile ?? 0
        let span = next.mile - previous
        return span > 0 ? min(1, max(0, (snapshot.routeMiles - previous) / span)) : 0
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
