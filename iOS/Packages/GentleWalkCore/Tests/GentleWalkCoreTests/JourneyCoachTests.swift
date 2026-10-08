import Foundation
import Testing
@testable import GentleWalkCore

/// Anti-boredom #7: every stop of every journey has its own coach line, as New York does.
@Suite struct JourneyCoachTests {
    @Test func everyStopHasALineInBothLanguages() {
        let content = TestSupport.appContent
        let vietnamese = Dictionary(SessionSyncTests.vietnamese.voiceLines.map { ($0.id, $0.text) }, uniquingKeysWith: { a, _ in a })
        let english = Dictionary(content.voiceLines.map { ($0.id, $0.text) }, uniquingKeysWith: { a, _ in a })
        for journey in content.journeys {
            #expect(journey.stops.count == 6, "\(journey.id)")
            for (index, stop) in journey.stops.enumerated() {
                let id = JourneyCoach.lineID(journeyID: journey.id, stopIndex: index, content: content)
                #expect(id == "a8.\(JourneyCoach.route(of: journey.id)).\(index + 1)", "\(journey.id) \(stop.id)")
                if let id {
                    #expect(vietnamese[id]?.isEmpty == false && vietnamese[id] != english[id], "VI \(id)")
                    // The new Pro lines keep to 14 words (New York's were written earlier, one runs to 15).
                    if journey.id != "jr.ny" { #expect((english[id] ?? "").split(separator: " ").count <= 14, "\(id) is short") }
                }
            }
        }
        #expect(JourneyCoach.lineID(journeyID: "jr.ny", stopIndex: 6, content: content) == nil)
    }

    /// The line said on Complete when a session reaches stops: the furthest stop reached this time, so
    /// two postcards in one session get one line, not two in a row.
    @Test func arrivalLineIsTheFurthestStopReached() throws {
        let content = TestSupport.appContent
        let smoky = try #require(content.journeys.first { $0.id == "jr.smoky" })
        let ids = smoky.stops.map(\.id)
        #expect(JourneyCoach.arrivalLineID(journey: smoky, unlocked: [ids[0]], content: content) == "a8.smoky.1")
        #expect(JourneyCoach.arrivalLineID(journey: smoky, unlocked: [ids[2], ids[1]], content: content) == "a8.smoky.3")
        #expect(JourneyCoach.arrivalLineID(journey: smoky, unlocked: [ids[5]], content: content) == "a8.smoky.6")
        // No new stop: nothing to say. A stop from another route: nothing either.
        #expect(JourneyCoach.arrivalLineID(journey: smoky, unlocked: [], content: content) == nil)
        #expect(JourneyCoach.arrivalLineID(journey: smoky, unlocked: ["pc.ny.zoo"], content: content) == nil)
        let ny = try #require(content.journeys.first { $0.id == "jr.ny" })
        #expect(JourneyCoach.arrivalLineID(journey: ny, unlocked: [ny.stops[3].id], content: content) == "a8.ny.4")
    }
}
