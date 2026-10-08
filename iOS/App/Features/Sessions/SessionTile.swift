import SwiftUI

/// One session in the two-column grid of "All sessions": painting on top with the heart on it, then
/// the name and length (17 pt and up, task 1.11), and the Pro lock when her plan does not include it.
/// Takes the width of its column and the height of its row.
struct SessionTile: View {
    let title: String
    let detail: String
    let art: Art
    let isLocked: Bool
    var hasVideo = false
    let isFavourite: Bool
    let onToggleFavourite: () -> Void
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: action) {
                VStack(alignment: .leading, spacing: 6) {
                    ArtImage(art: art, height: 104)
                        .overlay(alignment: .bottomLeading) {
                            if hasVideo { VideoBadge().padding(6) }
                        }
                    Text(verbatim: title).typeRole(.body).fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                    Text(verbatim: detail).typeRole(.body).foregroundStyle(Palette.textMuted)
                }
                .foregroundStyle(Palette.text)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            if isLocked { ProBadge() }
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Palette.surface, in: .rect(cornerRadius: Metrics.cardRadius, style: .continuous))
        // The heart sits on the painting's corner, on a light disc so it reads on any picture.
        .overlay(alignment: .topTrailing) {
            FavouriteButton(isOn: isFavourite, title: title, toggle: onToggleFavourite)
                .background(Palette.surface.opacity(0.85), in: .circle.inset(by: 10))
        }
    }
}
