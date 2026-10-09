import SwiftUI
import UIKit
import GentleWalkCore

/// The tree painting of the Progress tree card, cropped to the plant (owner, real iPhone 09/10/2026: a tall
/// paper tile with the seed a speck at its foot). Every stage stands on the same ground near the tile's
/// foot and fills most of its height; a seed's or sprout's wide mound of soil runs off both sides rather
/// than shrinking the plant. Painted on its own paper with a soft green ground, multiplied so the paper
/// grain disappears; in dark mode the tile is dimmed like every figure painting (`ArtImage`).
struct TreeArtTile: View {
    let level: TreeLevel
    let side: CGFloat

    @Environment(\.colorScheme) private var scheme

    /// The painted part's height as a share of the tile, and how far above the foot it stands.
    private static let fill: CGFloat = 0.80
    private static let foot: CGFloat = 0.07
    /// A wide painted part (seed, sprout: mostly soil) may run this many tile widths before it is scaled
    /// down; the overflow is soil and grass, clipped by the tile.
    private static let widest: CGFloat = 1.7

    var body: some View {
        ZStack(alignment: .bottom) {
            Palette.artPaper
            // The soft ground the mound stands on, so a narrow tree's soil does not float on the paper.
            LinearGradient(colors: [Palette.secondary.opacity(0), Palette.secondary.opacity(0.22)],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: side * 0.3)
            painting
        }
        .frame(width: side, height: side)
        .clipShape(.rect(cornerRadius: 14, style: .continuous))
        .compositingGroup()
        .environment(\.colorScheme, .light)
        .colorMultiply(scheme == .dark ? ArtImage.darkFigureDim : .white)
        .accessibilityHidden(true)
    }

    @ViewBuilder private var painting: some View {
        let name = Art.treeName(level: level)
        if let image = UIImage(named: name), image.size.height > 0 {
            let content = Art.treeContentRect(level: level)
            let aspect = image.size.width / image.size.height
            // Rendered image height that gives the painted part `fill` of the tile, or `widest` tile widths.
            let height = min(side * Self.fill / max(content.height, 0.01),
                             side * Self.widest / max(content.width * aspect, 0.01))
            let width = height * aspect
            // Centre the painted part across the tile, its foot `foot` above the tile's bottom edge.
            let dy = side * (1 - Self.foot) - (side - height) / 2 - content.maxY * height
            Image(name)
                .resizable()
                .frame(width: width, height: height)
                .mask { Self.mask(content, horizontal: true) }
                .mask { Self.mask(content, horizontal: false) }
                .offset(x: (0.5 - content.midX) * width, y: dy)
                .frame(width: side, height: side)
                .blendMode(.multiply)
        } else {
            AppIcon.sprout.image.resizable().scaledToFit().padding(side * 0.25).foregroundStyle(Palette.secondary)
        }
    }

    /// Keeps the painted part and a little paper round it, so the loose paper grain of the cut-out does not
    /// show as a pale box. Where the plant touches the image's edge (leaves cut when the sheet was split)
    /// the edge fades out instead of ending in a straight line; above the plant the paper fades in.
    private static func mask(_ content: CGRect, horizontal: Bool) -> LinearGradient {
        let margin = 0.04, fade = 0.08
        let stops: [Gradient.Stop]
        if horizontal {
            let lead = content.minX < 0.01 ? (clear: 0.0, solid: fade) : (clear: content.minX - margin, solid: content.minX)
            let trail = content.maxX > 0.99 ? (solid: 1 - fade, clear: 1.0) : (solid: content.maxX, clear: content.maxX + margin)
            stops = [.init(color: .clear, location: max(0, lead.clear)), .init(color: .black, location: lead.solid),
                     .init(color: .black, location: trail.solid), .init(color: .clear, location: min(1, trail.clear))]
        } else {
            stops = [.init(color: .clear, location: max(0, content.minY - margin)), .init(color: .black, location: content.minY),
                     .init(color: .black, location: 1)]
        }
        return LinearGradient(stops: stops, startPoint: horizontal ? .leading : .top, endPoint: horizontal ? .trailing : .bottom)
    }
}
