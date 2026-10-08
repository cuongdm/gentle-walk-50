import Foundation
import Testing
@testable import GentleWalkCore

/// "Hear your coach · 10 seconds" on Your plan (plan 08/10/2026 task 2.11): the first two lines of the
/// First Walk, back to back, voice only.
@Suite struct CoachPreviewTimelineTests {
    @Test func twoOpeningLinesOfTheFirstWalkUnderTwelveSeconds() {
        let timeline = SessionTimeline.coachPreview(voice: TestSupport.appContent.voiceLines)
        #expect(timeline.voice.map(\.lineID) == ["a1.01", "a1.02"])
        #expect(SessionTimeline.coachPreviewLineIDs == ["a1.01", "a1.02"])
        #expect(timeline.voice[0].start == 0)
        // The second line follows the first with a short breath, never over it.
        #expect(timeline.voice[1].start >= timeline.voice[0].end)
        #expect(timeline.voice[1].start <= timeline.voice[0].end + 0.5)
        #expect(timeline.total == timeline.voice[1].end)
        #expect(timeline.total >= 10 && timeline.total <= 12)
        #expect(timeline.bells.isEmpty)
        #expect(timeline.phases.isEmpty)
    }

    /// They are the lines the First Walk really opens with.
    @Test func linesOpenTheFirstWalk() throws {
        let firstWalk = try #require(TestSupport.appContent.sessions.first { $0.id == "ses.firstWalk" })
        let opening = firstWalk.segments.flatMap(\.cues).map(\.line).prefix(2)
        #expect(Array(opening) == SessionTimeline.coachPreviewLineIDs)
    }
}
