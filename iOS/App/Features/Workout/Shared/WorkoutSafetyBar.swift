import SwiftUI

/// Fixed bottom row on every player (S11, S12, S12b): Voice, Music (only when music exists),
/// Break in sky and This hurts in danger-soft. Each button has an icon and a word, 56 pt or more.
struct WorkoutSafetyBar: View {
    var showsVoice = true
    var isVoiceOn = true
    var showsMusic = false
    var isMusicOn = true
    var musicTitle: LocalizedStringResource = "Music"
    var onVoice: () -> Void = {}
    var onMusic: () -> Void = {}
    let onBreak: () -> Void
    let onHurts: () -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        // Accessibility sizes: two rows of two, so no word is ever cut ("This hurts" above all).
        if typeSize.isAccessibilitySize {
            Grid(horizontalSpacing: Metrics.touchSpacing, verticalSpacing: Metrics.touchSpacing) {
                GridRow { settingButtons }
                GridRow { safetyButtons }
            }
        } else {
            HStack(spacing: Metrics.touchSpacing) {
                settingButtons
                safetyButtons
            }
        }
    }

    @ViewBuilder private var settingButtons: some View {
            if showsVoice {
                BarButton(title: "Voice", symbol: isVoiceOn ? "speaker.wave.2.fill" : "speaker.slash.fill",
                          fill: Palette.surface, text: Palette.text, action: onVoice)
                    .accessibilityValue(isVoiceOn ? Text("On") : Text("Off"))
            }
            if showsMusic {
                BarButton(title: musicTitle, symbol: isMusicOn ? "music.note" : "speaker.slash", fill: Palette.surface,
                          text: Palette.text, action: onMusic)
                    .accessibilityValue(isMusicOn ? Text("On") : Text("Off"))
            }
    }

    @ViewBuilder private var safetyButtons: some View {
        BarButton(title: "Break", symbol: "cup.and.saucer.fill", fill: Palette.sky, text: Palette.onLightFill, action: onBreak)
        BarButton(title: "This hurts", symbol: "hand.raised.fill", fill: Palette.dangerSoft, text: Palette.onStrongFill, action: onHurts)
    }
}

private struct BarButton: View {
    let title: LocalizedStringResource
    let symbol: String
    let fill: Color
    let text: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: symbol).accessibilityHidden(true)
                Text(title).lineLimit(3).fixedSize(horizontal: false, vertical: true)
            }
            .typeRole(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(text)
            .frame(maxWidth: .infinity, minHeight: Metrics.minTouchTarget + 8)
            .padding(.vertical, 4)
            .background(fill, in: .rect(cornerRadius: 16, style: .continuous))
            .overlay { RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Palette.textMuted.opacity(0.2)) }
            .contentShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
