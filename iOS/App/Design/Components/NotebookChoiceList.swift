import SwiftUI

/// Answers on one sheet of notebook paper (Claude Design direction, owner 08/10/2026): rows separated by
/// dashed rules, an icon on its watercolour wash at the start of the line (optional: scales like "How
/// active are you now?" have none), 19 pt words. The chosen row is clear without colour: an ochre fill,
/// a 3 pt border, bold words over a highlighter stroke and a filled check; VoiceOver hears "Selected".
/// `Item` is a small enum of answers, so the value itself is a stable identity.
struct NotebookChoiceList<Item: Hashable>: View {
    let items: [Item]
    let title: (Item) -> LocalizedStringResource
    var icon: ((Item) -> AppIcon)? = nil
    let isSelected: (Item) -> Bool
    let onTap: (Item) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                NotebookRow(title: title(item), icon: icon?(item), isSelected: isSelected(item),
                            showsRule: item != items.last) { onTap(item) }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 2)
        .background { CardPaper() }
    }
}

/// One line of the notebook list: at least 56 pt tall, the whole line is the target.
struct NotebookRow: View {
    let title: LocalizedStringResource
    var icon: AppIcon?
    let isSelected: Bool
    var showsRule = true
    let action: () -> Void

    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // At accessibility sizes the words need the width; the icon only decorates.
                if let icon, !typeSize.isAccessibilitySize {
                    AppIconChip(icon: icon, selected: isSelected)
                }
                Text(title)
                    .typeRole(.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .modifier(HighlighterStroke(isOn: isSelected))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                if isSelected {
                    ChosenCheck().transition(.scale.combined(with: .opacity))
                }
            }
            .foregroundStyle(Palette.text)
            .padding(.vertical, 7)
            .padding(.horizontal, isSelected ? 8 : 0)
            .frame(maxWidth: .infinity, minHeight: Metrics.minTouchTarget, alignment: .leading)
            .background {
                if isSelected { ChosenFill() }
            }
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(ChoiceInk.chosen(scheme), lineWidth: 3)
                }
            }
            // The chosen line reaches a little past the page margin, like the mock.
            .padding(.horizontal, isSelected ? -8 : 0)
            .overlay(alignment: .bottom) {
                if showsRule && !isSelected {
                    DashedRule().accessibilityHidden(true)
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(PressableCardStyle())
        .sensoryFeedback(.selection, trigger: isSelected)
        .animation(.easeOut(duration: 0.2), value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// The dashed rule between notebook lines.
struct DashedRule: View {
    var body: some View {
        Line()
            .stroke(Palette.textMuted.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
            .frame(height: 1.5)
    }

    private struct Line: Shape {
        func path(in rect: CGRect) -> Path {
            Path { $0.move(to: CGPoint(x: rect.minX, y: rect.midY)); $0.addLine(to: CGPoint(x: rect.maxX, y: rect.midY)) }
        }
    }
}
