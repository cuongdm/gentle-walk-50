import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

@MainActor @Suite struct JourneySnapshotTests {
    let ny = TestFixtures.content.journeys.first { $0.id == "jr.ny" }!
    let smoky = TestFixtures.content.journeys.first { $0.id == "jr.smoky" }!
    let day = Date(timeIntervalSince1970: 1_790_000_000)

    @Test func stopsReadAsReachedNextAndAhead() {
        let snapshot = JourneySnapshot(journeyID: ny.id, journey: ny, totalMiles: 1.8, routeMiles: 1.8,
                                       unlocked: ["pc.ny.zoo", "pc.ny.bethesda"], completedJourneys: [],
                                       nextStop: ny.stops[2], milesToNext: 0.4, isLockedAhead: false,
                                       openedOn: ["pc.ny.bethesda": day])
        #expect(snapshot.status(of: ny.stops[0]) == .reached(on: nil))
        #expect(snapshot.status(of: ny.stops[1]) == .reached(on: day))
        #expect(snapshot.status(of: ny.stops[2]) == .next(milesToGo: 0.4))
        #expect(snapshot.status(of: ny.stops[3]) == .ahead)
    }

    @Test func aFreeRouteLocksEveryStopPastItsLimit() {
        let snapshot = JourneySnapshot(journeyID: smoky.id, journey: smoky, totalMiles: 3, routeMiles: 0,
                                       unlocked: ["pc.smoky.1"], completedJourneys: [], nextStop: smoky.stops[1],
                                       milesToNext: 2.4, isLockedAhead: true, limitMile: 0)
        #expect(snapshot.status(of: smoky.stops[0]) == .reached(on: nil))
        #expect(snapshot.status(of: smoky.stops[1]) == .locked)
        #expect(snapshot.status(of: smoky.stops[5]) == .locked)
    }
}
