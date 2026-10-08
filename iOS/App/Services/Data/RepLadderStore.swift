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
    /// `holdRaises`: a hard week (P6) or a 2-week check down by two (P9): no step up yet.
    func record(done: [String: Int], steady: Set<String>, troubled: Set<String>, shown: Set<String>, holdRaises: Bool = false) {
        var current = progress
        for id in shown { current[id]?.pendingChange = nil }
        save(RepLadder.update(current, done: done, steady: steady, troubled: troubled, holdRaises: holdRaises))
    }

    /// Today's reps per counted move for a Pro session (empty for free: the day's own reps). `trend`: her
    /// latest 2-week check (P9); `harder`: moves where Harder was done in full lately (P5, D10).
    func today(intensity: Intensity, limits: Set<BodyLimit>, isPro: Bool, trend: SelfCheckTrend = .flat,
               harder: Set<String> = []) -> [String: RepStep] {
        guard isPro else { return [:] }
        let current = progress
        return Dictionary(uniqueKeysWithValues: RepLadder.exercises.map {
            ($0, RepLadder.today($0, progress: current, intensity: intensity, limits: limits, trend: trend,
                                 bonusCap: harder.contains($0) ? 1 : 0))
        })
    }

    /// Back after a long break (P13): every counted move one step down.
    func stepDownAll() { save(RepLadder.stepDownAll(progress)) }
}
