import Testing
import GentleWalkCore
@testable import GentleWalk

/// The tree line on Complete and Progress (review M4, 02/10/2026): never "0 of 14".
@MainActor @Suite struct TreeMilestoneTextTests {
    @Test func dayALevelIsReachedNamesTheNextOne() throws {
        let milestone = try #require(TreeLevel.milestone(activeDays: 7))
        #expect(TreeMilestoneLine.text(milestone) == "Next: Sapling, 14 active days from here.")
    }

    @Test func onTheWayCountsDays() throws {
        let milestone = try #require(TreeLevel.milestone(activeDays: 9))
        #expect(TreeMilestoneLine.text(milestone) == "2 of 14 active days to Sapling")
    }

    @Test func afterTheTreeTheNextRing() throws {
        let milestone = try #require(TreeLevel.milestone(activeDays: 42))
        #expect(TreeMilestoneLine.text(milestone) == "Next ring in 42 active days.")
    }
}
