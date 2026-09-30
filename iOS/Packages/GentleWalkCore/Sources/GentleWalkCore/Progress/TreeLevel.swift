/// The tree that grows with active days (spec: Seed · Sprout · Sapling · Tree at 7 · 21 · 42 days,
/// then one year ring every further 42 days; decided 29/09/2026, kept as constants to tune later).
public enum TreeLevel: Int, CaseIterable, Comparable, Sendable {
    case seed, sprout, sapling, tree

    /// Active days needed for sprout, sapling and tree.
    public static let thresholds = [7, 21, 42]
    /// Active days per year ring after Tree.
    public static let ringEvery = 42

    public static func < (lhs: TreeLevel, rhs: TreeLevel) -> Bool { lhs.rawValue < rhs.rawValue }

    public static func level(activeDays: Int) -> TreeLevel {
        let passed = thresholds.filter { activeDays >= $0 }.count
        return TreeLevel(rawValue: passed) ?? .tree
    }

    /// Days to the next level, or to the next ring once the tree is grown.
    public static func daysToNext(activeDays: Int) -> Int {
        let days = max(0, activeDays)
        if let next = thresholds.first(where: { days < $0 }) { return next - days }
        let treeAt = thresholds.last ?? 0
        let nextRing = treeAt + ringEvery * (rings(activeDays: days) + 1)
        return nextRing - days
    }

    /// Year rings on the trunk: one per full 42 days after reaching Tree.
    public static func rings(activeDays: Int) -> Int {
        let treeAt = thresholds.last ?? 0
        guard activeDays >= treeAt else { return 0 }
        return (activeDays - treeAt) / ringEvery
    }
}

public extension TreeLevel {
    /// "5 of 7 active days to Sprout": the stretch from the last level (or ring) to the next one.
    struct Milestone: Equatable, Sendable {
        public var done: Int
        public var total: Int
        /// The level ahead; nil once the tree is grown (the goal is then the next year ring).
        public var next: TreeLevel?
    }

    static func milestone(activeDays: Int) -> Milestone? {
        let days = max(0, activeDays)
        let starts = [0] + thresholds
        if let index = thresholds.firstIndex(where: { days < $0 }) {
            let from = starts[index]
            return Milestone(done: days - from, total: thresholds[index] - from, next: TreeLevel(rawValue: index + 1))
        }
        let treeAt = thresholds.last ?? 0
        let from = treeAt + ringEvery * rings(activeDays: days)
        return Milestone(done: days - from, total: ringEvery, next: nil)
    }
}
