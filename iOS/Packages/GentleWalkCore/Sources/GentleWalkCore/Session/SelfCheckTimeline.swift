import Foundation

/// The 2-week self-check's audio (steady program task 4.7, script docs/scripts/A12-steady-program.md):
/// a setup line, "Three. Two. One.", a bell and "Go" at `goAt`, a bell and "Halfway there." at the
/// middle, and the done bell with "And stop." when the 30 seconds end. Played as one program like a
/// session; without recordings the bells still ring and the screen shows the words.
public extension SessionTimeline {
    /// Seconds from the start of the audio to "Go".
    static let selfCheckGoAt = 8.0
    /// The timed part: 30 seconds of sit-to-stands.
    static let selfCheckSeconds = 30.0

    /// Every line the self-check speaks (the release check wants a recording for each).
    static let selfCheckLineIDs = ["a12.check.setup", "a5.n.3", "a5.n.2", "a5.n.1", "a12.check.go", "a5.half",
                                   "a12.check.stop"]

    /// Silence between the history line and the setup line.
    static let selfCheckLeadGap = 0.6

    /// - Parameter previousCount: her last check done the same way: from the second check the coach first
    ///   says "Last check, you stood up eight times. Let's see today." (P7). The rest keeps its timing after
    ///   `leadIn`, so the screen's clock starts there.
    static func selfCheck(voice lines: [VoiceLine], previousCount: Int?) -> SessionTimeline {
        var timeline = selfCheck(voice: lines)
        let book = Dictionary(lines.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        guard let count = previousCount, let id = CoachHistory.checkLine(previousCount: count), book[id] != nil else {
            return timeline
        }
        let history = cue(for: id, at: 0, book: book)
        let lead = ((history.duration + selfCheckLeadGap) * 10).rounded(.up) / 10
        timeline.voice = [history] + timeline.voice.map { var moved = $0; moved.start += lead; return moved }
        timeline.bells = timeline.bells.map { var moved = $0; moved.at += lead; return moved }
        timeline.total += lead
        timeline.leadIn = lead
        return timeline
    }

    static func selfCheck(voice lines: [VoiceLine]) -> SessionTimeline {
        let book = Dictionary(lines.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let go = selfCheckGoAt
        let half = go + selfCheckSeconds / 2
        let stop = go + selfCheckSeconds
        var timeline = SessionTimeline()
        // The count and the bells keep their place: nothing is pushed back, the setup line is short.
        timeline.voice = [("a12.check.setup", 0), ("a5.n.3", go - 3), ("a5.n.2", go - 2), ("a5.n.1", go - 1),
                          ("a12.check.go", go), ("a5.half", half), ("a12.check.stop", stop)]
            .map { cue(for: $0.0, at: $0.1, book: book) }
        timeline.bells = [Bell(at: go, kind: .phase), Bell(at: half, kind: .phase), Bell(at: stop, kind: .done)]
        timeline.total = stop + 2
        return timeline
    }
}
