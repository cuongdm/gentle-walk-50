import Foundation

/// The id of the cheer Complete showed last (plan 08/10/2026 task 3.6), so the next session never gets
/// the same line twice in a row, even after the app was closed. "Delete all my data" clears it
/// (`AppDefaultsKeys`).
@MainActor struct CheerMemoryStore {
    static let defaultsKey = "lastCheerID"
    let defaults: UserDefaults

    var lastID: String? {
        get { defaults.string(forKey: Self.defaultsKey) }
        nonmutating set { defaults.set(newValue, forKey: Self.defaultsKey) }
    }
}
