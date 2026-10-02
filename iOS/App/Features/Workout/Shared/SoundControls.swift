import SwiftUI

/// Coach voice and music volumes and "Move introductions" (competitor idea 4, 30/09/2026). Used in
/// Me → Workout and in the player's Sound sheet; `onChange` applies the levels to a running session.
struct SoundControls: View {
    var showsMusic = true
    var onChange: (AudioLevels) -> Void = { _ in }

    @State private var levels = AudioLevels.saved()

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            LevelSlider(title: "Coach's voice", symbol: "person.wave.2", value: $levels.voice,
                        range: AudioLevels.voiceFloor...1)
            if showsMusic {
                LevelSlider(title: "Music", symbol: "music.note", value: $levels.music, range: 0...1)
            }
            Toggle(isOn: $levels.moveIntroductions) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Move introductions").typeRole(.body)
                    Text("The coach says each chair move's name and what it helps with. Turn off once you know them.")
                        .typeRole(.caption).foregroundStyle(Palette.textMuted)
                }
            }
            .tint(Palette.secondary)
            .frame(minHeight: Metrics.minTouchTarget)
        }
        .foregroundStyle(Palette.text)
        .onChange(of: levels) { _, new in
            new.save()
            onChange(new)
        }
    }
}

/// "Coach's voice" with a quiet and a loud icon either side of the slider (56 pt tall row).
private struct LevelSlider: View {
    let title: LocalizedStringResource
    let symbol: String
    @Binding var value: Double
    let range: ClosedRange<Double>

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: symbol).typeRole(.body)
            HStack(spacing: 10) {
                Image(systemName: "speaker.fill").foregroundStyle(Palette.textMuted).accessibilityHidden(true)
                Slider(value: $value, in: range)
                    .tint(Palette.secondary)
                    .accessibilityLabel(Text(title))
                    .accessibilityValue(Text(value.formatted(.percent.precision(.fractionLength(0)))))
                Image(systemName: "speaker.wave.3.fill").foregroundStyle(Palette.textMuted).accessibilityHidden(true)
            }
            .frame(minHeight: Metrics.minTouchTarget)
        }
    }
}

/// The player's Sound sheet: the same controls, applied to the session at once. Introductions
/// change from the next session.
struct SoundSheet: View {
    let showsMusic: Bool
    /// The walk player: the coach's voice and the music switch on and off here (they were buttons
    /// beside Pause, now Back and Skip).
    var player: SessionPlayer?
    let onChange: (AudioLevels) -> Void
    @Environment(\.dismiss) private var dismiss
    /// Captions can be turned on or off here too, where they are seen (they were only in Me).
    @AppStorage("captionsOn") private var captionsOn = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ClosableHeader(title: String(localized: "Sound"), onClose: { dismiss() })
                Toggle("Captions", isOn: $captionsOn).typeRole(.body).frame(minHeight: Metrics.minTouchTarget)
                    .tint(Palette.secondary)
                if let player {
                    Toggle("Coach's voice", isOn: Binding(get: { player.isVoiceOn }, set: { player.setVoiceOn($0) }))
                        .typeRole(.body).frame(minHeight: Metrics.minTouchTarget).tint(Palette.secondary)
                    if showsMusic {
                        Toggle("Music", isOn: Binding(get: { player.isMusicOn }, set: { player.setMusicOn($0) }))
                            .typeRole(.body).frame(minHeight: Metrics.minTouchTarget).tint(Palette.secondary)
                    }
                }
                SoundControls(showsMusic: showsMusic, onChange: onChange)
                Text("Move introductions change from your next session.")
                    .typeRole(.caption).foregroundStyle(Palette.textMuted)
            }
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        .screenBackground()
        .presentationDetents([.medium, .large])
    }
}
