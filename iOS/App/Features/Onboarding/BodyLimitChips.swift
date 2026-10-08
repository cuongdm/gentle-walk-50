import SwiftUI
import GentleWalkCore

/// Body cards (Claude Design "Sore spots", owner 08/10/2026): a two-tone figure drawn for each choice
/// (`LayeredIcon`), two columns of 62 pt cards, an odd last card across the row, and "None of these"
/// with a dashed border and no icon. Onboarding shows one group per screen (Sore spots, Anything
/// else); Me shows both. One column at accessibility text sizes.
struct BodyLimitChips: View {
    let limits: [BodyLimit]
    let selected: Set<BodyLimit>
    let onToggle: (BodyLimit) -> Void
    /// Onboarding only: "None of these" and whether it is chosen.
    var noneChosen: Bool? = nil
    var onNone: () -> Void = {}

    /// Sore spots (onboarding step 6) and everything else (step 7); together every limit once.
    static let soreSpots: [BodyLimit] = [.knees, .hips, .lowerBack, .shoulders, .jointReplacement]
    static let everyday: [BodyLimit] = [.noFloor, .standingIsHard, .dizzy, .unsteady, .noJumping]

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(spacing: 10) {
            ForEach(rows, id: \.first) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { limit in
                        BodyChoiceCard(limit: limit, isSelected: selected.contains(limit)) { onToggle(limit) }
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            if let noneChosen {
                NoneOfTheseButton(isSelected: noneChosen, action: onNone)
            }
        }
    }

    /// Pairs for the two columns; one per row at accessibility sizes.
    private var rows: [[BodyLimit]] {
        typeSize.isAccessibilitySize ? limits.map { [$0] } : Self.rows(limits)
    }

    static func rows(_ limits: [BodyLimit]) -> [[BodyLimit]] {
        stride(from: 0, to: limits.count, by: 2).map { Array(limits[$0..<min($0 + 2, limits.count)]) }
    }
}

/// One body card: the figure, the words (two short lines at most), and a check that sits on the card's
/// corner like a sticker when chosen, so it never takes the words' width.
struct BodyChoiceCard: View {
    let limit: BodyLimit
    let isSelected: Bool
    let action: () -> Void

    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 36
    @Environment(\.colorScheme) private var scheme
    private static let shape = RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                LayeredIcon(icon: OnboardingCopy.icon(limit), baseColor: Palette.text.opacity(0.55),
                            markColor: Palette.accent, selected: isSelected)
                    .frame(width: iconSize, height: iconSize)
                Text(OnboardingCopy.chip(limit))
                    .typeRole(.body)
                    .fontWeight(isSelected ? .bold : .medium)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    // Room for the check on the corner.
                    .padding(.trailing, 6)
            }
            .foregroundStyle(Palette.text)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 62, maxHeight: .infinity)
            .background {
                if isSelected { ChosenFill(cornerRadius: Metrics.cardRadius) } else { CardPaper() }
            }
            .overlay {
                Self.shape.strokeBorder(isSelected ? ChoiceInk.chosen(scheme) : Palette.textMuted.opacity(0.25),
                                        lineWidth: isSelected ? 3 : 1)
            }
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    ChosenCheck().scaleEffect(0.85).offset(x: 7, y: -7).transition(.scale.combined(with: .opacity))
                }
            }
            .contentShape(Self.shape)
        }
        .buttonStyle(PressableCardStyle())
        .sensoryFeedback(.selection, trigger: isSelected)
        .animation(.easeOut(duration: 0.2), value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// "None of these": a dashed outline and no icon, so it reads as the way out, not as a body area.
struct NoneOfTheseButton: View {
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) private var scheme
    private static let shape = RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text("None of these").typeRole(.body).fontWeight(isSelected ? .bold : .medium)
                if isSelected { ChosenCheck().scaleEffect(0.85) }
            }
            .foregroundStyle(Palette.text)
            .frame(maxWidth: .infinity, minHeight: Metrics.minTouchTarget)
            .background { if isSelected { ChosenFill(cornerRadius: Metrics.cardRadius) } }
            .overlay {
                if isSelected {
                    Self.shape.strokeBorder(ChoiceInk.chosen(scheme), lineWidth: 3)
                } else {
                    Self.shape.strokeBorder(Palette.textMuted.opacity(0.45), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                }
            }
            .contentShape(Self.shape)
        }
        .buttonStyle(PressableCardStyle())
        .sensoryFeedback(.selection, trigger: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
