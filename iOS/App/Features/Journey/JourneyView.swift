import SwiftUI
import GentleWalkCore

/// S18 Journey (redesign 29/09/2026): the painted map with the route and postcards, how far
/// along she is, the next stop with Walk now, and every stop down a line.
struct JourneyView: View {
    let snapshot: JourneySnapshot
    let onAllJourneys: () -> Void
    let onPostcard: (Journey.Stop) -> Void
    let onSeePlans: () -> Void
    /// Start today's session; nil hides the button (rest day, or already done).
    var onWalkNow: (() -> Void)? = nil

    /// Height of the visible scroll area: on a short phone (SE, 667 pt) the map shrinks and the
    /// next-stop card moves above the progress card, so its button clears the tab bar (review M5-D).
    /// iPhone SE about 554 pt, mini about 635 pt; iPhone 11 and larger about 720 pt and up.
    @State private var viewportHeight: CGFloat = 0
    private var isShort: Bool { viewportHeight > 0 && viewportHeight < 680 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: isShort ? 12 : 16) {
                if let journey = snapshot.journey {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(verbatim: journey.title).typeRole(.screenTitle).foregroundStyle(Palette.text)
                            .accessibilityAddTraits(.isHeader)
                        Text("A shorter, gentle version of the real route. Every minute you move takes you further.").typeRole(.caption).foregroundStyle(Palette.textMuted)
                    }
                    JourneyMap(snapshot: snapshot, journey: journey, onPostcard: onPostcard, height: isShort ? 190 : 250)
                    if isShort {
                        nextStopCard(in: journey)
                        JourneyProgressCard(journey: journey, routeMiles: snapshot.routeMiles)
                    } else {
                        JourneyProgressCard(journey: journey, routeMiles: snapshot.routeMiles)
                        nextStopCard(in: journey)
                    }
                    RouteList(journey: journey, snapshot: snapshot, onPostcard: onPostcard, onLocked: onSeePlans)
                    Text("Outdoor walks count their real distance.")
                        .typeRole(.caption).foregroundStyle(Palette.textMuted)
                }
            }
            .padding(Metrics.screenMargin)
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { viewportHeight = $0 }
        .screenBackground()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("All journeys", action: onAllJourneys)
            }
        }
    }

    /// What comes next: the locked stop past the free leg, the next postcard, or the finished route.
    @ViewBuilder private func nextStopCard(in journey: Journey) -> some View {
        if snapshot.isLockedAhead, let next = snapshot.nextStop {
            LockedStopCard(stopName: next.name, onSeePlans: onSeePlans)
        } else if let next = snapshot.nextStop {
            NextStopCard(stop: next, milesToGo: snapshot.milesToNext, progress: legProgress(to: next, in: journey),
                         onWalk: onWalkNow)
        } else if snapshot.isComplete {
            RouteDoneCard()
        }
    }

    /// Share of the way from the last stop to the next one.
    private func legProgress(to next: Journey.Stop, in journey: Journey) -> Double {
        let previous = journey.stops.last { $0.mile < next.mile }?.mile ?? 0
        let span = next.mile - previous
        return span > 0 ? min(1, max(0, (snapshot.routeMiles - previous) / span)) : 0
    }
}

/// Free user at the end of the free leg: "Next stop: Clingmans Dome" · See Pro plans · Not now.
struct LockedStopCard: View {
    let stopName: String
    let onSeePlans: () -> Void
    @State private var dismissed = false

    var body: some View {
        if !dismissed {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Next stop: \(stopName)").typeRole(.cardTitle)
                    Spacer()
                    ProBadge()
                }
                Text("You walked the free leg. The rest of this route comes with \(AppBrand.name) Pro, and your distance keeps counting.").typeRole(.body)
                HStack(spacing: Metrics.touchSpacing) {
                    Button("See Pro plans", action: onSeePlans).buttonStyle(PillButtonStyle(isSelected: true))
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
