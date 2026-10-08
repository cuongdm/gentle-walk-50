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
    /// `holdRaises`: a hard week (P6) or a 2-week check down by two (P9): no step up yet.
    func record(steady: Set<String>, troubled: Set<String>, announced: Set<String>, holdRaises: Bool = false) {
        var current = progress
        for id in announced { current[id]?.pendingChange = nil }
        save(SupportLadder.update(current, steady: steady, troubled: troubled, holdRaises: holdRaises))
    }

    /// Back after a long break (P13): every balance exercise one step down; the coach says so next time.
    func stepDownAll() { save(SupportLadder.stepDownAll(progress)) }
}
