import SwiftUI

/// One session to pick: painting, name, length, a Pro lock when the plan does not include it, and
/// (in All sessions) a heart. The heart is its own button beside the card, never inside it.
struct SessionCard: View {
    let title: String
    let detail: String?
    let art: Art
    let isLocked: Bool
    var favourite: Favourite? = nil
    let action: () -> Void

    /// The heart's state and what tapping it does.
    struct Favourite {
        let isOn: Bool
        let toggle: () -> Void
    }

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        HStack(spacing: 8) {
            Button(action: action) {
                HStack(spacing: 14) {
                    // At accessibility text sizes the words need the width; the picture steps aside.
                    if !typeSize.isAccessibilitySize {
                        ArtImage(art: art, height: 84).frame(width: 112)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(verbatim: title).typeRole(.body).fontWeight(.semibold)
                            .multilineTextAlignment(.leading)
                        if let detail {
                            Text(verbatim: detail).typeRole(.caption).foregroundStyle(Palette.textMuted)
                        }
                        if isLocked { ProBadge() }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(Palette.text)
                    if favourite == nil {
                        Image(systemName: "chevron.right").foregroundStyle(Palette.textMuted).accessibilityHidden(true)
                    }
                }
                .frame(minHeight: Metrics.minTouchTarget)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            if let favourite {
                FavouriteButton(isOn: favourite.isOn, title: title, toggle: favourite.toggle)
            }
        }
        .padding(8)
        .padding(.trailing, favourite == nil ? 8 : 0)
        .background(Palette.surface, in: .rect(cornerRadius: Metrics.cardRadius, style: .continuous))
    }
}

/// Heart toggle, 56 pt, with a spoken name that says what it will do.
struct FavouriteButton: View {
    let isOn: Bool
    let title: String
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            Image(systemName: isOn ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundStyle(isOn ? Palette.dangerSoft : Palette.textMuted)
                .frame(width: Metrics.minTouchTarget, height: Metrics.minTouchTarget)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isOn ? Text("Remove \(title) from favourites") : Text("Add \(title) to favourites"))
        .sensoryFeedback(.selection, trigger: isOn)
    }
}
