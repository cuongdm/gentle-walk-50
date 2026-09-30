import Foundation
import Testing
@testable import GentleWalk

/// Coach voice and music volumes, and move introductions (competitor idea 4, 30/09/2026).
@MainActor @Suite(.serialized) struct AudioLevelsTests {
    let defaults: UserDefaults = {
        let defaults = UserDefaults(suiteName: "audio-levels-tests")!
        defaults.removePersistentDomain(forName: "audio-levels-tests")
        return defaults
    }()

    @Test func defaultsAreFullVoiceAndIntroductionsOn() {
        let levels = AudioLevels.saved(in: defaults)
        #expect(levels.voice == 1)
        #expect(levels.music == AudioLevels.defaultMusic)
        #expect(levels.moveIntroductions)
    }

    @Test func savedValuesComeBackAndStayInRange() {
        AudioLevels(voice: 0.1, music: 1.4, moveIntroductions: false).save(in: defaults)
        let levels = AudioLevels.saved(in: defaults)
        // The coach never goes quieter than the floor, so she can always be heard.
        #expect(levels.voice == AudioLevels.voiceFloor)
        #expect(levels.music == 1)
        #expect(!levels.moveIntroductions)
    }

    @Test func eraseRemovesTheLevels() {
        #expect(AppDefaultsKeys.all.contains(AudioLevels.voiceKey))
        #expect(AppDefaultsKeys.all.contains(AudioLevels.musicKey))
        #expect(AppDefaultsKeys.all.contains(AudioLevels.introsKey))
    }

    @Test func thePlayerPassesLevelsToTheEngine() async throws {
        let engine = FakePlaybackEngine()
        let player = SessionPlayer(engine: engine, notificationCenter: NotificationCenter())
        try await player.load(TestFixtures.firstWalkTimeline())
        player.setLevels(voice: 0.6, music: 0.3)
        #expect(engine.levels == [0.6, 0.3])
    }
}
