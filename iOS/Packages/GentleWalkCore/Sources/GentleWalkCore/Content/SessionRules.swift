import Foundation

/// The session rules of docs/research/2026-09-30-exercise-standards.md §7 ("Quy tắc kiểm sessions.json"),
/// checked on every template:
/// 1. no brisk part before 2:00 of warm-up (so 5-minute walks have none);
/// 2. Seated never hears "brisk" or "moderate", nor a line written for standing levels;
/// 3. counted chair moves do 6–12 reps a set (sit-to-stand 5–12), and the coach counts each one;
/// 4. no single stretch hold over 30 seconds;
/// 5. every balance exercise says where the hands go, and nobody is asked to close their eyes;
/// 6. walks of 5 minutes or more cool down for at least 1:00, of 8 minutes or more for 2:00.
enum SessionRules {
    struct Finding: Equatable { var code: ContentIssue.Code; var detail: String }

    static let warmUpBeforeBrisk = 120
    static let repRange = 6...12
    static let sitToStandRange = 5...12
    static let longestHold = 30
    static let bannedWords = ["brisk", "moderate"]
    static let closedEyes = ["close your eyes", "eyes closed", "closed eyes"]
    /// Lines that say where her hands go (A11 §2.2: both hands, one hand, fingertips; sit-to-stand pushes up).
    static let handLinePrefixes = ["a11.hands.", "a11.sts."]

    static func check(_ bundle: ContentBundle) -> [Finding] {
        let exercises = Dictionary(bundle.exercises.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let lines = Dictionary(bundle.voiceLines.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let table = VoiceRotation.Table(lines: bundle.voiceLines)
        var findings: [Finding] = []

        for line in bundle.voiceLines where closedEyes.contains(where: line.text.lowercased().contains) {
            findings.append(Finding(code: .balanceWithoutHands, detail: "\(line.id): eyes closed"))
        }

        for session in bundle.sessions {
            let segments = session.segments
            if session.kind == .walk {
                if let firstBrisk = segments.firstIndex(where: { $0.kind == .brisk }) {
                    let warm = segments[..<firstBrisk].filter { $0.kind == .warmup || $0.kind == .intro }.reduce(0) { $0 + $1.seconds }
                    if warm < warmUpBeforeBrisk {
                        findings.append(Finding(code: .briskBeforeWarmUp, detail: "\(session.id): \(warm) s of warm-up"))
                    }
                }
                let total = session.seconds
                let cooldown = segments.filter { $0.kind == .cooldown }.reduce(0) { $0 + $1.seconds }
                let needed = total >= 480 ? 120 : total >= 300 ? 60 : 0
                if cooldown < needed {
                    findings.append(Finding(code: .cooldownTooShort, detail: "\(session.id): \(cooldown) s"))
                }
            }
            if session.level == .seated {
                for cue in segments.flatMap(\.cues) {
                    for id in table.alternatives(of: cue.line, level: .seated) {
                        guard let line = lines[id] else { continue }
                        let text = line.text.lowercased()
                        if bannedWords.contains(where: text.contains) || !line.fits(level: .seated, limits: []) {
                            findings.append(Finding(code: .briskWhileSeated, detail: "\(session.id) → \(id)"))
                        }
                    }
                }
            }
            for segment in segments {
                let exercise = segment.exerciseID.flatMap { exercises[$0] }
                if let hold = segment.hold, hold > longestHold {
                    findings.append(Finding(code: .holdTooLong, detail: "\(session.id) → \(segment.exerciseID ?? "?"): \(hold) s"))
                }
                if segment.kind == .move, let exercise, exercise.counting == .reps {
                    let counted = segment.cues.filter { $0.line.hasPrefix("a5.n.") }.count
                    let range = exercise.id == "mv.sit-to-stand" ? sitToStandRange : repRange
                    if let reps = segment.reps, range.contains(reps), counted == reps * (segment.sets ?? 1) { continue }
                    findings.append(Finding(code: .repsOutOfRange,
                                            detail: "\(session.id) → \(exercise.id): \(segment.reps ?? 0) reps, \(counted) counted"))
                }
                if session.kind == .balance, segment.kind == .move, exercise != nil,
                   !segment.cues.contains(where: { handLinePrefixes.contains(where: $0.line.hasPrefix) }) {
                    findings.append(Finding(code: .balanceWithoutHands, detail: "\(session.id) → \(segment.exerciseID ?? "?")"))
                }
            }
        }
        return findings
    }
}
