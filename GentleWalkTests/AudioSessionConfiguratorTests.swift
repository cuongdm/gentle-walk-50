import AVFoundation
import Testing
@testable import GentleWalk

@Suite struct AudioSessionConfiguratorTests {
    @Test func guidedSessionOwnsTheAudio() {
        let settings = AudioSessionConfigurator.settings(for: .guided)
        #expect(settings.category == .playback)
        #expect(settings.mode == .spokenAudio)
        #expect(!settings.options.contains(.mixWithOthers))
    }

    @Test func overUserAudioMixesAndDucks() {
        // Outdoors with "My audio": the coach talks over the user's podcast or music (audible content, never silence).
        let settings = AudioSessionConfigurator.settings(for: .overUserAudio)
        #expect(settings.category == .playback)
        #expect(settings.options == [.mixWithOthers, .duckOthers])
    }
}
