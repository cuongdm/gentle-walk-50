import SwiftUI

/// A large tappable choice (onboarding answers, phone placement, place selector). Selected cards
/// get a bold primary border and a tick; VoiceOver hears "Selected".
struct SelectableCard: View {
    let title: LocalizedStringResource
    var subtitle: LocalizedStringResource? = nil
    var symbol: String? = nil
    /// Colour of the icon and its soft circle.
    var tint: Color = Palette.secondary
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                if let symbol {
                    IconChip(symbol: symbol, tint: tint)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).typeRole(.body).fontWeight(.semibold)
                    if let subtitle {
                        Text(subtitle).typeRole(.caption).foregroundStyle(Palette.textMuted)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .typeRole(.cardTitle)
                    .foregroundStyle(isSelected ? Palette.primary : Palette.textMuted)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(Palette.text)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, minHeight: 72)
            .background {
                RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
                    .fill(Palette.surface)
                    .overlay {
                        RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
                            .fill(Palette.secondary.opacity(isSelected ? 0.08 : 0))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
                    .strokeBorder(isSelected ? Palette.primary : Palette.textMuted.opacity(0.25), lineWidth: isSelected ? 3 : 1)
            }
            .contentShape(.rect(cornerRadius: Metrics.cardRadius))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
