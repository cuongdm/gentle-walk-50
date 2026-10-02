import AVFoundation
import Testing
import GentleWalkCore
@testable import GentleWalk

/// Test double: records calls and lets the test drive the clock.
@MainActor final class FakePlaybackEngine: PlaybackEngine {
    var onTime: ((Double) -> Void)?
    var onEnd: (() -> Void)?
    private(set) var loaded: [SessionTimeline] = []
    private(set) var isPlaying = false
    private(set) var seeks: [Double] = []

    func load(_ timeline: SessionTimeline) async throws { loaded.append(timeline) }
    func play() { isPlaying = true }
    func pause() { isPlaying = false }
    func seek(to seconds: Double) { seeks.append(seconds) }
    private(set) var voiceOn = true
    func setVoiceOn(_ on: Bool) { voiceOn = on }
    private(set) var musicOn = true
    func setMusicOn(_ on: Bool) { musicOn = on }
    private(set) var levels: [Float] = []
    func setLevels(voice: Float, music: Float) { levels = [voice, music] }
    func advance(to seconds: Double) { onTime?(seconds) }
}

@MainActor @Suite struct SessionPlayerTests {
    func player() async throws -> (SessionPlayer, FakePlaybackEngine) {
        let engine = FakePlaybackEngine()
        let player = SessionPlayer(engine: engine, notificationCenter: NotificationCenter())
        try await player.load(TestFixtures.firstWalkTimeline())
        return (player, engine)
    }

    @Test func playPauseResume() async throws {
        let (player, engine) = try await player()
        #expect(player.state == .ready)
        player.play()
        #expect(player.state == .playing)
        #expect(engine.isPlaying)
        player.pause(.user)
        #expect(player.state == .paused(.user))
        #expect(!engine.isPlaying)
        player.resume()
        #expect(player.state == .playing)
    }

    @Test func clockDrivesPhaseCaptionAndRemainingTime() async throws {
        let (player, engine) = try await player()
        player.play()
        engine.advance(to: 122.5)
        #expect(player.currentPhase?.kind == .brisk)
        #expect(player.caption?.lineID == "a1.13")
        #expect(player.remainingInPhase == 28)
        #expect(player.phaseIndex == 2)
    }

    /// Walk home gently ends at infinity: the clock goes on without a countdown, and nothing traps
    /// (Int(.infinity) crashed the app, review 02/10/2026).
    @Test func walkHomeGentlyRunsOpenEnded() async throws {
        let (player, engine) = try await player()
        player.play()
        engine.advance(to: 122.5)
        try await player.apply(.walkHomeGently)
        engine.advance(to: 300)
        #expect(player.currentPhase?.end == .infinity)
        #expect(player.remainingInPhase == 0)
        #expect(player.state == .playing)
        #expect(player.timeline.isOpenEnded)
        engine.advance(to: 10_000)
        #expect(player.state == .playing)
    }

    @Test func easierVersionRebuildsAndSeeksToTheSameMoment() async throws {
        let engine = FakePlaybackEngine()
        let player = SessionPlayer(engine: engine, notificationCenter: NotificationCenter())
        let content = TestFixtures.content
        let plan = try SessionBuilder.build(kind: PlannedDay(main: .chair, chairMoves: 0, cooldown: true), level: .seated,
                                            intensity: .gentle, limits: [], rotationIndex: 0, content: content)
        try await player.load(SessionTimeline.make(plan: plan, voice: content.voiceLines))
        player.play()
        let move = try #require(player.timeline.phases.first { $0.kind == .move })
        engine.advance(to: move.start + 20)
        try await player.apply(.easierVersion(exerciseID: move.exerciseID!))
        #expect(engine.loaded.count == 2)
        #expect(engine.seeks.last == move.start + 20)
        #expect(player.currentPhase?.isEasier == true)
        #expect(player.state == .playing)
    }

    /// Owner's screen recording 01/10: Skip must be one seek on the media already loaded, never a
    /// rebuild. Three quick taps skip three parts; the program and the media then differ by the cuts.
    @Test func skipIsAnInstantSeekOverTheCutMedia() async throws {
        let engine = FakePlaybackEngine()
        let player = SessionPlayer(engine: engine, notificationCenter: NotificationCenter())
        let content = TestFixtures.content
        let plan = try SessionBuilder.build(kind: PlannedDay(main: .chair, chairMoves: 0, cooldown: true), level: .seated,
                                            intensity: .gentle, limits: [], rotationIndex: 0, content: content)
        let original = SessionTimeline.make(plan: plan, voice: content.voiceLines)
        try await player.load(original)
        player.play()
        let move = try #require(original.phases.first { $0.kind == .move })
        let index = try #require(original.phases.firstIndex(of: move))
        let at = move.start + 5
        engine.advance(to: at)
        player.skip()
        player.skip()
        player.skip()
        #expect(engine.loaded.count == 1)
        #expect(player.phaseIndex == index + 3)
        #expect(player.currentTime == at)
        #expect(player.moveDirection == .forward)
        #expect(!player.timeline.voice.contains { $0.lineID == "a7.hurt.skip" })
        // Media time of the next part = program time + what was cut.
        let cut = (move.end - at) + (original.phases[index + 1].end - original.phases[index + 1].start)
            + (original.phases[index + 2].end - original.phases[index + 2].start)
        #expect(engine.seeks.last == at + cut)
        // The engine lands a hair early: still read as the new part, never "00:01" of the old one.
        engine.advance(to: at + cut - 0.02)
        #expect(player.phaseIndex == index + 3)
        #expect(player.currentTime == at)
        engine.advance(to: at + cut + 10)
        #expect(player.currentTime == at + 10)
        // Back into the shortened move, then playing on jumps over the cut media.
        player.seek(to: move.start)
        #expect(player.moveDirection == .backward)
        #expect(engine.seeks.last == move.start)
        engine.advance(to: at + 1)   // media inside the cut
        #expect(engine.seeks.last == at + cut)
        #expect(player.phaseIndex == index + 3)
    }

    @Test func reachingTheEndFinishes() async throws {
        let (player, engine) = try await player()
        player.play()
        engine.advance(to: 300)
        #expect(player.state == .finished)
    }
}
