import Testing
@testable import GentleWalkCore

/// One stretch done on both sides, or held twice in a row, counts once: the preview's list and the
/// player's "Stretch 2 of 5" count the same way (review C, 09/10/2026).
@Suite struct MoveRunsTests {
    let seated: [String?] = ["st.neck-turn", "st.chin-tuck", "st.chest", "st.chest", "st.twist", "st.twist", "st.thigh", "st.thigh", "st.ankle"]

    @Test func consecutiveRepeatsAreOneStretch() {
        #expect(MoveRuns.list(seated) == ["st.neck-turn", "st.chin-tuck", "st.chest", "st.twist", "st.thigh", "st.ankle"])
        #expect(MoveRuns.positions(seated) == [0, 1, 2, 2, 3, 3, 4, 4, 5])
    }

    @Test func aStretchThatComesBackLaterCountsAgain() {
        let ids: [String?] = ["st.chest", "st.twist", "st.chest"]
        #expect(MoveRuns.list(ids) == ["st.chest", "st.twist", "st.chest"])
        #expect(MoveRuns.positions(ids) == [0, 1, 2])
    }

    @Test func movesWithoutAnExerciseEachCount() {
        #expect(MoveRuns.positions([nil, nil, "st.calf"]) == [0, 1, 2])
        #expect(MoveRuns.positions([]) == [])
    }

    /// The player's "Stretch n of N" from one source: position of the move under way and the number of runs.
    @Test func positionLabelNumbers() {
        #expect(MoveRuns.position(of: 3, in: seated) == MoveRuns.Position(number: 3, count: 6))
        #expect(MoveRuns.position(of: 8, in: seated) == MoveRuns.Position(number: 6, count: 6))
        #expect(MoveRuns.position(of: 20, in: seated) == MoveRuns.Position(number: 6, count: 6))
        #expect(MoveRuns.position(of: 0, in: []) == nil)
    }
}
