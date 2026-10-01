import SwiftUI
import GentleWalkCore

/// The move's name and purpose with its clock beside it, so the time does not take a row of its own
/// (owner 01/10: the 80 pt clock pushed Easier / Harder and the tips below the fold). Stacked at
/// accessibility text sizes.
struct MoveHeaderWithClock<Clock: View, Detail: View>: View {
    let exercise: Exercise?
    /// Room for the clock (the rep counter with its +1 needs more).
    var clockWidth: CGFloat = 170
    @ViewBuilder let clock: () -> Clock
    /// A short line under the purpose (sit-to-stand: "Tap +1 each time you stand").
    @ViewBuilder var detail: () -> Detail

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if typeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 8) {
                names
                clock()
            }
        } else {
            HStack(alignment: .center, spacing: 12) {
                names.frame(maxWidth: .infinity, alignment: .leading)
                clock().frame(maxWidth: clockWidth, alignment: .trailing)
            }
        }
    }

    /// Name (screen title), purpose and detail as small lines: the coach says the purpose too.
    private var names: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: exercise?.name ?? "")
                .typeRole(.screenTitle)
                .foregroundStyle(Palette.text)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .accessibilityAddTraits(.isHeader)
            Text(verbatim: exercise?.purpose ?? "").typeRole(.caption).foregroundStyle(Palette.textMuted)
                .lineLimit(2)
            detail()
        }
    }
}

extension MoveHeaderWithClock where Detail == EmptyView {
    init(exercise: Exercise?, clockWidth: CGFloat = 170, @ViewBuilder clock: @escaping () -> Clock) {
        self.init(exercise: exercise, clockWidth: clockWidth, clock: clock, detail: { EmptyView() })
    }
}

/// Easier · Harder · Tips on one line, equal widths. The tips stay folded: the coach says them, and
/// they are one tap away for a look (owner 01/10). The easier / harder instruction is not folded.
struct MoveOptionsRow: View {
    let usesEasier: Bool
    var showsHarder = false
    var hasHarder = true
    @Binding var showsTips: Bool
    let onEasier: () -> Void
    var onHarder: () -> Void = {}

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 8) { options }
            VStack(spacing: 8) { options }
        }
    }

    @ViewBuilder private var options: some View {
        Button("Easier", action: onEasier)
            .buttonStyle(PillButtonStyle(isSelected: usesEasier, fills: true))
            .accessibilityLabel(Text("Easier version"))
            .accessibilityAddTraits(usesEasier ? .isSelected : [])
        if hasHarder {
            Button("Harder", action: onHarder)
                .buttonStyle(PillButtonStyle(isSelected: showsHarder, fills: true))
                .accessibilityLabel(Text("Harder version"))
                .accessibilityAddTraits(showsHarder ? .isSelected : [])
        }
        Button {
            withAnimation(.snappy) { showsTips.toggle() }
        } label: {
            Label("Tips", systemImage: showsTips ? "chevron.up" : "chevron.down")
                .labelStyle(TrailingIconLabelStyle())
        }
        .buttonStyle(PillButtonStyle(isSelected: showsTips, fills: true))
        .accessibilityLabel(Text(showsTips ? "Hide tips" : "Show tips"))
    }
}

/// "Tips ⌄": the title, then a small icon after it.
private struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 6) {
            configuration.title
            configuration.icon.imageScale(.small)
        }
    }
}
