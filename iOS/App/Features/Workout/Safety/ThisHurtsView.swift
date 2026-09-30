import SwiftUI

/// S13 This hurts: a full screen, not a sheet. One question, five chips, the easier version as the
/// biggest button, and two links.
struct ThisHurtsView: View {
    @Bindable var model: ThisHurtsModel
    let onDone: (HurtOutcome) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ScreenHeader(title: "Let's take care of that.")
                Text("Where does it hurt?").typeRole(.cardTitle).foregroundStyle(Palette.text)
                FlowChips(selection: $model.area)
                Button("Show an easier version") { Task { onDone(await model.showEasier()) } }
                    .buttonStyle(.primaryAction)
                VStack(spacing: 4) {
                    Button("Skip this move") { Task { onDone(await model.skipMove()) } }
                        .buttonStyle(.textLink)
                    Button("Stop for today") { onDone(model.stopForToday()) }
                        .buttonStyle(.textLink)
                }
                .frame(maxWidth: .infinity)
                Text("We'll remember this and adjust your plan. Today still counts.")
                    .typeRole(.body)
                    .foregroundStyle(Palette.text)
            }
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        .screenBackground()
    }
}

/// Area chips that wrap to more lines at large text sizes.
private struct FlowChips: View {
    @Binding var selection: HurtArea?

    var body: some View {
        FlowLayout(spacing: Metrics.touchSpacing) {
            ForEach(HurtArea.allCases) { area in
                Button { selection = area } label: { Text(area.title) }
                    .buttonStyle(PillButtonStyle(isSelected: selection == area))
                    .accessibilityAddTraits(selection == area ? .isSelected : [])
            }
        }
    }
}

/// Simple wrapping layout for chips.
struct FlowLayout: Layout {
    var spacing: CGFloat = 12

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(proposal: proposal, subviews: subviews)
        let height = rows.last.map { $0.y + $0.height } ?? 0
        return CGSize(width: proposal.width ?? rows.map(\.width).max() ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for row in arrange(proposal: ProposedViewSize(width: bounds.width, height: nil), subviews: subviews) {
            var x = bounds.minX
            for index in row.items {
                let size = fit(subviews[index], maxWidth: bounds.width)
                subviews[index].place(at: CGPoint(x: x, y: bounds.minY + row.y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
        }
    }

    private struct Row { var items: [Int] = []; var y: CGFloat = 0; var width: CGFloat = 0; var height: CGFloat = 0 }

    /// A chip wider than the row (large text) wraps inside the row instead of running off the
    /// screen (review U2).
    private func fit(_ subview: LayoutSubview, maxWidth: CGFloat) -> CGSize {
        let ideal = subview.sizeThatFits(.unspecified)
        guard ideal.width > maxWidth else { return ideal }
        return subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [Row] = [Row()]
        for (index, subview) in subviews.enumerated() {
            let size = fit(subview, maxWidth: maxWidth)
            if !rows[rows.count - 1].items.isEmpty, rows[rows.count - 1].width + spacing + size.width > maxWidth {
                let y = rows[rows.count - 1].y + rows[rows.count - 1].height + spacing
                rows.append(Row(y: y))
            }
            var row = rows[rows.count - 1]
            row.width += (row.items.isEmpty ? 0 : spacing) + size.width
            row.height = max(row.height, size.height)
            row.items.append(index)
            rows[rows.count - 1] = row
        }
        return rows
    }
}
