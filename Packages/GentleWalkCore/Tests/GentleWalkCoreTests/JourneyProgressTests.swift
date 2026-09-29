import Testing
@testable import GentleWalkCore

@Suite struct JourneyProgressTests {
    let journey = TestSupport.newYorkJourney

    @Test func crossingTimesSquareUnlocksIt() {
        let step = JourneyProgress.advance(journey: journey, from: 1.8, to: 2.3)
        #expect(step.unlocked == ["pc.ny.times"])
        #expect(step.next?.id == "pc.ny.bryant")
        #expect(abs(step.milesToNext - 0.5) < 0.000_1)
        #expect(!step.isComplete)
    }

    @Test func firstWalkUnlocksCentralParkZoo() {
        let step = JourneyProgress.advance(journey: journey, from: 0, to: 0.25)
        #expect(step.unlocked == ["pc.ny.zoo"])
        #expect(step.next?.id == "pc.ny.bethesda")
    }

    @Test func oneLongWalkCanUnlockSeveralStops() {
        let step = JourneyProgress.advance(journey: journey, from: 0.9, to: 3.0)
        #expect(step.unlocked == ["pc.ny.bethesda", "pc.ny.times", "pc.ny.bryant"])
    }

    @Test func reachingTheLastStopCompletesTheJourney() {
        let step = JourneyProgress.advance(journey: journey, from: 4.8, to: 5.3)
        #expect(step.unlocked == ["pc.ny.bridge"])
        #expect(step.next == nil)
        #expect(step.milesToNext == 0)
        #expect(step.isComplete)
    }

    @Test func noMovementUnlocksNothing() {
        #expect(JourneyProgress.advance(journey: journey, from: 0, to: 0).unlocked.isEmpty)
        #expect(JourneyProgress.advance(journey: journey, from: 2.3, to: 2.3).unlocked.isEmpty)
    }
}
