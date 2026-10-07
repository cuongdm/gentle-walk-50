import SwiftUI

/// Main button: full width, at least 60 pt tall (grows with Dynamic Type), radius 18, 20 pt semibold,
/// white text on a strong fill. One per screen.
struct PrimaryButtonStyle: ButtonStyle {
    /// Fill colour: `Palette.primary`, or `Palette.dangerSoft` for This hurts and deleting data.
    var fill: Color = Palette.primary

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .typeRole(.button)
            .multilineTextAlignment(.center)
            .foregroundStyle(Palette.onStrongFill)
            .padding(.horizontal, Metrics.screenMargin)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: Metrics.buttonHeight)
            .background(fill, in: .rect(cornerRadius: Metrics.buttonRadius, style: .continuous))
            .opacity(configuration.isPressed ? 0.85 : 1)
            .opacity(isEnabled ? 1 : 0.45)
            .contentShape(.rect(cornerRadius: Metrics.buttonRadius, style: .continuous))
    }
}

/// Secondary button: same size as the main button, transparent with a 2 pt primary border and
/// main-text label (primary text on bg would fall under 4.5:1).
struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .typeRole(.button)
            .multilineTextAlignment(.center)
            .foregroundStyle(Palette.text)
            .padding(.horizontal, Metrics.screenMargin)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: Metrics.buttonHeight)
            .overlay {
                RoundedRectangle(cornerRadius: Metrics.buttonRadius, style: .continuous)
                    .strokeBorder(Palette.primary, lineWidth: Metrics.secondaryBorder)
            }
            .opacity(configuration.isPressed ? 0.7 : 1)
            .opacity(isEnabled ? 1 : 0.45)
            .contentShape(.rect(cornerRadius: Metrics.buttonRadius, style: .continuous))
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    /// The one main button on a screen.
    static var primaryAction: PrimaryButtonStyle { PrimaryButtonStyle() }
    /// This hurts, and confirming a data deletion.
    static var dangerAction: PrimaryButtonStyle { PrimaryButtonStyle(fill: Palette.dangerSoft) }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondaryAction: SecondaryButtonStyle { SecondaryButtonStyle() }
}

/// A card that gives a little under the finger (0.98) before it takes the tap.
struct PressableCardStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
