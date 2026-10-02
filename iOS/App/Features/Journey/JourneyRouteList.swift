import SwiftUI
import GentleWalkCore

/// "Central Park to Brooklyn Bridge · 1.8 of 5 mi" with a bar for the whole route.
struct JourneyProgressCard: View {
    let journey: Journey
    let routeMiles: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let subtitle = journey.subtitle {
                Text(verbatim: subtitle).typeRole(.cardTitle)
            }
            Text(verbatim: String(localized: "\(JourneyProgressCard.number(routeMiles)) of \(CompleteContent.miles(journey.length, trimmed: true))"))
                .typeRole(.body)
            PhaseProgressBar(progress: journey.length > 0 ? routeMiles / journey.length : 0, tint: Palette.secondary)
        }
        .foregroundStyle(Palette.text)
        .cardStyle()
    }

    /// Miles as a bare number in the user's unit ("1.8" of "5 mi").
    static func number(_ value: Double) -> String { DistanceText.number(miles: value) }
}

/// The next postcard, softly shown, how far it is, a bar from the last stop, and "Start today's
/// session" when one is waiting.
struct NextStopCard: View {
    let stop: Journey.Stop
    let milesToGo: Double
    /// 0...1 from the previous stop to this one.
    let progress: Double
    let onWalk: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                PostcardThumb(stopID: stop.id, isSoft: true, width: 104, height: 84)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next stop").typeRole(.caption).foregroundStyle(Palette.textMuted)
                    Text(verbatim: stop.name).typeRole(.cardTitle).foregroundStyle(Palette.text)
                    Text(verbatim: String(localized: "\(CompleteContent.miles(milesToGo)) to go")).typeRole(.body).foregroundStyle(Palette.text)
                }
                Spacer(minLength: 0)
            }
            PhaseProgressBar(progress: progress, tint: Palette.sun)
            if let onWalk {
                Button("Start today's session", action: onWalk).buttonStyle(.secondaryAction)
            }
        }
        .cardStyle()
    }
}

/// "You walked the whole route." with the coach celebrating.
struct RouteDoneCard: View {
    var body: some View {
        HStack(spacing: 14) {
            ArtImage(art: .walkerCelebrate, height: 84).frame(width: 84)
            Text("You walked the whole route.").typeRole(.cardTitle).foregroundStyle(Palette.text)
            Spacer(minLength: 0)
        }
        .cardStyle()
    }
}

/// Every stop in order down a line: postcard, name, and where she stands with it.
struct RouteList: View {
    let journey: Journey
    let snapshot: JourneySnapshot
    let onPostcard: (Journey.Stop) -> Void
    /// A Pro stop: the plans, like any locked content (it was a dead tap; review 02/10/2026).
    var onLocked: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("The route").typeRole(.cardTitle).foregroundStyle(Palette.text).accessibilityAddTraits(.isHeader)
            VStack(spacing: 0) {
                ForEach(Array(journey.stops.enumerated()), id: \.element.id) { index, stop in
                    RouteRow(stop: stop, status: snapshot.status(of: stop), isFirst: index == 0,
                             isLast: index == journey.stops.count - 1,
                             lineDone: snapshot.status(of: journey.stops[min(index + 1, journey.stops.count - 1)]).isReached,
                             onLocked: onLocked) {
                        onPostcard(stop)
                    }
                }
            }
            .cardStyle(padding: 12)
        }
    }
}

private struct RouteRow: View {
    let stop: Journey.Stop
    let status: JourneySnapshot.StopStatus
    let isFirst: Bool
    let isLast: Bool
    /// The line down to the next stop is walked.
    let lineDone: Bool
    var onLocked: () -> Void = {}
    let onOpen: () -> Void

    var body: some View {
        // Only a reached stop opens its postcard: the others are still a reward to walk to (review D36).
        if status.isReached {
            Button(action: onOpen) { row }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
        } else if status == .locked {
            Button(action: onLocked) { row }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
        } else {
            row.accessibilityElement(children: .combine)
        }
    }

    private var row: some View {
            HStack(alignment: .center, spacing: 12) {
                RouteLine(isFirst: isFirst, isLast: isLast, status: status, lineDone: lineDone)
                PostcardThumb(stopID: stop.id, isSoft: !status.isReached, width: 64, height: 52)
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: stop.name).typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
                    Text(verbatim: detail).typeRole(.caption).foregroundStyle(Palette.textMuted)
                }
                Spacer(minLength: 0)
                switch status {
                case .reached: Image(systemName: "chevron.right").foregroundStyle(Palette.textMuted).accessibilityHidden(true)
                case .locked: ProBadge()
                case .next, .ahead: EmptyView()
                }
            }
            .frame(minHeight: 72)
            .contentShape(.rect)
    }

    private var detail: String {
        switch status {
        case .reached(let date?): String(localized: "Reached \(date.formatted(.dateTime.month(.abbreviated).day()))")
        case .reached(nil): String(localized: "Reached")
        case .next(let miles): String(localized: "\(CompleteContent.miles(miles)) to go")
        case .ahead: stop.mile == 0 ? String(localized: "Start") : String(localized: "Reach it at \(CompleteContent.miles(stop.mile))")
        case .locked: String(localized: "With Gentle Walk Pro · at \(CompleteContent.miles(stop.mile))")
        }
    }
}

/// The dot and the line through it; green where walked, a warm ring on the next stop.
private struct RouteLine: View {
    let isFirst: Bool
    let isLast: Bool
    let status: JourneySnapshot.StopStatus
    let lineDone: Bool

    private var reached: Bool { status.isReached }
    private var ring: Color {
        switch status {
        case .reached: Palette.secondary
        case .next: Palette.sun
        case .ahead, .locked: Palette.textMuted.opacity(0.5)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(isFirst ? .clear : (reached ? Palette.secondary : Palette.textMuted.opacity(0.3))).frame(width: 3)
            Circle()
                .fill(reached ? Palette.secondary : Palette.surface)
                .overlay { Circle().strokeBorder(ring, lineWidth: status == .ahead || status == .locked ? 2 : 3) }
                .frame(width: 14, height: 14)
            Rectangle().fill(isLast ? .clear : (lineDone ? Palette.secondary : Palette.textMuted.opacity(0.3))).frame(width: 3)
        }
        .frame(width: 16)
        .accessibilityHidden(true)
    }
}

/// A stop's postcard in a rounded frame; softer when not reached yet.
struct PostcardThumb: View {
    let stopID: String
    let isSoft: Bool
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ArtImage(name: Art.postcardName(stopID: stopID), fallbackName: Art.coverName(stopID: stopID), height: height)
            .frame(width: width)
            .saturation(isSoft ? 0.7 : 1)
            .overlay {
                RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
                    .fill(Palette.artPaper.opacity(isSoft ? 0.28 : 0))
            }
            .accessibilityHidden(true)
    }
}

extension JourneySnapshot.StopStatus {
    var isReached: Bool { if case .reached = self { true } else { false } }
}
