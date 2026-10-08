import SwiftUI

/// Round Pause / Resume button, 88 pt (S11) or 72 pt (S12 control row).
struct PauseButton: View {
    let isPaused: Bool
    var size: CGFloat = 88
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isPaused ? "play.fill" : "pause.fill")
                .font(.system(size: size * 0.36, weight: .bold))
                .foregroundStyle(Palette.onStrongFill)
                .frame(width: size, height: size)
                .background(Palette.primary, in: .circle)
                .contentShape(.circle)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isPaused ? Text("Resume") : Text("Pause"))
    }
}

/// Back · Pause · Skip row on the chair and stretch players.
struct PlayerControlRow: View {
    let isPaused: Bool
    let onBack: () -> Void
    let onPause: () -> Void
    let onSkip: () -> Void
    /// Smaller on an iPhone SE, so the move above keeps room (still well over 56 pt).
    var pauseSize: CGFloat = 76

    var body: some View {
        HStack {
            ControlIcon(title: "Back", symbol: "backward.end.fill", action: onBack)
            Spacer()
            PauseButton(isPaused: isPaused, size: pauseSize, action: onPause)
            Spacer()
            ControlIcon(title: "Skip", symbol: "forward.end.fill", action: onSkip)
        }
        .dynamicTypeSize(...PlayerChrome.typeLimit)
        .fixedSize(horizontal: false, vertical: true)
        .layoutPriority(1)
    }
}

private struct ControlIcon: View {
    let title: LocalizedStringResource
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: symbol).typeRole(.cardTitle).accessibilityHidden(true)
                Text(title).typeRole(.caption)
            }
            .foregroundStyle(Palette.text)
            .frame(minWidth: 72, minHeight: Metrics.minTouchTarget)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
