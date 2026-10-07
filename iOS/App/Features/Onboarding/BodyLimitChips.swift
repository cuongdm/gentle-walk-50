import SwiftUI
import GentleWalkCore

/// The body-limit choices of S06 and Me, in two short groups (owner 01/10: nine chips of every
/// length wrapped into a long, ragged list): joints as a two-column grid of equal buttons, the
/// everyday limits one per line, and "None of these" on its own at the end. The shapes tell the
/// groups apart, so they have no headings (the screen has to fit with Continue pinned). Columns
/// become a single list at accessibility text sizes.
struct BodyLimitChips: View {
    let selected: Set<BodyLimit>
    let onToggle: (BodyLimit) -> Void
    /// S06 only: "None of these" and whether it is chosen.
    var noneChosen: Bool? = nil
    var onNone: () -> Void = {}

    static let joints: [BodyLimit] = [.knees, .hips, .lowerBack, .shoulders, .jointReplacement, .noJumping]
    static let everyday: [BodyLimit] = [.noFloor, .standingIsHard, .dizzy, .unsteady]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Self.rows(Self.joints), id: \.first) { row in
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 8) { ForEach(row, id: \.self) { chip($0) } }
                    VStack(spacing: 8) { ForEach(row, id: \.self) { chip($0) } }
                }
            }
            ForEach(Self.everyday, id: \.self) { limit in
                chip(limit).padding(.top, limit == Self.everyday.first ? 8 : 0)
            }
            if let noneChosen {
                Button(action: onNone) { Text("None of these") }
                    .buttonStyle(PillButtonStyle(isSelected: noneChosen, fills: true))
                    .accessibilityAddTraits(noneChosen ? .isSelected : [])
                    .padding(.top, 6)
            }
        }
    }

    private func chip(_ limit: BodyLimit) -> some View {
        let isOn = selected.contains(limit)
        return Button { onToggle(limit) } label: { Text(OnboardingCopy.chip(limit)) }
            .buttonStyle(PillButtonStyle(isSelected: isOn, fills: true))
            .accessibilityAddTraits(isOn ? .isSelected : [])
    }

    /// Pairs for the two-column grid.
    static func rows(_ limits: [BodyLimit]) -> [[BodyLimit]] {
        stride(from: 0, to: limits.count, by: 2).map { Array(limits[$0..<min($0 + 2, limits.count)]) }
    }
}
