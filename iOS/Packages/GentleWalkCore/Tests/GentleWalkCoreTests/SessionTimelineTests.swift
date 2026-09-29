import Testing
@testable import GentleWalkCore

@Suite struct SessionTimelineTests {
    let content = TestSupport.appContent

    func firstWalk() throws -> SessionTimeline {
        let template = try #require(content.sessions.first { $0.id == "ses.firstWalk" })
        return SessionTimeline.make(plan: SessionPlan(template: template), voice: content.voiceLines)
    }

    @Test func firstWalkMatchesScript() throws {
        let timeline = try firstWalk()
        #expect(timeline.voice.count == 30)
        #expect(timeline.bells.filter { $0.kind == .phase }.map(\.at) == [27, 120, 150, 180, 210, 240])
        #expect(timeline.bells.filter { $0.kind == .done }.map(\.at) == [294])
        #expect(timeline.total == 300)
        // A line that follows a bell starts one second after it.
        let heelTaps = try #require(timeline.voice.first { $0.lineID == "a1.04" })
        #expect(heelTaps.start == 28)
        let last = try #require(timeline.voice.last)
        #expect(last.lineID == "a1.30")
        #expect(last.start == 295)
    }

    @Test func voiceLinesNeverOverlap() throws {
        let voice = try firstWalk().voice
        for (a, b) in zip(voice, voice.dropFirst()) {
            #expect(b.start >= a.end, "\(b.lineID) starts before \(a.lineID) ends")
        }
    }

    @Test func phasesCoverTheWholeSession() throws {
        let phases = try firstWalk().phases
        #expect(phases.map(\.kind) == [.intro, .warmup, .brisk, .easy, .brisk, .easy, .cooldown])
        #expect(phases.first?.start == 0)
        #expect(phases.last?.end == 300)
        for (a, b) in zip(phases, phases.dropFirst()) { #expect(a.end == b.start) }
    }

    @Test func captionIsTheExactSpokenLineAtThatMoment() throws {
        let timeline = try firstWalk()
        let captions = CaptionTimeline(timeline: timeline)
        let texts = Dictionary(uniqueKeysWithValues: content.voiceLines.map { ($0.id, $0.text) })
        for cue in timeline.voice {
            #expect(captions.caption(at: cue.start + 0.1)?.text == texts[cue.lineID])
        }
        // Between lines and during a bell there is no caption.
        #expect(captions.caption(at: 27.5) == nil)
    }

    @Test func recordedWordTimingsHighlightTheCurrentWord() {
        let line = VoiceLine(id: "x", text: "Nice and easy.", duration: 1.5, words: [
            .init(word: "Nice", start: 0, end: 0.4), .init(word: "and", start: 0.45, end: 0.6), .init(word: "easy.", start: 0.7, end: 1.2),
        ])
        let plan = SessionPlan(template: SessionTemplate(id: "t", kind: .walk, segments: [
            .init(kind: .warmup, seconds: 10, cues: [.init(at: 2, line: "x"), .init(at: 7, line: "x")]),  // second cue takes the done bell
        ]))
        let captions = CaptionTimeline(timeline: SessionTimeline.make(plan: plan, voice: [line]))
        #expect(captions.caption(at: 2.5)?.wordIndex == 1)
        #expect(captions.caption(at: 2.1)?.wordIndex == 0)
    }
}
