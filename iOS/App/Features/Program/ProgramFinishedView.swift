import SwiftUI
import GentleWalkCore

/// The 12 weeks are done (steady program task 4.14): what she did, her latest check against her first
/// one (only when done the same way), and two calm choices. No norms, no "you're now safe".
struct ProgramFinishedView: View {
    let summary: ProgramFinishedSummary
    let name: String?
    let onRestart: () -> Void
    let onKeepRoutine: () -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ArtImage(art: .walkerCelebrate, height: 170).accessibilityHidden(true)
                ScreenHeaderText(title: name.map { String(localized: "12 weeks, \($0)!") } ?? String(localized: "12 weeks!"),
                                 subtitle: String(localized: "You kept going, at your own pace."))
                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: Plural.activeDays(summary.activeDays)).typeRole(.cardTitle)
                    if let first = summary.first, let latest = summary.latest, summary.checks > 1 {
                        Text(verbatim: String(localized: "Your 2-week check: \(first) at the start, \(latest) now."))
                            .typeRole(.body)
                        if let since = summary.sinceFirst, since > 0 {
                            Text(verbatim: String(localized: "+\(since) since your first check")).typeRole(.body).fontWeight(.semibold)
                        }
                    }
                }
                .foregroundStyle(Palette.text)
                .cardStyle()
                Text("What next? Start a new 12 weeks from week 1, or keep your weekly plan as it is. Your 2-week checks go on either way.")
                    .typeRole(.body).foregroundStyle(Palette.text)
                SelfCheckDisclaimer()
                if typeSize.isAccessibilitySize { actions }
            }
            .padding(Metrics.screenMargin)
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
