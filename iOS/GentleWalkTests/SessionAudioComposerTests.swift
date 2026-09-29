import AVFoundation
import Testing
import GentleWalkCore
@testable import GentleWalk

@Suite struct SessionAudioComposerTests {
    let timeline = TestFixtures.shortTimeline()
    var voices: [String: URL] { Dictionary(uniqueKeysWithValues: ["v1", "v2", "v3"].map { ($0, TestFixtures.url("voice-1s", "m4a")) }) }

    @Test func compositionMatchesTimeline() async throws {
        #expect(timeline.total == 30)
        #expect(timeline.bells.count == 3)  // two phase bells + done bell
        let (composition, mix) = try await SessionAudioComposer.compose(
            timeline: timeline, voiceURL: voices, bellURL: TestFixtures.url("bell-1s", "m4a"),
            musicURL: TestFixtures.url("music-10s", "m4a"))
        #expect(composition.tracks(withMediaType: .audio).count == 3)
        #expect(abs(composition.duration.seconds - 30) < 0.05)

        let music = try #require(mix.inputParameters.first)
        for cue in timeline.voice {
            var start: Float = -1, end: Float = -1
            var range = CMTimeRange.zero
            _ = music.getVolumeRamp(for: CMTime(seconds: cue.start + cue.duration / 2, preferredTimescale: 600),
                                    startVolume: &start, endVolume: &end, timeRange: &range)
            #expect(start == SessionAudioComposer.duckedVolume, "music not lowered under \(cue.lineID)")
        }
        var start: Float = -1, end: Float = -1
        var range = CMTimeRange.zero
        _ = music.getVolumeRamp(for: CMTime(seconds: 15, preferredTimescale: 600), startVolume: &start, endVolume: &end, timeRange: &range)
        #expect(start == 1)
    }

    @Test func musicOffMeansTwoTracks() async throws {
        let (composition, mix) = try await SessionAudioComposer.compose(
            timeline: timeline, voiceURL: voices, bellURL: TestFixtures.url("bell-1s", "m4a"), musicURL: nil)
        #expect(composition.tracks(withMediaType: .audio).count == 2)
        #expect(mix.inputParameters.isEmpty)
        // No music: the program ends with the last line (no silence added to stay awake, 2.5.4).
        let lastSound = timeline.voice.map(\.end).max()!
        #expect(abs(composition.duration.seconds - lastSound) < 0.05)
    }

    /// The shipped assets together: recorded voice lines, the placeholder bells and the walk music.
    @Test func bundledAssetsBuildAFullFirstWalk() async throws {
        let content = TestFixtures.content
        let timeline = TestFixtures.firstWalkTimeline()
        var voices: [String: URL] = [:]
        for line in content.voiceLines {
            if let file = line.file, let url = Bundle.main.url(forResource: (file as NSString).deletingPathExtension, withExtension: "m4a") {
                voices[line.id] = url
            }
        }
        let music = try #require(try MusicLibrary.load(bundle: .main).url(for: .walk))
        let bell = try #require(SessionMedia.phaseBellURL)
        let (composition, mix) = try await SessionAudioComposer.compose(
            timeline: timeline, voiceURL: voices, bellURL: bell, doneBellURL: SessionMedia.doneBellURL, musicURL: music)
        #expect(composition.tracks(withMediaType: .audio).count == 3)
        #expect(abs(composition.duration.seconds - timeline.total) < 0.05)
        #expect(!mix.inputParameters.isEmpty)
    }

    /// Review I8: "Voice louder than music" off dips the music less while the coach speaks.
    @Test func musicDipFollowsTheSetting() async throws {
        let (_, mix) = try await SessionAudioComposer.compose(
            timeline: timeline, voiceURL: voices, bellURL: TestFixtures.url("bell-1s", "m4a"),
            musicURL: TestFixtures.url("music-10s", "m4a"), duckedVolume: 0.6)
        let parameters = try #require(mix.inputParameters.first)
        let cue = try #require(timeline.voice.first { voices[$0.lineID] != nil })
        var start: Float = 0, end: Float = 0
        var range = CMTimeRange()
        let found = parameters.getVolumeRamp(for: SessionAudioComposer.time(cue.start + 0.01), startVolume: &start,
                                             endVolume: &end, timeRange: &range)
        #expect(found)
        #expect(start == 0.6)
    }

    @Test func musicFillsTheRequestedLengthForAnOpenEndedWalk() async throws {
        let (composition, _) = try await SessionAudioComposer.compose(
            timeline: timeline, voiceURL: voices, bellURL: TestFixtures.url("bell-1s", "m4a"),
            musicURL: TestFixtures.url("music-10s", "m4a"), length: 90)
        #expect(abs(composition.duration.seconds - 90) < 0.05)
    }
}
