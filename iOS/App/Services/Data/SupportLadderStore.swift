import Foundation
import GentleWalkCore

/// The support ladder of the balance exercises (Pro, review 06/10/2026): her step per exercise, kept
/// in UserDefaults like favourites (a few small values, on the device only). "Delete all my data"
/// clears it (`AppDefaultsKeys`).
@MainActor struct SupportLadderStore {
    static let defaultsKey = "supportLadder"
    let defaults: UserDefaults

    var progress: [String: SupportProgress] {
        guard let data = defaults.data(forKey: Self.defaultsKey),
              let stored = try? JSONDecoder().decode([String: SupportProgress].self, from: data) else { return [:] }
        return stored
    }

    private func save(_ progress: [String: SupportProgress]) {
        if let data = try? JSONEncoder().encode(progress) { defaults.set(data, forKey: Self.defaultsKey) }
    }

    /// After a session: steps up or down, and marks the changes the coach has just announced as said.
    func record(steady: Set<String>, troubled: Set<String>, announced: Set<String>) {
        var current = progress
        for id in announced { current[id]?.pendingChange = nil }
        save(SupportLadder.update(current, steady: steady, troubled: troubled))
    }
}
