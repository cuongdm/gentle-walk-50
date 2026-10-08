/// Counting the moves of a block the way she sees them: one stretch done on both sides, or held twice in
/// a row, is one stretch. The workout preview lists `list(_:)` and the stretch player's "Stretch 2 of 5"
/// comes from `position(of:in:)`, so the two always agree (review C, 09/10/2026). A move with no exercise
/// counts on its own; a stretch that comes back later in the block counts again.
public enum MoveRuns {
    public struct Position: Equatable, Sendable {
        /// 1-based.
        public var number: Int
        public var count: Int
    }

    /// The run each move belongs to, in order: [chest, chest, twist] → [0, 0, 1].
    public static func positions(_ ids: [String?]) -> [Int] {
        var result: [Int] = []
        var run = -1
        for (i, id) in ids.enumerated() {
            if i == 0 || id == nil || id != ids[i - 1] { run += 1 }
            result.append(run)
        }
        return result
    }

    /// One entry per run: [chest, chest, twist] → [chest, twist].
    public static func list(_ ids: [String?]) -> [String?] {
        let runs = positions(ids)
        return ids.indices.filter { $0 == 0 || runs[$0] != runs[$0 - 1] }.map { ids[$0] }
    }

    /// "n of N" for the move at `index` (clamped to the last move); nil without moves.
    public static func position(of index: Int, in ids: [String?]) -> Position? {
        guard !ids.isEmpty else { return nil }
        let runs = positions(ids)
        let at = min(max(index, 0), ids.count - 1)
        return Position(number: runs[at] + 1, count: (runs.last ?? 0) + 1)
    }
}
