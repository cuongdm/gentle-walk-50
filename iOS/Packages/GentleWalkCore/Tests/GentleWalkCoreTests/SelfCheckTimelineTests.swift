import Foundation
import Testing
@testable import GentleWalkCore

/// The 30-second self-check audio (steady program task 4.7).
@Suite struct SelfCheckTimelineTests {
    @Test func thirtySecondsWithCountdownBellsAndStop() {
        let timeline = SessionTimeline.selfCheck(voice: TestSupport.appContent.voiceLines)
        let at = Dictionary(timeline.voice.map { ($0.lineID, $0.start) }, uniquingKeysWith: { first, _ in first })
        let go = SessionTimeline.selfCheckGoAt
        #expect(at["a5.n.3"] == go - 3 && at["a5.n.2"] == go - 2 && at["a5.n.1"] == go - 1)
        #expect(at["a12.check.go"] == go)
        #expect(at["a5.half"] == go + 15)
        #expect(at["a12.check.stop"] == go + 30)
        #expect(timeline.bells.map(\.at) == [go, go + 15, go + 30])
        #expect(timeline.bells.last?.kind == .done)
        #expect(timeline.total <= 40)
        #expect(timeline.voice.map(\.lineID) == SessionTimeline.selfCheckLineIDs)
    }

    /// The setup line ends before the count starts, so nothing talks over "Three".
    @Test func setupLineFitsBeforeTheCount() {
        let timeline = SessionTimeline.selfCheck(voice: TestSupport.appContent.voiceLines)
        let setup = timeline.voice.first { $0.lineID == "a12.check.setup" }
        #expect(setup.map { $0.end <= SessionTimeline.selfCheckGoAt - 3 + 0.01 } ?? false)
        #expect(timeline.voice.allSatisfy { !$0.text.isEmpty })
    }

    /// Every line of the self-check is in the content, in English and Vietnamese (task 5.2).
    @Test func steadyProgramLinesExist() throws {
        let english = Set(TestSupport.appContent.voiceLines.map(\.id))
        #expect(Set(SessionTimeline.selfCheckLineIDs).isSubset(of: english))
        let vietnamese = Set(SessionSyncTests.vietnamese.voiceLines.filter { !$0.text.isEmpty }.map(\.id))
        #expect(Set(SessionTimeline.selfCheckLineIDs).isSubset(of: vietnamese))
    }
}
