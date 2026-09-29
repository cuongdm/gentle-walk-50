import Testing
@testable import GentleWalkCore

@Suite struct BodyLimitFilterTests {
    let all = TestSupport.appContent.exercises

    @Test func jointReplacementHidesTheCrossedLegThighStretch() {
        let ids = BodyLimitFilter.allowed(all, limits: [.jointReplacement]).map(\.id)
        #expect(!ids.contains("st.thigh"))
        #expect(ids.count == all.count - 1)
    }

    @Test func standingIsHardHidesUnsupportedStandingButKeepsChairMoves() {
        let ids = BodyLimitFilter.allowed(all, limits: [.standingIsHard]).map(\.id)
        #expect(!ids.contains("mv.wall-push"))
        #expect(!ids.contains("st.calf"))
        // Standing with the chair to hold stays.
        #expect(ids.contains("mv.sit-to-stand"))
        #expect(ids.contains("mv.single-leg"))
        #expect(ids.contains("mv.knee-lift"))
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
