import SwiftUI
import GentleWalkCore

// Motion for the onboarding redesign (owner 03/10/2026, prototype "Gentle Walk onboarding redesign"):
// every move is under 0.6 s, nothing advances by itself, and Reduce Motion leaves only fades.

/// How an element arrives the first time it appears.
enum RevealStyle {
    /// Rises 14 pt while fading in.
    case rise
    /// Grows from half size with a small overshoot (week tiles, timeline dots).
    case pop
    /// Drops 10 pt from above (limit chips landing in the plan).
    case drop
}

private struct RevealOnAppear: ViewModifier {
    let style: RevealStyle
    let delay: Double
    let enabled: Bool
    @State private var shown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ViewBuilder func body(content: Content) -> some View {
        if enabled { animated(content) } else { content }
    }

    private func animated(_ content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .scaleEffect(shown || reduceMotion || style != .pop ? 1 : 0.5)
            .offset(y: shown || reduceMotion ? 0 : (style == .rise ? 14 : style == .drop ? -10 : 0))
            .onAppear {
                let animation: Animation = reduceMotion ? .easeOut(duration: 0.25)
                    : style == .pop ? .spring(response: 0.42, dampingFraction: 0.62) : .spring(response: 0.5, dampingFraction: 0.86)
                withAnimation(animation.delay(reduceMotion ? 0 : delay)) { shown = true }
            }
    }
}

extension View {
    /// Fades the view in (and moves it a little, unless Reduce Motion is on) when it first appears.
    func reveal(_ style: RevealStyle = .rise, delay: Double = 0, enabled: Bool = true) -> some View {
        modifier(RevealOnAppear(style: style, delay: delay, enabled: enabled))
    }
}

/// The coach's round face, cut from the waving painting (head at the top of the picture).
struct CoachFace: View {
    var size: CGFloat = 44

    var body: some View {
        // The face sits in a 110 px square at (95, 15) of the 269 × 509 painting.
        let k = size / 110
        Image(Art.walkerWave.rawValue)
            .resizable()
            .frame(width: 269 * k, height: 509 * k)
            .offset(x: -95 * k, y: -15 * k)
            .frame(width: size, height: size, alignment: .topLeading)
            .background(Palette.artPaper)
            .clipShape(.circle)
            .overlay { Circle().strokeBorder(Palette.secondary.opacity(0.35), lineWidth: 2) }
            .accessibilityHidden(true)
    }
}
