import Foundation
import GentleWalkCore

/// Two small things the stage recaps remember (docs/plans/2026-10-09-plan-journey-link.md), in UserDefaults like
/// the ladders (on the device only; "Delete all my data" clears them through `AppDefaultsKeys`):
/// the breaks she picked up from in this round, so sessions before a break keep their stage, and the
/// "Stage N is done" card she tapped away (like `healthCardDismissed`).
@MainActor struct ProgramMemoryStore {
    static let pausesKey = "programPauses"
    static let stageCardKey = "stageRecapSeen"
    let defaults: UserDefaults

    var pauses: [ProgramPause] { decode([ProgramPause].self, Self.pausesKey) ?? [] }

    func addPause(_ pause: ProgramPause) {
        encode(pauses + [pause], Self.pausesKey)
    }

    /// A new round starts fresh: its weeks owe nothing to the last round's breaks.
    func clearPauses() { defaults.removeObject(forKey: Self.pausesKey) }

    var dismissedStage: StageMark? { decode(StageMark.self, Self.stageCardKey) }

    func dismissStage(_ mark: StageMark) { encode(mark, Self.stageCardKey) }

    private func decode<T: Decodable>(_ type: T.Type, _ key: String) -> T? {
        defaults.data(forKey: key).flatMap { try? JSONDecoder().decode(type, from: $0) }
    }

    private func encode(_ value: some Encodable, _ key: String) {
        if let data = try? JSONEncoder().encode(value) { defaults.set(data, forKey: key) }
    }
}
