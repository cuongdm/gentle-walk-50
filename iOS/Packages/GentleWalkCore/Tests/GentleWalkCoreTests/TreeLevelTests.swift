import Testing
@testable import GentleWalkCore

@Suite struct TreeLevelTests {
    @Test(arguments: [(0, TreeLevel.seed), (6, .seed), (7, .sprout), (13, .sprout), (21, .sapling), (41, .sapling), (42, .tree), (84, .tree)])
    func levelForActiveDays(_ days: Int, _ expected: TreeLevel) {
        #expect(TreeLevel.level(activeDays: days) == expected)
    }

    @Test func daysToNextLevel() {
        #expect(TreeLevel.daysToNext(activeDays: 13) == 8)
        #expect(TreeLevel.daysToNext(activeDays: 0) == 7)
        // After Tree the next goal is the next ring, every 42 days.
        #expect(TreeLevel.daysToNext(activeDays: 42) == 42)
        #expect(TreeLevel.daysToNext(activeDays: 90) == 36)
    }

    @Test func ringsAfterTree() {
        #expect(TreeLevel.rings(activeDays: 41) == 0)
        #expect(TreeLevel.rings(activeDays: 83) == 0)
        #expect(TreeLevel.rings(activeDays: 84) == 1)
        #expect(TreeLevel.rings(activeDays: 126) == 2)
    }
}
