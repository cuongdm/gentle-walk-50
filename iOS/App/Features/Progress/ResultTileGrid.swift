import SwiftUI

// The tiles of "Your results" (P8). Owner, real iPhone 09/10/2026: a single tile sat in the left half of
// the card with the right half empty. Tiles now go two to a row; one left alone on its row (an odd last
// tile, or the only one) lies flat across the whole card, icon at left. With large text on a phone two
// columns squeeze the words ("Sit-to-" / "stands"), so every tile lies flat on its own row; at accessibility
// sizes each takes its own row with the icon above the words (`ProgressSpotRow` does the same).

/// How the tiles are arranged for the text size and the width class.
enum ResultTileLayout: Equatable {
    /// Two to a row; a tile alone on its row lies flat across the card.
    case grid
    /// One to a row, flat (icon at left): xxLarge text and up on a phone.
    case list
    /// One to a row, icon above the words: accessibility text sizes.
    case stack

    static func choose(typeSize: DynamicTypeSize, regularWidth: Bool) -> ResultTileLayout {
        if typeSize.isAccessibilitySize { return .stack }
        return typeSize >= .xxLarge && !regularWidth ? .list : .grid
    }

    var columns: Int { self == .grid ? 2 : 1 }
}

/// One row of the tiles: two side by side, or one alone that spans the card.
struct ResultTileRow: Identifiable, Equatable {
    var tiles: [ResultTile]
    /// Drawn flat (`ResultTileView.isWide`): alone on a row of the grid, or every row of the list.
    var isWide: Bool
    /// A tile shows at most once, so the first one names the row.
    var id: ResultTile { tiles[0] }
}

extension ResultTile {
    /// The tiles in order, `layout.columns` to a row; a single tile on a grid row, and every list row, is flat.
    static func rows(_ tiles: [ResultTile], layout: ResultTileLayout) -> [ResultTileRow] {
        let columns = layout.columns
        return stride(from: 0, to: tiles.count, by: columns).map { start in
            let row = Array(tiles[start..<min(start + columns, tiles.count)])
            return ResultTileRow(tiles: row, isWide: layout == .list || (layout == .grid && row.count == 1))
        }
    }
}

/// Lays out the tiles by `ResultTile.rows`: tiles on one row share its height, a wide one spans the row.
struct ResultTileGrid<Tile: View>: View {
    let tiles: [ResultTile]
    /// The view of one tile, flat (`true`) or upright.
    @ViewBuilder let tile: (ResultTile, Bool) -> Tile

    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        let layout = ResultTileLayout.choose(typeSize: typeSize, regularWidth: sizeClass == .regular)
        Grid(alignment: .topLeading, horizontalSpacing: 10, verticalSpacing: 10) {
            ForEach(ResultTile.rows(tiles, layout: layout)) { row in
                GridRow {
                    ForEach(row.tiles, id: \.self) { item in
                        tile(item, row.isWide).gridCellColumns(row.tiles.count == 1 ? layout.columns : 1)
                    }
                }
            }
        }
    }
}

/// One result: an icon chip, the number, what it is, and where she started. Upright in a two-column row
/// (Claude Design Outcomes.dc.html); flat when it has the row to itself, so it fills the card's width.
struct ResultTileView: View {
    let icon: AppIcon
    let value: String
    let label: LocalizedStringResource
    let detail: String?
    var isWide = false

    var body: some View {
        Group {
            if isWide {
                HStack(alignment: .center, spacing: 14) {
                    AppIconChip(icon: icon, size: 44)
                    words
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    AppIconChip(icon: icon, size: 36)
                    words
                }
            }
        }
        // Every tile on a row takes the row's height, so the two backgrounds line up.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: isWide ? .leading : .topLeading)
        .padding(12)
        .background(Palette.bg.opacity(0.6), in: .rect(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var words: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: value).typeRole(.statCompact)
                .foregroundStyle(Palette.text).lineLimit(1).minimumScaleFactor(0.6)
            Text(label).typeRole(.body).foregroundStyle(Palette.text)
                .fixedSize(horizontal: false, vertical: true)
            if let detail {
                Text(verbatim: detail).typeRole(.caption).foregroundStyle(Palette.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
