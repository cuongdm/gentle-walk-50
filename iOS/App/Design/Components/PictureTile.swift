import SwiftUI

/// A compact choice with its painting on top and the words below, for two or three side by side
/// (where to walk, seated or in place). Selected: primary border, soft green wash, a tick.
struct PictureTile: View {
    let art: Art
    let title: LocalizedStringResource
    var subtitle: LocalizedStringResource? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ArtImage(art: art, height: 72)
                    .overlay(alignment: .topTrailing) {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Palette.onStrongFill, Palette.primary)
                                .padding(4)
                                .accessibilityHidden(true)
                        }
                    }
                Text(title).typeRole(.body).fontWeight(.semibold).multilineTextAlignment(.center)
                if let subtitle {
                    Text(subtitle).typeRole(.caption).foregroundStyle(Palette.textMuted).multilineTextAlignment(.center)
                }
            }
            .foregroundStyle(Palette.text)
            .padding(6)
            .frame(maxWidth: .infinity, minHeight: Metrics.minTouchTarget, alignment: .top)
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
