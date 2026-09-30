import SwiftUI
import GentleWalkCore

/// "6 of 14 active days to Sapling" over a bar: the way to the next tree level, counted from the
/// last one, never a streak (competitor idea 5, 30/09/2026). After the tree: the next year ring.
struct TreeMilestoneLine: View {
    let activeDays: Int

    var body: some View {
        if let milestone = TreeLevel.milestone(activeDays: activeDays) {
            VStack(alignment: .leading, spacing: 6) {
                Text(verbatim: Self.text(milestone)).typeRole(.body).foregroundStyle(Palette.text)
                PhaseProgressBar(progress: Double(milestone.done) / Double(max(1, milestone.total)), tint: Palette.secondary)
            }
            .accessibilityElement(children: .combine)
        }
    }

    static func text(_ milestone: TreeLevel.Milestone) -> String {
        if let next = milestone.next {
            return String(localized: "\(milestone.done) of \(milestone.total) active days to \(String(localized: next.title))")
        }
        return String(localized: "\(milestone.done) of \(milestone.total) active days to the next ring")
    }
}
