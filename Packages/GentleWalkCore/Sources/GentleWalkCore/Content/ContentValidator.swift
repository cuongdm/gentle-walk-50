/// Where the content is being checked. Development tolerates missing media (placeholders and the
/// DEBUG speech fallback cover them); release must be complete before submission (task 9.2).
public enum ValidationMode: Sendable { case development, release }

public struct ContentIssue: Equatable, Sendable {
    public enum Code: Sendable {
        case duplicateID, stopsNotIncreasing, wrongStopCount, missingExercise, missingVoiceLine, missingVoiceFile, noFreeJourney
    }
    public enum Severity: Sendable { case warning, error }

    public var code: Code
    public var severity: Severity
    /// Human-readable pointer to the offending item, e.g. "jr.ny" or "ses.walk → mv.nope".
    public var detail: String
}

/// Checks the bundled JSON before the app uses it. Pure function: no I/O.
public enum ContentValidator {
    /// Every journey has exactly six postcards (spec S18).
    public static let stopsPerJourney = 6

    public static func validate(_ bundle: ContentBundle, mode: ValidationMode) -> [ContentIssue] {
        var issues: [ContentIssue] = []
        func error(_ code: ContentIssue.Code, _ detail: String) {
            issues.append(ContentIssue(code: code, severity: .error, detail: detail))
        }

        // Ids must be unique across every kind of content so cues and saved records never collide.
        var seen = Set<String>()
        let allIDs = bundle.exercises.map(\.id) + bundle.journeys.map(\.id)
            + bundle.journeys.flatMap { $0.stops.map(\.id) } + bundle.voiceLines.map(\.id) + bundle.sessions.map(\.id)
        for id in allIDs where !seen.insert(id).inserted {
            error(.duplicateID, id)
        }

        for journey in bundle.journeys {
            if journey.stops.count != stopsPerJourney {
                error(.wrongStopCount, "\(journey.id): \(journey.stops.count) stops")
            }
            for (previous, next) in zip(journey.stops, journey.stops.dropFirst()) where next.mile <= previous.mile {
                error(.stopsNotIncreasing, "\(journey.id): \(previous.id) → \(next.id)")
            }
        }
        if !bundle.journeys.contains(where: \.isFree) {
            error(.noFreeJourney, "no journey has isFree = true")
        }

        let exerciseIDs = Set(bundle.exercises.map(\.id))
        let lineIDs = Set(bundle.voiceLines.map(\.id))
        for session in bundle.sessions {
            for segment in session.segments {
                if let exerciseID = segment.exerciseID, !exerciseIDs.contains(exerciseID) {
                    error(.missingExercise, "\(session.id) → \(exerciseID)")
                }
                for cue in segment.cues where !lineIDs.contains(cue.line) {
                    error(.missingVoiceLine, "\(session.id) → \(cue.line)")
                }
            }
        }

        for line in bundle.voiceLines where line.file == nil {
            issues.append(ContentIssue(
                code: .missingVoiceFile,
                severity: mode == .release ? .error : .warning,
                detail: line.id
            ))
        }
        return issues
    }
}
