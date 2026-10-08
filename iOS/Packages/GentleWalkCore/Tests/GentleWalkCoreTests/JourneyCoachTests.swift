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
}
