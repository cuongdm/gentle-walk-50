import AVFoundation
import Foundation
import GentleWalkCore

/// Everything a session needs before it can play: the timeline measured against real audio
/// lengths, and the audio file for every line it may speak.
struct SessionMedia {
    var timeline: SessionTimeline
    var voiceURLs: [String: URL]
    /// Lines with no audio (Release: the release content check makes this empty).
    var missingLines: [String]

    static var phaseBellURL: URL? { Bundle.main.url(forResource: "bell-phase", withExtension: "m4a") }
    static var doneBellURL: URL? { Bundle.main.url(forResource: "bell-done", withExtension: "m4a") }

    @MainActor
    static func prepare(plan: SessionPlan, content: ContentBundle, voiceSource: VoiceSource) async -> SessionMedia {
        let ids = Array(Set(plan.lineIDs + SessionTimeline.editLineIDs)).sorted()
        var lines = Dictionary(content.voiceLines.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        var urls: [String: URL] = [:]
        var missing: [String] = []
        for id in ids {
            switch await voiceSource.resolve(id) {
            case .bundled(let url):
                urls[id] = url
            case .synthesized(let url):
                urls[id] = url
                // Spoken lines have no measured length in the content; measure the file.
                if let seconds = try? await AVURLAsset(url: url).load(.duration).seconds, seconds > 0 {
                    lines[id]?.duration = seconds
                    lines[id]?.words = nil
                }
            case .missing:
                missing.append(id)
            }
        }
        let timeline = SessionTimeline.make(plan: plan, voice: Array(lines.values))
        return SessionMedia(timeline: timeline, voiceURLs: urls, missingLines: missing)
    }

    @MainActor func makeEngine(musicURL: URL?, duckedVolume: Float = SessionAudioComposer.duckedVolume) -> AVPlaybackEngine? {
        guard let bell = Self.phaseBellURL else { return nil }
        return AVPlaybackEngine(voiceURLs: voiceURLs, bellURL: bell, doneBellURL: Self.doneBellURL, musicURL: musicURL,
                                duckedVolume: duckedVolume)
    }
}
