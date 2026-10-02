import Foundation

/// The texts of one language over the English content, by id (`content.<language>.json`, built by
/// tools/i18n/build_content_overlay.py). English is the source and needs no file; a new language is
/// one more file (plus its String Catalog column and voice recordings). Anything the file leaves out
/// stays English, so a half-translated language still works.
public struct ContentLocalization: Codable, Equatable, Sendable {
    public struct ExerciseText: Codable, Equatable, Sendable {
        public var name: String?
        public var purpose: String?
        public var tips: [String]?
        public var easier: String?
        public var harder: String?
        /// `BodyLimit` raw value → note.
        public var limitNotes: [String: String]?
        public init(name: String? = nil, purpose: String? = nil, tips: [String]? = nil, easier: String? = nil,
                    harder: String? = nil, limitNotes: [String: String]? = nil) {
            self.name = name; self.purpose = purpose; self.tips = tips; self.easier = easier; self.harder = harder
            self.limitNotes = limitNotes
        }
    }

    public struct StopText: Codable, Equatable, Sendable {
        public var name: String?
        public var back: String?
        public var coachLine: String?
        public init(name: String? = nil, back: String? = nil, coachLine: String? = nil) {
            self.name = name; self.back = back; self.coachLine = coachLine
        }
    }

    public struct JourneyText: Codable, Equatable, Sendable {
        public var title: String?
        public var subtitle: String?
        public var summary: String?
        public var stops: [String: StopText]?
        public init(title: String? = nil, subtitle: String? = nil, summary: String? = nil, stops: [String: StopText]? = nil) {
            self.title = title; self.subtitle = subtitle; self.summary = summary; self.stops = stops
        }
    }

    /// A coach line in this language. Without a recording (`file` nil) the English audio is never
    /// used: the line is spoken by the system voice in development and reported as missing for release.
    public struct VoiceText: Codable, Equatable, Sendable {
        public var text: String
        public var file: String?
        public var duration: Double?
        public var words: [VoiceLine.TimedWord]?
        public init(text: String, file: String? = nil, duration: Double? = nil, words: [VoiceLine.TimedWord]? = nil) {
            self.text = text; self.file = file; self.duration = duration; self.words = words
        }
    }

    public var schemaVersion: Int
    /// BCP 47 code: "vi".
    public var language: String
    public var exercises: [String: ExerciseText]
    public var journeys: [String: JourneyText]
    public var voiceLines: [String: VoiceText]
    public var notifications: [String: String]
    public var wins: [String: String]

    public init(schemaVersion: Int = 1, language: String, exercises: [String: ExerciseText] = [:],
                journeys: [String: JourneyText] = [:], voiceLines: [String: VoiceText] = [:],
                notifications: [String: String] = [:], wins: [String: String] = [:]) {
        self.schemaVersion = schemaVersion; self.language = language; self.exercises = exercises
        self.journeys = journeys; self.voiceLines = voiceLines; self.notifications = notifications; self.wins = wins
    }

    public static let currentSchemaVersion = 1

    /// Every coach line has its recording in this language.
    public var hasAllRecordings: Bool { !voiceLines.isEmpty && voiceLines.values.allSatisfy { $0.file != nil } }

    /// The same texts without the coach lines: screens in this language, the coach in English (with
    /// her voice) until the recordings exist.
    public var withoutCoachLines: ContentLocalization {
        var copy = self
        copy.voiceLines = [:]
        return copy
    }
}

extension ContentBundle {
    /// The same content with this language's texts in place of the English ones.
    public func localized(_ texts: ContentLocalization) -> ContentBundle {
        var copy = self
        copy.exercises = exercises.map { exercise in
            guard let t = texts.exercises[exercise.id] else { return exercise }
            var e = exercise
            e.name = t.name ?? e.name
            e.purpose = t.purpose ?? e.purpose
            if let tips = t.tips, tips.count == e.tips.count { e.tips = tips }
            e.easier = t.easier ?? e.easier
            if e.harder != nil { e.harder = t.harder ?? e.harder }
            if let notes = t.limitNotes {
                e.limitNotes = e.limitNotes?.map { note in
                    Exercise.LimitNote(limit: note.limit, text: notes[note.limit.rawValue] ?? note.text)
                }
            }
            return e
        }
        copy.journeys = journeys.map { journey in
            guard let t = texts.journeys[journey.id] else { return journey }
            var j = journey
            j.title = t.title ?? j.title
            j.subtitle = t.subtitle ?? j.subtitle
            j.summary = t.summary ?? j.summary
            j.stops = j.stops.map { stop in
                guard let s = t.stops?[stop.id] else { return stop }
                var copy = stop
                copy.name = s.name ?? copy.name
                copy.back = s.back ?? copy.back
                copy.coachLine = s.coachLine ?? copy.coachLine
                return copy
            }
            return j
        }
        copy.voiceLines = voiceLines.map { line in
            guard let t = texts.voiceLines[line.id] else { return line }
            var l = line
            l.text = t.text
            l.file = t.file
            l.duration = t.duration
            l.words = t.words
            return l
        }
        return copy
    }
}
