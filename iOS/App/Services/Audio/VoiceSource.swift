import AVFoundation
import Foundation
import GentleWalkCore

enum VoiceResolution: Equatable, Sendable {
    /// Recorded line shipped in the app.
    case bundled(URL)
    /// DEBUG only: spoken by the system voice into Caches so development runs without recordings.
    case synthesized(URL)
    /// No recording (Release never synthesizes; the release content check reports these).
    case missing
}

/// Finds the audio file for a voice line (task 3.3).
@MainActor final class VoiceSource {
    private let bundle: Bundle
    private let lines: [String: VoiceLine]
    private let allowsSynthesis: Bool
    private let cacheDirectory: URL
    private let language: AppLanguage

    #if DEBUG
    static let synthesisDefault = true
    #else
    static let synthesisDefault = false
    #endif

    init(bundle: Bundle = .main, lines: [VoiceLine], allowsSynthesis: Bool = VoiceSource.synthesisDefault,
         cacheDirectory: URL = VoiceSource.defaultCache, language: AppLanguage = .current) {
        self.bundle = bundle
        self.language = language
        self.lines = Dictionary(lines.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        self.allowsSynthesis = allowsSynthesis
        self.cacheDirectory = cacheDirectory
    }

    static var defaultCache: URL {
        URL.cachesDirectory.appendingPathComponent("SpokenLines", isDirectory: true)
    }

    func resolve(_ id: String) async -> VoiceResolution {
        guard let line = lines[id] else { return .missing }
        if let file = line.file {
            let name = (file as NSString).deletingPathExtension
            let ext = (file as NSString).pathExtension
            if let url = bundle.url(forResource: name, withExtension: ext) { return .bundled(url) }
        }
        guard allowsSynthesis, !line.text.isEmpty else { return .missing }
        // One cache per language: the same id is another sentence in another language.
        let url = cacheDirectory.appendingPathComponent("\(id).\(language.rawValue).caf")
        if FileManager.default.fileExists(atPath: url.path) { return .synthesized(url) }
        do {
            try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
            try await SpeechFileWriter().write(line.text, language: language.speechCode, to: url)
            return .synthesized(url)
        } catch {
            return .missing
        }
    }
}

/// Writes a sentence spoken by the system voice to a file (DEBUG fallback only).
final class SpeechFileWriter: @unchecked Sendable {
    enum WriteError: Error { case noAudio }

    private let synthesizer = AVSpeechSynthesizer()
    private var file: AVAudioFile?

    func write(_ text: String, language: String = "en-US", to url: URL) async throws {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            var finished = false
            synthesizer.write(utterance) { [self] buffer in
                guard !finished else { return }
                guard let pcm = buffer as? AVAudioPCMBuffer, pcm.frameLength > 0 else {
                    finished = true
                    let wrote = file != nil
                    file = nil
                    wrote ? continuation.resume() : continuation.resume(throwing: WriteError.noAudio)
                    return
                }
                do {
                    if file == nil {
                        file = try AVAudioFile(forWriting: url, settings: pcm.format.settings,
                                               commonFormat: pcm.format.commonFormat, interleaved: pcm.format.isInterleaved)
                    }
                    try file?.write(from: pcm)
                } catch {
                    finished = true
                    file = nil
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
