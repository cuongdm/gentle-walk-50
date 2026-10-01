import SwiftUI

/// A text link ("Maybe later", "Skip rest"): main text colour, underlined, 56 pt tall touch area.
/// Primary-coloured text would fall under 4.5:1 on the background, so links stay in `text`.
struct TextLinkButtonStyle: ButtonStyle {
    var role: TypeRole = .body

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .typeRole(role)
            .fontWeight(.semibold)
            .underline()
            .foregroundStyle(Palette.text)
            .multilineTextAlignment(.center)
            .frame(minHeight: Metrics.minTouchTarget)
            .padding(.horizontal, 8)
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

extension ButtonStyle where Self == TextLinkButtonStyle {
    static var textLink: TextLinkButtonStyle { TextLinkButtonStyle() }
    static var smallTextLink: TextLinkButtonStyle { TextLinkButtonStyle(role: .caption) }
}

/// Pill used for chips and version toggles: bordered, filled when selected, at least 56 pt tall.
struct PillButtonStyle: ButtonStyle {
    var isSelected = false
    /// Shares a row with its siblings: each pill takes an equal part of the width (three answers or
    /// three options on one line instead of wrapping onto two).
    var fills = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .typeRole(.body)
            .fontWeight(.semibold)
            .lineLimit(fills ? 1 : nil)
            .minimumScaleFactor(fills ? 0.85 : 1)
            .foregroundStyle(isSelected ? Palette.onStrongFill : Palette.text)
            .padding(.horizontal, fills ? 10 : 18)
            .frame(maxWidth: fills ? .infinity : nil, minHeight: Metrics.minTouchTarget)
            .background(isSelected ? Palette.secondary : Palette.surface, in: .capsule)
            .overlay { Capsule().strokeBorder(isSelected ? Palette.secondary : Palette.textMuted.opacity(0.4), lineWidth: 2) }
            .contentShape(.capsule)
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}
