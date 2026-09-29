import SwiftUI
import GentleWalkCore

/// All journeys (and "Where to next?" when the current one is done): five cards with Done,
/// In progress, Start or First stop free, then "More journeys coming" (no monthly promise, review M19).
struct JourneyListView: View {
    let journeys: [Journey]
    let snapshot: JourneySnapshot
    let isPro: Bool
    var isWhereToNext = false
    let onChoose: (Journey) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Metrics.touchSpacing) {
                ScreenHeader(title: isWhereToNext ? "Where to next?" : "All journeys",
                             subtitle: isWhereToNext ? "You finished a whole route. Pick your next one." : nil)
                ForEach(journeys) { journey in
                    JourneyCard(journey: journey, status: status(of: journey), onChoose: { onChoose(journey) })
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("More journeys coming").typeRole(.cardTitle)
                    Text("Coming next: Route 66").typeRole(.body)
                }
                .foregroundStyle(Palette.text)
                .cardStyle()
            }
            .padding(Metrics.screenMargin)
        }
        .screenBackground()
    }

    private func status(of journey: Journey) -> JourneyCard.Status {
        if snapshot.completedJourneys.contains(journey.id) { return .done }
        if journey.id == snapshot.journeyID { return .inProgress }
        return journey.isFree || isPro ? .start : .firstStopFree
    }
}

struct JourneyCard: View {
    enum Status { case done, inProgress, start, firstStopFree }

    let journey: Journey
    let status: Status
    let onChoose: () -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        Button(action: onChoose) {
            if typeSize.isAccessibilitySize { stacked } else { overlaid }
        }
        .buttonStyle(.plain)
        .disabled(status == .done)
    }

    /// Accessibility text sizes: the words below the cover, where they can grow.
    private var stacked: some View {
        VStack(alignment: .leading, spacing: 10) {
            ArtImage(name: Art.coverName(journeyID: journey.id), height: 150)
            Text(verbatim: journey.title).typeRole(.cardTitle).multilineTextAlignment(.leading)
            if let subtitle = journey.subtitle { Text(verbatim: subtitle).typeRole(.body) }
            statusLabel
        }
        .foregroundStyle(Palette.text)
        .cardStyle(padding: 10)
    }

    private var overlaid: some View {
            // The cover fills the card; the words sit on a dark scrim at its foot so white text keeps
            // its contrast over any painting. The status badge rides on a light pill at the top.
            ArtImage(name: Art.coverName(journeyID: journey.id), height: 190)
                .overlay {
                    LinearGradient(colors: [.clear, Palette.onLightFill.opacity(0.75)], startPoint: .center, endPoint: .bottom)
                        .clipShape(.rect(cornerRadius: Metrics.cardRadius, style: .continuous))
                }
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(verbatim: journey.title).typeRole(.cardTitle).fontWeight(.bold)
                            .multilineTextAlignment(.leading)
                        if let subtitle = journey.subtitle { Text(verbatim: subtitle).typeRole(.body) }
                    }
                    .foregroundStyle(Palette.onStrongFill)
                    .shadow(color: Palette.onLightFill.opacity(0.5), radius: 3)
                    .padding(16)
                }
                .overlay(alignment: .topLeading) {
                    statusLabel
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .foregroundStyle(Palette.text)
                        .background(Palette.surface, in: .capsule)
                        .padding(12)
                }
    }

    @ViewBuilder private var statusLabel: some View {
        switch status {
        case .done: Label("Done", systemImage: "checkmark.circle.fill").typeRole(.caption).foregroundStyle(Palette.secondary)
        case .inProgress: Text("In progress").typeRole(.caption).fontWeight(.semibold)
        case .start: Text("Start this journey").typeRole(.caption).fontWeight(.semibold)
        case .firstStopFree:
            HStack { Text("First stop free").typeRole(.caption); ProBadge() }
        }
    }
}

/// Postcard detail: big picture, two lines about the place, a warm line from the coach.
struct PostcardDetailView: View {
    let stop: Journey.Stop
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ArtImage(name: Art.postcardName(stopID: stop.id), fallbackName: Art.coverName(stopID: stop.id), height: 260)
                Text(verbatim: stop.name).typeRole(.screenTitle).foregroundStyle(Palette.text)
                if let back = stop.back { Text(verbatim: back).typeRole(.body).foregroundStyle(Palette.text) }
                if let coach = stop.coachLine {
                    Text(verbatim: coach).typeRole(.cardTitle).italic().foregroundStyle(Palette.text)
                }
                ShareLink(item: String(localized: "I walked to \(stop.name) with Gentle Walk.")) {
                    Text("Share")
                }
                .buttonStyle(.secondaryAction)
                Button("Close") { dismiss() }.buttonStyle(.textLink).frame(maxWidth: .infinity)
            }
            .padding(Metrics.screenMargin)
        }
        .screenBackground()
    }
}
