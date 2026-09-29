import AVFoundation
import Testing
@testable import GentleWalk

@MainActor @Suite struct SessionInterruptionTests {
    func post(_ type: AVAudioSession.InterruptionType, on center: NotificationCenter) {
        center.post(name: AVAudioSession.interruptionNotification, object: nil,
                    userInfo: [AVAudioSessionInterruptionTypeKey: type.rawValue])
    }

    @Test func callPausesAndDoesNotAutoResume() async throws {
        let center = NotificationCenter()
        let engine = FakePlaybackEngine()
        let player = SessionPlayer(engine: engine, notificationCenter: center)
        try await player.load(TestFixtures.firstWalkTimeline())
        player.play()
        post(.began, on: center)
        #expect(player.state == .paused(.interrupted))
        #expect(!engine.isPlaying)
        post(.ended, on: center)
        #expect(player.state == .paused(.interrupted))
        #expect(!engine.isPlaying)
    }

    @Test func interruptionWhilePausedByUserKeepsTheUserPause() async throws {
        let center = NotificationCenter()
        let player = SessionPlayer(engine: FakePlaybackEngine(), notificationCenter: center)
        try await player.load(TestFixtures.firstWalkTimeline())
        player.play()
        player.pause(.user)
        post(.began, on: center)
        #expect(player.state == .paused(.user))
    }
}
