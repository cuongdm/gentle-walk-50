import SwiftUI

/// A large tappable choice (onboarding answers, phone placement, place selector). Selected cards
/// get a bold primary border and a tick; VoiceOver hears "Selected".
struct SelectableCard: View {
    let title: LocalizedStringResource
    var subtitle: LocalizedStringResource? = nil
    var symbol: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                if let symbol {
                    Image(systemName: symbol)
                        .typeRole(.cardTitle)
                        .foregroundStyle(Palette.secondary)
                        .frame(minWidth: 32)
                        .accessibilityHidden(true)
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
            .background(Palette.surface, in: .rect(cornerRadius: Metrics.cardRadius, style: .continuous))
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
