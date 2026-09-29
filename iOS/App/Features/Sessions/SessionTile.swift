import SwiftUI

/// One session in a sideways row of "All sessions": painting on top with the heart on it, then
/// the name and length, and the Pro lock when her plan does not include it.
struct SessionTile: View {
    let title: String
    let detail: String
    let art: Art
    let isLocked: Bool
    let isFavourite: Bool
    let onToggleFavourite: () -> Void
    let action: () -> Void

    @ScaledMetric(relativeTo: .body) private var width: CGFloat = 156

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: action) {
                VStack(alignment: .leading, spacing: 6) {
                    ArtImage(art: art, height: 104)
                    Text(verbatim: title).typeRole(.body).fontWeight(.semibold)
                        .lineLimit(2, reservesSpace: true)
                        .multilineTextAlignment(.leading)
                    Text(verbatim: detail).typeRole(.caption).foregroundStyle(Palette.textMuted)
                }
                .foregroundStyle(Palette.text)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            if isLocked { ProBadge() }
        }
        .padding(8)
        .frame(width: width, alignment: .topLeading)
        .background(Palette.surface, in: .rect(cornerRadius: Metrics.cardRadius, style: .continuous))
        // The heart sits on the painting's corner, on a light disc so it reads on any picture.
        .overlay(alignment: .topTrailing) {
            FavouriteButton(isOn: isFavourite, title: title, toggle: onToggleFavourite)
                .background(Palette.surface.opacity(0.85), in: .circle.inset(by: 10))
        }
    }
}
