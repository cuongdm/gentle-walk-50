import SwiftUI

/// A switch that always says its state in words, "On" or "Off", beside it (Claude Design control states,
/// owner 08/10/2026: never colour alone). The row stays one target of at least 56 pt; VoiceOver already
/// reads the switch's value, so the word is hidden from it.
struct OnOffToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        OnOffToggleRow(configuration: configuration)
    }
}

/// At the largest text sizes the label takes the full width with the word and the switch on the line
/// under it (beside them it broke mid-word: "Walk remin/der"); VoiceOver still meets one switch.
private struct OnOffToggleRow: View {
    let configuration: ToggleStyleConfiguration
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if typeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 4) {
                configuration.label
                HStack(spacing: 12) {
                    word
                    Spacer(minLength: 0)
                    Toggle(isOn: configuration.$isOn) { configuration.label }
                        .labelsHidden()
                        .toggleStyle(.switch)
                }
                .frame(minHeight: Metrics.minTouchTarget)
            }
            .contentShape(.rect)
            .onTapGesture { configuration.isOn.toggle() }
            .accessibilityRepresentation {
                Toggle(isOn: configuration.$isOn) { configuration.label }
            }
        } else {
            Toggle(isOn: configuration.$isOn) {
                HStack(spacing: 8) {
                    configuration.label.frame(maxWidth: .infinity, alignment: .leading)
                    word
                }
            }
            .toggleStyle(.switch)
            .frame(minHeight: Metrics.minTouchTarget)
        }
    }

    private var word: some View {
        Text(configuration.isOn ? "On" : "Off")
            .typeRole(.body).fontWeight(.semibold)
            .foregroundStyle(Palette.text)
            .fixedSize()
            .accessibilityHidden(true)
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
