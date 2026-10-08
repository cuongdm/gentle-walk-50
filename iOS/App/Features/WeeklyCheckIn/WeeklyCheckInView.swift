import SwiftUI
import GentleWalkCore

/// P6 weekly check-in (plan 4.9, D11): two quick questions about last week, on the first open from Sunday
/// to Tuesday, skippable, no notification of its own. "Harder" makes next week a little shorter and gentler,
/// "Easier than I expected" a little longer; the chip is kept in her own words for Today and Progress.
struct WeeklyCheckInView: View {
    let onSave: (WeeklyEffort, BetterChip?) -> Void
    let onSkip: () -> Void

    @State private var effort: WeeklyEffort?
    @State private var better: BetterChip?
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ScreenHeader(title: "This week felt…", subtitle: "About last week. You can skip this.")
                VStack(spacing: 10) {
                    ForEach(WeeklyEffort.allCases, id: \.self) { value in
                        SelectableCard(title: value.title, symbol: value.symbol, isSelected: effort == value) { effort = value }
                    }
                }
                Text("One thing that felt a bit better?").typeRole(.cardTitle).foregroundStyle(Palette.text)
                    .padding(.top, 4)
                FlowLayout(spacing: Metrics.touchSpacing) {
                    ForEach(BetterChip.allCases, id: \.self) { chip in
                        Button { better = better == chip ? nil : chip } label: { Text(chip.localizedTitle) }
                            .buttonStyle(PillButtonStyle(isSelected: better == chip))
                            .accessibilityAddTraits(better == chip ? .isSelected : [])
                    }
                }
                if typeSize.isAccessibilitySize { actions }
            }
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        .pinnedActions(!typeSize.isAccessibilitySize) { actions }
        .screenBackground()
        .sensoryFeedback(.selection, trigger: effort)
        .sensoryFeedback(.selection, trigger: better)
    }

    @ViewBuilder private var actions: some View {
        if let effort {
            Button("Save") { onSave(effort, better) }.buttonStyle(.primaryAction)
        } else {
            // Not pressable yet: an outlined button that says why (control-state rules, 08/10/2026).
            Text("Pick one to continue.")
                .typeRole(.button)
                .foregroundStyle(Palette.textMuted)
                .frame(maxWidth: .infinity, minHeight: Metrics.buttonHeight)
                .overlay {
                    RoundedRectangle(cornerRadius: Metrics.buttonRadius, style: .continuous)
                        .strokeBorder(Palette.textMuted.opacity(0.6), style: StrokeStyle(lineWidth: 2, dash: [6, 5]))
                }
        }
        Button("Skip", action: onSkip)
            .buttonStyle(.textLink)
            .frame(maxWidth: .infinity)
    }
}

extension WeeklyEffort {
    var title: LocalizedStringResource {
        switch self {
        case .easier: "Easier than I expected"
        case .right: "About right"
        case .harder: "Harder"
        }
    }

    var symbol: String {
        switch self {
        case .easier: "arrow.up.right"
        case .right: "equal"
        case .harder: "arrow.down.right"
        }
    }
}

extension BetterChip {
    /// The chip through the String Catalog (the core keeps the English source in `title`).
    var localizedTitle: LocalizedStringResource {
        switch self {
        case .gettingUp: "Getting up from a chair"
        case .stairs: "Stairs"
        case .morningStiffness: "Stiffness in the morning"
        case .energy: "Energy"
        case .sleep: "Sleep"
        case .walkingOutside: "Walking outside"
        case .nothingYet: "Nothing yet"
        }
    }
}
