import Testing
@testable import GentleWalkCore

@Suite struct BodyLimitFilterTests {
    let all = TestSupport.appContent.exercises

    @Test func jointReplacementHidesTheCrossedLegThighStretch() {
        let ids = BodyLimitFilter.allowed(all, limits: [.jointReplacement]).map(\.id)
        #expect(!ids.contains("st.thigh"))
        #expect(ids.count == all.count - 1)
    }

    @Test func standingIsHardHidesStandingMovesButKeepsSitToStand() {
        let ids = BodyLimitFilter.allowed(all, limits: [.standingIsHard]).map(\.id)
        // A4 §5.5: the wall push-up and every move standing behind the chair.
        for hidden in ["mv.wall-push", "mv.single-leg", "mv.side-leg", "mv.back-leg", "mv.knee-curl", "mv.mini-squat",
                       "st.calf", "bl.tandem", "bl.side-walk"] {
            #expect(!ids.contains(hidden), "\(hidden)")
        }
        #expect(ids.contains("mv.sit-to-stand"))
        #expect(ids.contains("mv.knee-lift"))
        #expect(ids.contains("st.overhead"))  // done seated instead
    }

    @Test func noFloorChangesNothingBecauseThereAreNoFloorExercises() {
        #expect(BodyLimitFilter.allowed(all, limits: [.noFloor]) == all)
    }

    @Test func noLimitsKeepsEverything() {
        #expect(BodyLimitFilter.allowed(all, limits: []) == all)
    }

    @Test func easierVersionIsTheDefaultForMatchingLimits() {
        #expect(BodyLimitFilter.startsEasier(TestSupport.exercise("mv.sit-to-stand"), limits: [.knees]))
        #expect(!BodyLimitFilter.startsEasier(TestSupport.exercise("mv.sit-to-stand"), limits: [.shoulders]))
    }
}
