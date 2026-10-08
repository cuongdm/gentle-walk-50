import AVFoundation
import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

/// "Hear your coach · 10 seconds" (plan 08/10/2026 task 2.11): real bundled lines, voice only, and the
/// audio session is given back when it stops.
@MainActor @Suite(.serialized) struct CoachPreviewPlayerTests {
    final class SpySession: PreviewAudioSession {
        var activations = 0
        var deactivations = 0
        func activate() throws { activations += 1 }
        func deactivate() { deactivations += 1 }
    }

    func player(_ content: ContentBundle = TestFixtures.content, language: AppLanguage = .english,
                session: PreviewAudioSession = SpySession()) -> CoachPreviewPlayer {
        CoachPreviewPlayer(voiceSource: VoiceSource(lines: content.voiceLines, allowsSynthesis: false, language: language),
                           lines: content.voiceLines, audioSession: session)
    }

    @Test func compositionIsTwoBundledLinesUnderTwelveSeconds() async throws {
        let composition = try await player().composition()
        // One voice track: no bell track, no music track.
        #expect(composition.tracks(withMediaType: .audio).count == 1)
        #expect(composition.duration.seconds >= 10 && composition.duration.seconds <= 12)
    }

    @Test func stopDeactivatesTheAudioSession() async throws {
        let spy = SpySession()
        let preview = player(session: spy)
        preview.toggle()
        #expect(preview.state == .loading)
        for _ in 0..<50 where preview.state != .playing { try await Task.sleep(for: .milliseconds(100)) }
        #expect(preview.state == .playing)
        #expect(spy.activations == 1)
        preview.toggle()
        #expect(preview.state == .idle)
        #expect(spy.deactivations == 1)
        // Leaving the screen after it stopped changes nothing more.
        preview.stop()
        #expect(spy.deactivations == 1)
    }

    @Test func vietnameseResolvesViLines() async throws {
        let texts = try #require(AppLanguage.vietnamese.contentTexts())
        let vietnamese = TestFixtures.content.localized(texts)
        let source = VoiceSource(lines: vietnamese.voiceLines, allowsSynthesis: false, language: .vietnamese)
        for id in CoachPreviewPlayer.lineIDs {
            guard case .bundled(let url) = await source.resolve(id) else {
                Issue.record("\(id) has no Vietnamese recording")
                continue
            }
            #expect(url.lastPathComponent == "\(id).vi.m4a")
        }
        let composition = try await player(vietnamese, language: .vietnamese).composition()
        #expect(composition.tracks(withMediaType: .audio).count == 1)
        #expect(composition.duration.seconds > 5)
    }
}
