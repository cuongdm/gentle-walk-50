import Foundation
import GentleWalkCore

/// The rep ladder of the leg-strength moves (Pro, steady program task 3.3): her step per move, kept in
/// UserDefaults like the support ladder (a few small values, on the device only). "Delete all my data"
/// clears it (`AppDefaultsKeys`).
@MainActor struct RepLadderStore {
    static let defaultsKey = "repLadder"
    let defaults: UserDefaults

    var progress: [String: RepProgress] {
        guard let data = defaults.data(forKey: Self.defaultsKey),
              let stored = try? JSONDecoder().decode([String: RepProgress].self, from: data) else { return [:] }
        return stored
    }

    private func save(_ progress: [String: RepProgress]) {
        if let data = try? JSONEncoder().encode(progress) { defaults.set(data, forKey: Self.defaultsKey) }
    }

    /// After a session: `done` is the step each counted move was done at; steps up or down, and marks
    /// the changes Complete has just shown as said.
    func record(done: [String: Int], steady: Set<String>, troubled: Set<String>, shown: Set<String>) {
        var current = progress
        for id in shown { current[id]?.pendingChange = nil }
        save(RepLadder.update(current, done: done, steady: steady, troubled: troubled))
    }

    /// Today's reps per counted move for a Pro session (empty for free: the day's own reps).
    func today(intensity: Intensity, limits: Set<BodyLimit>, isPro: Bool) -> [String: RepStep] {
        guard isPro else { return [:] }
        let current = progress
        return Dictionary(uniqueKeysWithValues: RepLadder.exercises.map {
            ($0, RepLadder.today($0, progress: current, intensity: intensity, limits: limits))
        })
    }
}
