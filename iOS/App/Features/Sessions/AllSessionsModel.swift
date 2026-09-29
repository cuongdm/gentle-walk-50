import Foundation
import GentleWalkCore
import Observation

/// "All sessions" (milestone 10): the four groups of `SessionCatalog`, built once for her limits
/// and plan, with her favourites on top. Sessions her limits empty out are left off.
@Observable @MainActor final class AllSessionsModel {
    struct Item: Equatable, Identifiable {
        var id: String
        var title: String
        var detail: String
        var art: Art
        var isLocked: Bool
        var request: WorkoutRequest
    }

    struct Section: Equatable, Identifiable {
        var group: SessionPreset.Group
        var items: [Item]
        var id: SessionPreset.Group { group }
    }

    let sections: [Section]
    @ObservationIgnored private let itemsByID: [String: Item]
    private let favourites: FavouriteSessions

    init(isPro: Bool, limits: Set<BodyLimit>, rotationIndex: Int, content: ContentBundle, favourites: FavouriteSessions) {
        self.favourites = favourites
        let sections = SessionPreset.Group.allCases.map { group in
            let items = SessionCatalog.presets(in: group).compactMap { preset -> Item? in
                // Standing stretches would turn seated anyway when standing is hard: show the seated ones only.
                if preset.standing && limits.contains(.standingIsHard) { return nil }
                let minutes = preset.minutes(content: content, limits: limits, rotationIndex: rotationIndex)
                guard minutes > 0 else { return nil }
                return Item(id: preset.id, title: String(localized: preset.title), detail: String(localized: "\(minutes) min"),
                            art: preset.art, isLocked: !isPro && !preset.isFree,
                            request: preset.request(limits: limits, rotationIndex: rotationIndex))
            }
            return Section(group: group, items: items)
        }
        self.sections = sections.filter { !$0.items.isEmpty }
        itemsByID = Dictionary(uniqueKeysWithValues: sections.flatMap(\.items).map { ($0.id, $0) })
    }

    /// Her hearted sessions, in the order she added them.
    var favouriteItems: [Item] { favourites.ids.compactMap { itemsByID[$0] } }

    func isFavourite(_ id: String) -> Bool { favourites.contains(id) }

    func toggleFavourite(_ id: String) { favourites.toggle(id) }
}
