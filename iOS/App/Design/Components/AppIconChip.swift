import SwiftUI

extension AppIcon.Tint {
    /// The wash colour of an icon chip. Never used for the glyph stroke (sky and sun are too light for a
    /// line on paper, `nguon-icon.md` §4): the glyph is ink green, cream in dark mode (`ChoiceInk`).
    var wash: Color {
        switch self {
        case .sap: Palette.secondary
        case .sky: Palette.sky
        case .ochre: Palette.sun
        case .sienna: Palette.accent
        case .danger: Palette.dangerSoft
        }
    }
}

/// Ink for icons and the "chosen" marks (Claude Design control states, owner 08/10/2026): deep green on
/// paper, and in dark mode cream for glyphs and ochre for the chosen border and check, which keep 3:1
/// against the dark card where the deep green would not.
enum ChoiceInk {
    /// `Palette.iconInk`: the same two values as an asset, so `DesignTokenTests` checks it on every wash.
    static func glyph(_ scheme: ColorScheme) -> Color { Palette.iconInk }
    static func chosen(_ scheme: ColorScheme) -> Color { scheme == .dark ? Palette.sun : Palette.primary }
    static func onChosen(_ scheme: ColorScheme) -> Color { scheme == .dark ? Palette.onLightFill : Palette.onStrongFill }
}

/// An `AppIcon` on a hand-painted watercolour wash (radial, uneven blob): the leading icon of a notebook
/// row. The Fill twin shows when the row is chosen. Decorative: the row's words carry the meaning.
struct AppIconChip: View {
    let icon: AppIcon
    var selected = false
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 38
    @Environment(\.colorScheme) private var scheme

    /// 38 pt for list rows and answers; 44 pt at the head of a Today card (icon doc §2).
    init(icon: AppIcon, selected: Bool = false, size: CGFloat = 38) {
        self.icon = icon
        self.selected = selected
        _size = ScaledMetric(wrappedValue: size, relativeTo: .body)
    }

    var body: some View {
        icon.image(selected: selected)
            .resizable()
            .scaledToFit()
            .frame(width: size * 0.55, height: size * 0.55)
            .foregroundStyle(ChoiceInk.glyph(scheme))
            .frame(width: size, height: size)
            .background {
                WashShape(variant: WashShape.variant(for: icon.rawValue))
                    .fill(RadialGradient(colors: [icon.tint.wash.opacity(0.12), icon.tint.wash.opacity(0.4)],
                                         center: UnitPoint(x: 0.34, y: 0.3), startRadius: 0, endRadius: size * 0.75))
            }
            .accessibilityHidden(true)
    }
}

/// An `AppIcon` without its wash, sized with the text beside it (a week-strip day, the leaf in a line of
/// text). Decorative like the chip.
struct AppIconGlyph: View {
    let icon: AppIcon
    var color: Color = Palette.iconInk
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 20

    init(icon: AppIcon, size: CGFloat = 20, color: Color = Palette.iconInk) {
        self.icon = icon
        self.color = color
        _size = ScaledMetric(wrappedValue: size, relativeTo: .body)
    }

    var body: some View {
        icon.image.resizable().scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(color)
            .accessibilityHidden(true)
    }
}

/// The filled check of a chosen answer: a solid circle with a hand-drawn tick (never colour alone).
struct ChosenCheck: View {
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 28
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Image(systemName: "checkmark")
            .font(.system(size: size * 0.5, weight: .bold))
            .foregroundStyle(ChoiceInk.onChosen(scheme))
            .frame(width: size, height: size)
            .background(ChoiceInk.chosen(scheme), in: .circle)
            .accessibilityHidden(true)
    }
}

/// An ochre highlighter stroke under the words of the chosen answer, like a marker in a notebook.
struct HighlighterStroke: ViewModifier {
    let isOn: Bool

    func body(content: Content) -> some View {
        content.background(alignment: .bottom) {
            if isOn {
                GeometryReader { proxy in
                    Palette.sun.opacity(0.45)
                        .frame(height: proxy.size.height * 0.4)
                        .offset(y: proxy.size.height * 0.52)
                }
                .padding(.horizontal, -3)
                .transition(.opacity)
                .accessibilityHidden(true)
            }
        }
    }
}

/// The chosen fill: an ochre wash, a little deeper at the top (Claude Design "Main goal").
struct ChosenFill: View {
    var cornerRadius: CGFloat = 14

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(LinearGradient(colors: [Palette.sun.opacity(0.28), Palette.sun.opacity(0.13)], startPoint: .top, endPoint: .bottom))
            .shadow(color: Palette.primary.opacity(0.12), radius: 7, y: 4)
    }
}
