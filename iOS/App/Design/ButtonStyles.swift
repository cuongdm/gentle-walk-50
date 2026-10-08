import SwiftUI

/// Main button: full width, at least 64 pt tall (grows with Dynamic Type), 20 pt semibold, white text.
/// One per screen. Soft depth, not 3D (Claude Design direction, owner 08/10/2026): a light-to-deep green
/// gradient, a 1 pt highlight along the top edge and a soft green shadow; pressed, it darkens, sinks
/// (inner shadow) and gives a little (0.97); disabled is flat.
struct PrimaryButtonStyle: ButtonStyle {
    /// A flat fill instead of the green gradient: `Palette.dangerSoft` for This hurts and deleting data.
    var fill: Color? = nil

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let shape = RoundedRectangle(cornerRadius: Metrics.buttonRadius, style: .continuous)
    private static let resting = LinearGradient(stops: [.init(color: Palette.primaryTop, location: 0),
                                                        .init(color: Palette.primaryMid, location: 0.55),
                                                        .init(color: Palette.primaryBottom, location: 1)],
                                                startPoint: .top, endPoint: .bottom)
    private static let pressed = LinearGradient(colors: [Palette.primaryBottom, Palette.primaryPressed],
                                                startPoint: .top, endPoint: .bottom)
    private static let highlight = LinearGradient(colors: [Palette.onStrongFill.opacity(0.22), .clear],
                                                  startPoint: .top, endPoint: .center)

    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        return configuration.label
            .typeRole(.button)
            .multilineTextAlignment(.center)
            .foregroundStyle(Palette.onStrongFill)
            .padding(.horizontal, Metrics.screenMargin)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: Metrics.buttonHeight)
            .background {
                if let fill {
                    Self.shape.fill(fill).opacity(isPressed ? 0.85 : 1)
                } else if !isEnabled {
                    Self.shape.fill(Palette.primaryMid)
                } else {
                    Self.shape.fill(isPressed ? Self.pressed : Self.resting)
                        .overlay {
                            if isPressed {
                                // Inner shadow along the top edge: the button sinks under the finger.
                                Self.shape.stroke(Palette.shadow.opacity(0.35), lineWidth: 4)
                                    .blur(radius: 3).offset(y: 2).mask(Self.shape)
                            } else {
                                Self.shape.strokeBorder(Self.highlight, lineWidth: 1)
                            }
                        }
                        .shadow(color: Palette.primaryBottom.opacity(isPressed ? 0.12 : 0.26), radius: 9, y: isPressed ? 3 : 8)
                }
            }
            .scaleEffect(isPressed && !reduceMotion && fill == nil ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: isPressed)
            .opacity(isEnabled ? 1 : 0.45)
            .contentShape(Self.shape)
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
