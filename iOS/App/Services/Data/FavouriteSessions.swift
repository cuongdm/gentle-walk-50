import Foundation
import GentleWalkCore
import Observation

/// Sessions she hearted in "All sessions" (milestone 10), in the order she added them. Stored as
/// catalog ids in UserDefaults; "Delete all my data" clears them (`AppDefaultsKeys`).
@Observable @MainActor final class FavouriteSessions {
    static let defaultsKey = "favouriteSessions"

    private(set) var ids: [String]
    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
        // Ids of sessions no longer in the catalog are dropped quietly.
        let stored = defaults.stringArray(forKey: Self.defaultsKey) ?? []
        ids = stored.filter { SessionCatalog.preset(id: $0) != nil }
    }

    func contains(_ id: String) -> Bool { ids.contains(id) }

    func toggle(_ id: String) {
        if let index = ids.firstIndex(of: id) { ids.remove(at: index) } else { ids.append(id) }
        defaults.set(ids, forKey: Self.defaultsKey)
    }
}
