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

    /// − / + in five steps instead of sliders (plan 08/10/2026 task 1.10; spec: no sliders for shaky hands).
    @Test func stepsMapToLevels() {
        #expect(AudioLevels.steps == 5)
        // The coach's first step is the floor, so she can always be heard; the last is full volume.
        #expect(AudioLevels.voice(atStep: 1) == AudioLevels.voiceFloor)
        #expect(AudioLevels.voice(atStep: 5) == 1)
        #expect(AudioLevels.music(atStep: 5) == 1)
        #expect(AudioLevels.music(atStep: 1) > 0)
        for step in 1...5 {
            #expect(AudioLevels.voiceStep(for: AudioLevels.voice(atStep: step)) == step)
            #expect(AudioLevels.musicStep(for: AudioLevels.music(atStep: step)) == step)
        }
        // Old in-between values land on the nearest step; out of range is clamped.
        #expect(AudioLevels.voiceStep(for: 0.98) == 5)
        #expect(AudioLevels.voiceStep(for: 0.1) == 1)
        #expect(AudioLevels.musicStep(for: AudioLevels.defaultMusic) == 4)
        #expect(AudioLevels.voice(atStep: 9) == 1)
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
