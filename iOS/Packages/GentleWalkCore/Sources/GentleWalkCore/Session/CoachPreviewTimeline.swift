import Foundation

/// "Hear your coach · 10 seconds" on Your plan (plan 08/10/2026 task 2.11, D3): the two lines the First
/// Walk opens with, back to back with a short breath between, voice only (no bells, no music). The
/// app plays it like a session (`SessionAudioComposer`, one `AVPlayer`), so she hears the real coach
/// in her language before she decides anything.
public extension SessionTimeline {
    static let coachPreviewLineIDs = ["a1.01", "a1.02"]
    /// Pause between the two lines.
    static let coachPreviewGap = 0.3

    static func coachPreview(voice lines: [VoiceLine]) -> SessionTimeline {
        let book = Dictionary(lines.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        var timeline = SessionTimeline()
        var at = 0.0
        for id in coachPreviewLineIDs {
            let line = cue(for: id, at: at, book: book)
            timeline.voice.append(line)
            at = line.end + coachPreviewGap
        }
        timeline.total = timeline.voice.last?.end ?? 0
        return timeline
    }
}
