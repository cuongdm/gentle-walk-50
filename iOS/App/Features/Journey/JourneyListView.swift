import SwiftUI
import GentleWalkCore

/// All journeys (and "Where to next?" when the current one is done): five cards with Done,
/// In progress, Start or "First leg free", then "More journeys coming" (no monthly promise, review M19).
/// Switching asks first and says the current journey's progress is kept (clarity review D19).
struct JourneyListView: View {
    let journeys: [Journey]
    let snapshot: JourneySnapshot
    let isPro: Bool
    var isWhereToNext = false
    let onChoose: (Journey) -> Void

    @State private var pending: Journey?

    private var currentTitle: String? { journeys.first { $0.id == snapshot.journeyID }?.title }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Metrics.touchSpacing) {
                ScreenHeader(title: isWhereToNext ? "Where to next?" : "All journeys",
                             subtitle: isWhereToNext ? "You finished a whole route. Pick your next one." : nil)
                ForEach(journeys) { journey in
                    JourneyCard(journey: journey, status: status(of: journey), onChoose: {
                        if journey.id == snapshot.journeyID || currentTitle == nil { onChoose(journey) } else { pending = journey }
                    })
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("More journeys coming").typeRole(.cardTitle)
                    Text("Coming next: Route 66").typeRole(.body)
                }
                .foregroundStyle(Palette.text)
                .cardStyle()
            }
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        .screenBackground()
        .alert(Text(verbatim: pending.map { String(localized: "Start \($0.title)?") } ?? ""),
               isPresented: Binding(get: { pending != nil }, set: { if !$0 { pending = nil } }), presenting: pending) { journey in
            Button("Start") { onChoose(journey) }
            Button("Not now", role: .cancel) {}
        } message: { journey in
            Text(verbatim: switchMessage(to: journey))
        }
    }

    private func switchMessage(to journey: Journey) -> String {
        let kept = currentTitle.map { String(localized: "Your \($0) progress stays saved, and you can come back any time.") } ?? ""
        guard status(of: journey) == .firstLegFree, let end = JourneyAccess.freeLegEnd(of: journey) else { return kept }
        return String(localized: "The first leg, to \(end.name), is free.") + " " + kept
    }

    private func status(of journey: Journey) -> JourneyCard.Status {
        if snapshot.completedJourneys.contains(journey.id) { return .done }
        if journey.id == snapshot.journeyID { return .inProgress }
        return journey.isFree || isPro ? .start : .firstLegFree
    }
}

struct JourneyCard: View {
    enum Status { case done, inProgress, start, firstLegFree }

    let journey: Journey
    let status: Status
    let onChoose: () -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        // A finished route is not a button, but keeps full colour: `.disabled` greyed the
        // "Done" pill and title below readable contrast (review M5-D).
        if status == .done {
            card.accessibilityElement(children: .combine)
        } else {
            Button(action: onChoose) { card }
                .buttonStyle(.plain)
        }
    }

    @ViewBuilder private var card: some View {
        if typeSize.isAccessibilitySize { stacked } else { overlaid }
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
        case .done:
            // Words in text ink (a checked pair on the surface pill), the tick in sap green.
            Label {
                Text("Done").fontWeight(.semibold).foregroundStyle(Palette.text)
            } icon: {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(Palette.secondary)
            }
            .typeRole(.caption)
        case .inProgress: Text("In progress").typeRole(.caption).fontWeight(.semibold)
        case .start: Text("Start this journey").typeRole(.caption).fontWeight(.semibold)
        case .firstLegFree:
            HStack {
                if let end = JourneyAccess.freeLegEnd(of: journey) {
                    Text("First leg free · to \(end.name)").typeRole(.caption).fontWeight(.semibold)
                }
                ProBadge()
            }
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
                ShareLink(item: String(localized: "I walked to \(stop.name) with \(AppBrand.name).")) {
                    Text("Share")
                }
                .buttonStyle(.secondaryAction)
                Button("Close") { dismiss() }.buttonStyle(.textLink).frame(maxWidth: .infinity)
            }
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        .screenBackground()
    }
}
