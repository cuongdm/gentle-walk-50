import Foundation
import GentleWalkCore

/// The walking level she is on now (plan 08/10/2026, decision D1). `UserProfile.startLevel` keeps
/// meaning "where she started"; this store holds the current level, when it last changed and the
/// Today card that explains the change until she has seen it. One small JSON value in UserDefaults,
/// like the ladders; "Delete all my data" clears it (`AppDefaultsKeys`).
@MainActor struct WalkLevelStore {
    static let defaultsKey = "walkLevel"
    let defaults: UserDefaults

    private struct Stored: Codable {
        var level: WalkLevel
        var changedAt: Date
        var card: AdaptationCard?
        /// How many times the level has changed (DEBUG counters in Me, plan decision D15).
        var changes: Int?
    }

    private var stored: Stored? {
        guard let data = defaults.data(forKey: Self.defaultsKey) else { return nil }
        return try? JSONDecoder().decode(Stored.self, from: data)
    }

    private func save(_ value: Stored) {
        if let data = try? JSONEncoder().encode(value) { defaults.set(data, forKey: Self.defaultsKey) }
    }

    /// The current level, or the start level when it has never changed.
    func state(startLevel: WalkLevel) -> LevelState {
        guard let stored else { return LevelState(level: startLevel, changedAt: nil) }
        return LevelState(level: stored.level, changedAt: stored.changedAt)
    }

    /// When the level last changed (`nil` = still the start level).
    var changedAt: Date? { stored?.changedAt }

    /// The card that explains the last change, until it is cleared.
    var pendingCard: AdaptationCard? { stored?.card }

    /// How many times the level has changed since onboarding.
    var changeCount: Int { stored?.changes ?? 0 }

    func set(level: WalkLevel, changedAt: Date, card: AdaptationCard?) {
        save(Stored(level: level, changedAt: changedAt, card: card, changes: changeCount + 1))
    }

    func clearCard() {
        guard var value = stored, value.card != nil else { return }
        value.card = nil
        save(value)
    }
}
