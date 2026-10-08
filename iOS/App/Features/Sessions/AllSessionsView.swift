import SwiftUI
import GentleWalkCore

/// "All sessions" (milestone 10): her favourites, then Walks · Chair moves · Stretches · Short
/// extras. A locked card opens the plans; an open one opens the preview.
struct AllSessionsView: View {
    let model: AllSessionsModel
    let onOpen: (AllSessionsModel.Item) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("All sessions").typeRole(.screenTitle).foregroundStyle(Palette.text)
                        .accessibilityAddTraits(.isHeader)
                    // Whether a pick counts, and what "Pro" opens (clarity review D39).
                    Text("Pick any session. It counts for today.").typeRole(.body).foregroundStyle(Palette.text)
                }
                if !model.favouriteItems.isEmpty {
                    SessionSection(title: "Your favourites", items: model.favouriteItems, model: model, onOpen: onOpen)
                }
                ForEach(model.sections) { section in
                    SessionSection(title: section.group.title, items: section.items, model: model, onOpen: onOpen)
                }
            }
            .padding(Metrics.screenMargin)
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .screenBackground()
    }
}

/// A group title and its sessions in a two-column grid that wraps downwards (plan 08/10/2026 task 1.11:
/// a sideways row hid its third tile and older eyes rarely find sideways scrolling), tiles in a row the
/// same height; stacked cards at accessibility text sizes (a tile would be too narrow for the words).
struct SessionSection: View {
    let title: LocalizedStringResource
    let items: [AllSessionsModel.Item]
    let model: AllSessionsModel
    let onOpen: (AllSessionsModel.Item) -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    /// Items in pairs, one pair per grid row.
    private var rows: [[AllSessionsModel.Item]] {
        stride(from: 0, to: items.count, by: 2).map { Array(items[$0..<min($0 + 2, items.count)]) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).typeRole(.cardTitle).foregroundStyle(Palette.text).accessibilityAddTraits(.isHeader)
            if typeSize.isAccessibilitySize {
                ForEach(items) { item in
                    SessionCard(title: item.title, detail: item.detail, art: item.art, isLocked: item.isLocked,
                                hasVideo: item.hasVideo, favourite: .init(isOn: model.isFavourite(item.id), toggle: { model.toggleFavourite(item.id) })) {
                        onOpen(item)
                    }
                }
            } else {
                Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                    ForEach(rows, id: \.first?.id) { pair in
                        GridRow(alignment: .top) {
                            ForEach(pair) { item in tile(item) }
                            if pair.count == 1 { Color.clear.gridCellUnsizedAxes([.horizontal, .vertical]) }
                        }
                    }
                }
            }
        }
    }

    private func tile(_ item: AllSessionsModel.Item) -> some View {
        SessionTile(title: item.title, detail: item.detail, art: item.art, isLocked: item.isLocked,
                    hasVideo: item.hasVideo, isFavourite: model.isFavourite(item.id),
                    onToggleFavourite: { model.toggleFavourite(item.id) }) { onOpen(item) }
    }
}

/// The Today tab's destination: builds the model once for her plan and limits.
struct AllSessionsScreen: View {
    let app: AppModel
    @State private var model: AllSessionsModel?

    var body: some View {
        VStack {
            if let model {
                AllSessionsView(model: model) { item in
                    item.isLocked ? app.offerPlans(.lockedContent) : app.preview(item.request, checkIn: app.today?.checkedIn)
                }
            } else {
                Palette.bg.ignoresSafeArea()
            }
        }
        .task { model = app.makeAllSessions() }
    }
}
