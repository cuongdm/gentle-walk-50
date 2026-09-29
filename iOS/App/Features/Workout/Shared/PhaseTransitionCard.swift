import SwiftUI

/// Phase change frame (task 3.6): the whole screen takes the new phase colour with the phase name
/// large in the middle for a moment. Bell and two taps come from the audio program and `PhaseSignal`.
struct PhaseTransitionCard: View {
    let label: String
    let tone: PhaseTone

    var body: some View {
        ZStack {
            tone.fill.ignoresSafeArea()
            Text(verbatim: label)
                .typeRole(.transition)
                .foregroundStyle(Palette.onLightFill)
                .multilineTextAlignment(.center)
                .padding(Metrics.screenMargin)
        }
        .accessibilityElement()
        .accessibilityLabel(Text(verbatim: label))
    }
}

extension PhaseTone {
    /// Full-screen phase colour: sun for brisk, sky for easy, soft bg while getting ready.
    var fill: Color {
        switch self {
        case .brisk: Palette.sun
        case .easy: Palette.sky
        case .ready: Palette.surface
        }
    }

    /// Soft background tint for the player while in this phase.
    var wash: Color {
        switch self {
        case .brisk: Palette.sun.opacity(0.18)
        case .easy: Palette.sky.opacity(0.16)
        case .ready: .clear
        }
    }
}
