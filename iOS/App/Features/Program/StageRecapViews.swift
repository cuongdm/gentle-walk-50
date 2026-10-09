import SwiftUI
import GentleWalkCore

/// What she did in one stage, in plain lines (Today's stage card, the Program screen): days and time, journey
/// miles, the stops she reached (with a small strip of their postcards where asked), her latest check.
struct StageRecapLines: View {
    let recap: StageRecap
    var showsStrip = false

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // One line where it fits; days and time on lines of their own at accessibility sizes.
            if typeSize.isAccessibilitySize {
                Text(verbatim: Plural.activeDays(recap.activeDays)).typeRole(.body).fontWeight(.semibold)
                Text(verbatim: StageRecapText.moving(recap.activeSeconds)).typeRole(.body).fontWeight(.semibold)
            } else {
                Text(verbatim: StageRecapText.activity(recap)).typeRole(.body).fontWeight(.semibold)
            }
            if let miles = StageRecapText.miles(recap.journeyMiles, outdoor: recap.outdoorMiles) {
                Text(verbatim: miles).typeRole(.body)
            }
            if showsStrip { StageRouteStrip(stops: recap.stops) }
            if let stops = StageRecapText.stops(recap.stops) {
                Text(verbatim: stops).typeRole(.body)
            }
            if let check = recap.check {
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: StageRecapText.check(check)).typeRole(.body)
                    if let gain = StageRecapText.checkGain(check) {
                        Text(verbatim: gain).typeRole(.body).fontWeight(.semibold)
                    }
                }
            }
        }
        .foregroundStyle(Palette.text)
        .fixedSize(horizontal: false, vertical: true)
    }
}

/// Today: "Stage 1 is done: Steady base", the recap, which stage she is in now, "See my plan" and "Got it"
/// (inside `SpecialCard`, plan 09/10/2026). Recognition only: nothing unlocks, nothing changes by itself.
struct StageDoneCardContent: View {
    let recap: StageRecap
    let onSeePlan: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(verbatim: StageRecapText.doneTitle(recap.stage)).typeRole(.cardTitle)
                .accessibilityAddTraits(.isHeader)
            StageRecapLines(recap: recap)
            if let now = StageRecapText.nowIn(after: recap.stage) {
                Text(verbatim: now).typeRole(.body).foregroundStyle(Palette.text)
            }
            FlowLayout(spacing: Metrics.touchSpacing) {
                Button("See my plan", action: onSeePlan).buttonStyle(PillButtonStyle(isSelected: true))
                Button("Got it", action: onDismiss).buttonStyle(.textLink)
            }
        }
    }
}

/// Under a stage on the Program screen: "Done" or "So far", the recap with its postcards, and on the current
/// stage the next stop she can reach on her plan.
struct StageRecapBlock: View {
    let recap: StageRecap
    var route: RoutePosition? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle().fill(Palette.textMuted.opacity(0.25)).frame(height: 1).accessibilityHidden(true)
            header
            StageRecapLines(recap: recap, showsStrip: true)
            if let route, let next = StageRecapText.nextStop(route) {
                Text(verbatim: next).typeRole(.body).foregroundStyle(Palette.text)
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder private var header: some View {
        switch recap.status {
        case .done:
            Label {
                Text("Done")
            } icon: {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(Palette.secondary)
            }
            .typeRole(.caption).fontWeight(.semibold).foregroundStyle(Palette.text)
        case .soFar:
            Text("So far").typeRole(.caption).fontWeight(.semibold).foregroundStyle(Palette.text)
        }
    }
}

/// The postcards of the stops she reached, joined by the walked route's green line (as on the Journey list):
/// up to four, then "+2"; or, for a whole route (`spread`), four from the first to the last. Decorative: the
/// stop names are said in words beside it. Hidden at accessibility sizes.
struct StageRouteStrip: View {
    let stops: [StageRecap.Stop]
    var maxThumbs = 4
    /// First, last and evenly between, with no "+N" (the words say how many).
    var spread = false

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if !stops.isEmpty, !typeSize.isAccessibilitySize {
            HStack(spacing: 0) {
                ForEach(Array(shown.enumerated()), id: \.element.id) { index, stop in
                    if index > 0 {
                        Rectangle().fill(Palette.secondary).frame(width: 10, height: 3)
                    }
                    PostcardThumb(stopID: stop.stopID, isSoft: false, width: 56, height: 44)
                }
                if !spread, stops.count > maxThumbs {
                    Text(verbatim: "+\(stops.count - maxThumbs)")
                        .typeRole(.caption).fontWeight(.semibold).foregroundStyle(Palette.text)
                        .padding(.leading, 8)
                }
            }
            .padding(.vertical, 2)
            .accessibilityHidden(true)
        }
    }

    private var shown: [StageRecap.Stop] {
        guard stops.count > maxThumbs, maxThumbs > 1 else { return Array(stops.prefix(maxThumbs)) }
        guard spread else { return Array(stops.prefix(maxThumbs)) }
        let step = Double(stops.count - 1) / Double(maxThumbs - 1)
        return (0..<maxThumbs).map { stops[Int((Double($0) * step).rounded())] }
    }
}

/// The end of the 12 weeks: "Your whole route", its miles and stops, and from where to where.
struct WholeRouteCard: View {
    let route: RoundRecap

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            IconCardRow(icon: .journey) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your whole route").typeRole(.cardTitle).accessibilityAddTraits(.isHeader)
                    Text(verbatim: StageRecapText.wholeRoute(route)).typeRole(.body)
                    if let line = StageRecapText.fromTo(route) {
                        Text(verbatim: line).typeRole(.body)
                    }
                }
            }
            StageRouteStrip(stops: route.stops, maxThumbs: 4, spread: true)
        }
        .foregroundStyle(Palette.text)
        .cardStyle()
    }
}

/// Journey: "Your 12 weeks", the stops of this route by the stage of her plan she was in when she reached them.
/// Read-only and worked out from when each postcard opened.
struct JourneyStagesCard: View {
    let groups: [StageStops]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            IconCardRow(icon: .program, alignment: .center) {
                Text("Your 12 weeks").typeRole(.cardTitle).accessibilityAddTraits(.isHeader)
            }
            Text("The stage of your plan when you reached each stop.").typeRole(.caption).foregroundStyle(Palette.textMuted)
            ForEach(groups) { group in
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: StageRecapText.name(group.stage))
                        .typeRole(.caption).fontWeight(.semibold).foregroundStyle(Palette.accent)
                    Text(verbatim: StageRecapText.names(group.stops)).typeRole(.body).foregroundStyle(Palette.text)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .foregroundStyle(Palette.text)
        .cardStyle()
    }
}
