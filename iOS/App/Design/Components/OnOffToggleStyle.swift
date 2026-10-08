import SwiftUI

/// A switch that always says its state in words, "On" or "Off", beside it (Claude Design control states,
/// owner 08/10/2026: never colour alone). The row stays one target of at least 56 pt; VoiceOver already
/// reads the switch's value, so the word is hidden from it.
struct OnOffToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Toggle(isOn: configuration.$isOn) {
            HStack(spacing: 8) {
                configuration.label.frame(maxWidth: .infinity, alignment: .leading)
                Text(configuration.isOn ? "On" : "Off")
                    .typeRole(.body).fontWeight(.semibold)
                    .foregroundStyle(Palette.text)
                    .fixedSize()
                    .accessibilityHidden(true)
            }
        }
        .toggleStyle(.switch)
        .frame(minHeight: Metrics.minTouchTarget)
    }
}

extension ToggleStyle where Self == OnOffToggleStyle {
    static var onOffWord: OnOffToggleStyle { OnOffToggleStyle() }
}

/// The label of a settings switch: its icon chip, the words and an optional second line.
struct IconToggleLabel: View {
    let icon: AppIcon
    let title: LocalizedStringResource
    var detail: String? = nil

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        HStack(spacing: 12) {
            if !typeSize.isAccessibilitySize { AppIconChip(icon: icon) }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).typeRole(.body)
                if let detail { Text(verbatim: detail).typeRole(.caption) }
            }
        }
    }
}
