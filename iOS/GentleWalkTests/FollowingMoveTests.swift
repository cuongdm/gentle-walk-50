import Testing
@testable import GentleWalk

/// "Next: …" under the move bar (review M5, 02/10/2026).
@MainActor @Suite struct FollowingMoveTests {
    private let names = ["st.chest": "Chest opener", "st.twist": "Upper back twist", "st.thigh": "Back of thigh"]
    private var ids: [String?] { ["st.chest", "st.twist", "st.twist", "st.thigh"] }

    @Test func nextDifferentMoveIsItsName() {
        #expect(FollowingMove.label(ids: ids, index: 0) { names[$0] } == "Upper back twist")
    }

    @Test func sameMoveAgainSaysOnceMore() {
        #expect(FollowingMove.label(ids: ids, index: 1) { names[$0] } == "Upper back twist, once more")
    }

    @Test func lastMoveHasNoNext() {
        #expect(FollowingMove.label(ids: ids, index: 3) { names[$0] } == nil)
    }
}
