import Foundation

/// Everything the app ships as JSON: exercises, journeys, voice lines and session templates.
/// Loaded once at launch (`ContentStore`, task 1.5) and checked by `ContentValidator` (task 1.4).
public struct ContentBundle: Codable, Equatable, Sendable {
    public var schemaVersion: Int
    public var exercises: [Exercise]
    public var journeys: [Journey]
    public var voiceLines: [VoiceLine]
    public var sessions: [SessionTemplate]

    public init(
        schemaVersion: Int = CoreInfo.contentSchemaVersion,
        exercises: [Exercise] = [],
        journeys: [Journey] = [],
        voiceLines: [VoiceLine] = [],
        sessions: [SessionTemplate] = []
    ) {
        self.schemaVersion = schemaVersion
        self.exercises = exercises
        self.journeys = journeys
        self.voiceLines = voiceLines
        self.sessions = sessions
    }

    public static func decode(from data: Data) throws -> ContentBundle {
        try JSONDecoder().decode(ContentBundle.self, from: data)
    }
}
