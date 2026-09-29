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
        engine.advance(to: 125)
        #expect(player.currentPhase?.kind == .brisk)
        #expect(player.caption?.lineID == "a1.13")
        #expect(player.remainingInPhase == 25)
        #expect(player.phaseIndex == 2)
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

    @Test func reachingTheEndFinishes() async throws {
        let (player, engine) = try await player()
        player.play()
        engine.advance(to: 300)
        #expect(player.state == .finished)
    }
}
