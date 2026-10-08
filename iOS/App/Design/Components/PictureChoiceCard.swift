import SwiftUI

/// A choice with a painting on the left (where to walk, seated or in place): picture, words and a
/// tick, the whole card tappable. Selected: primary border and a soft green wash.
struct PictureChoiceCard: View {
    let art: Art
    let title: LocalizedStringResource
    var subtitle: LocalizedStringResource? = nil
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // At accessibility text sizes the words need the width; the picture steps aside.
                if !typeSize.isAccessibilitySize {
                    ArtImage(art: art, height: 84).frame(width: 112)
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
            .padding(8)
            .padding(.trailing, 8)
            .frame(maxWidth: .infinity, minHeight: Metrics.rowHeight)
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
