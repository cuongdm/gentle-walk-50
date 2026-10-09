import SwiftUI
import GentleWalkCore

/// The 12 weeks are done (steady program task 4.14): what she did, her latest check against her first
/// one (only when done the same way), and two calm choices. No norms, no "you're now safe".
struct ProgramFinishedView: View {
    let summary: ProgramFinishedSummary
    let name: String?
    let onRestart: () -> Void
    let onKeepRoutine: () -> Void
    /// "Still the same goal? Change it in Me." (decision D13): goes to Me.
    var onChangeGoal: () -> Void = {}

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // The coach beside the title, so the two buttons, the link and the note all fit an
                // iPhone SE (plan 08/10/2026 task 1.16).
                HStack(alignment: .center, spacing: 12) {
                    ScreenHeaderText(title: name.map { String(localized: "12 weeks, \($0)!") } ?? String(localized: "12 weeks!"),
                                     subtitle: String(localized: "You kept going, at your own pace."))
                    if !typeSize.isAccessibilitySize {
                        ArtImage(art: .walkerCelebrate, height: 96).frame(width: 72).accessibilityHidden(true)
                    }
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: Plural.activeDays(summary.activeDays)).typeRole(.cardTitle)
                    if let first = summary.first, let latest = summary.latest, summary.checks > 1 {
                        Text(verbatim: String(localized: "Your 2-week check: \(first) at the start, \(latest) now."))
                            .typeRole(.body)
                        if let since = summary.sinceFirst, since > 0 {
                            Text(verbatim: String(localized: "+\(since) since your first check")).typeRole(.body).fontWeight(.semibold)
                        }
                        // With the numbers it is about (and in view on an iPhone SE).
                        SelfCheckDisclaimer()
                    }
                }
                .foregroundStyle(Palette.text)
                .cardStyle()
                // The plan and the journey as one story (plan 09/10/2026): where her minutes took her.
                if let route = summary.route, route.journeyMiles >= 0.05 {
                    WholeRouteCard(route: route)
                }
                // Two short lines that match the two buttons (plan 08/10/2026 task 1.16).
                VStack(alignment: .leading, spacing: 6) {
                    Text("What next?").typeRole(.cardTitle)
                    Label("Start again at week 1", systemImage: "arrow.counterclockwise")
                    Label("Or keep your plan as it is", systemImage: "calendar")
                }
                .typeRole(.body).foregroundStyle(Palette.text)
                Button("Still the same goal? Change it in Me.", action: onChangeGoal)
                    .buttonStyle(.smallTextLink)
                    // The 56 pt touch area keeps its size; only the empty space around the words shrinks.
                    .padding(.vertical, -8)
                if typeSize.isAccessibilitySize { actions }
            }
            .padding(.horizontal, Metrics.screenMargin)
            .padding(.top, 8)
            .padding(.bottom, Metrics.screenMargin)
            .readableColumn()
        }
        .pinnedActions(!typeSize.isAccessibilitySize) { actions }
        .screenBackground()
    }

    @ViewBuilder private var actions: some View {
        Button("Start a new 12 weeks", action: onRestart).buttonStyle(.primaryAction)
        Button("Keep my routine", action: onKeepRoutine).buttonStyle(.secondaryAction)
    }
}
