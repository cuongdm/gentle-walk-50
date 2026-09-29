import AVFoundation
import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

@MainActor @Suite(.serialized) struct VoiceSourceTests {
    let cache = FileManager.default.temporaryDirectory.appendingPathComponent("voice-source-tests", isDirectory: true)

    func source(synthesis: Bool) -> VoiceSource {
        try? FileManager.default.removeItem(at: cache)
        return VoiceSource(bundle: .main, lines: TestFixtures.content.voiceLines, allowsSynthesis: synthesis, cacheDirectory: cache)
    }

    @Test func recordedLineComesFromTheBundle() async throws {
        let recorded = try #require(TestFixtures.content.voiceLines.first { $0.file != nil })
        let resolution = await source(synthesis: false).resolve(recorded.id)
        guard case .bundled(let url) = resolution else { Issue.record("expected bundled, got \(resolution)"); return }
        #expect(url.lastPathComponent == recorded.file)
    }

    @Test func missingLineIsSpokenIntoTheCacheInDebug() async throws {
        let missing = try #require(TestFixtures.content.voiceLines.first { $0.file == nil })
        let resolution = await source(synthesis: true).resolve(missing.id)
        guard case .synthesized(let url) = resolution else { Issue.record("expected synthesized, got \(resolution)"); return }
        let size = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int ?? 0
        #expect(size > 0)
        #expect(url.path.hasPrefix(cache.path))
    }

    @Test func releaseNeverSynthesizes() async throws {
        let missing = try #require(TestFixtures.content.voiceLines.first { $0.file == nil })
        #expect(await source(synthesis: false).resolve(missing.id) == .missing)
    }

    @Test func unknownLineIsMissing() async {
        #expect(await source(synthesis: true).resolve("no.such.line") == .missing)
    }
}
