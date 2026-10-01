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
        /// At least one move in it has a filmed clip; the rest are voice and pictures.
        var hasVideo = false
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
        let filmed = SessionVideo.filmed(in: content)
        let sections = SessionPreset.Group.allCases.map { group in
            let items = SessionCatalog.presets(in: group).compactMap { preset -> Item? in
                // Standing stretches would turn seated anyway when standing is hard: show the seated ones
                // only. Balance is done standing throughout: left off too.
                if (preset.standing || preset.variant == SessionBuilder.Variant.balance) && limits.contains(.standingIsHard) {
                    return nil
                }
                let minutes = preset.minutes(content: content, limits: limits, rotationIndex: rotationIndex)
                guard minutes > 0 else { return nil }
                let request = preset.request(limits: limits, rotationIndex: rotationIndex)
                return Item(id: preset.id, title: String(localized: preset.title), detail: String(localized: "\(minutes) min"),
                            art: preset.art, isLocked: !isPro && !preset.isFree,
                            hasVideo: SessionVideo.has(request, filmed: filmed, content: content), request: request)
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

/// Whether a session shows a filmed coach: one of its moves has a clip in the app at her level.
enum SessionVideo {
    /// Exercises with a clip in the app bundle, at each walking level (walk moves differ by level).
    static func filmed(in content: ContentBundle) -> [WalkLevel: Set<String>] {
        Dictionary(uniqueKeysWithValues: WalkLevel.allCases.map { level in
            (level, Set(content.exercises.filter {
                ExerciseVideo.firstBundled($0.videoCandidates(level: level, pace: .easy)) != nil
            }.map(\.id)))
        })
    }

    static func has(_ request: WorkoutRequest, filmed: [WalkLevel: Set<String>], content: ContentBundle) -> Bool {
        guard request.place != .outdoors, let plan = try? request.plan(content: content) else { return false }
        let level = request.place == .pad ? .pad : request.level
        return plan.exerciseIDs.contains(where: (filmed[level] ?? []).contains)
    }
}
