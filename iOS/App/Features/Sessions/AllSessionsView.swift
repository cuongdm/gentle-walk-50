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
                Text("All sessions").typeRole(.screenTitle).foregroundStyle(Palette.text)
                    .accessibilityAddTraits(.isHeader)
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

/// A group title and its sessions: a sideways row of tiles, or stacked cards at accessibility
/// text sizes (a tile would be too narrow for the words).
struct SessionSection: View {
    let title: LocalizedStringResource
    let items: [AllSessionsModel.Item]
    let model: AllSessionsModel
    let onOpen: (AllSessionsModel.Item) -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

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
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 12) {
                        ForEach(items) { item in
                            SessionTile(title: item.title, detail: item.detail, art: item.art, isLocked: item.isLocked,
                                        hasVideo: item.hasVideo, isFavourite: model.isFavourite(item.id),
                                        onToggleFavourite: { model.toggleFavourite(item.id) }) { onOpen(item) }
                        }
                    }
                    .padding(.horizontal, Metrics.screenMargin)
                }
                .scrollIndicators(.hidden)
                // Rows run to the screen edges; the text above keeps the page margin.
                .padding(.horizontal, -Metrics.screenMargin)
            }
        }
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
