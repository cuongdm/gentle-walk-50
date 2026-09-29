/// A scripted session (First Walk, walk by level and intensity, chair day, stretch day, cool-down).
/// `SessionBuilder` (task 2.8) assembles plans from templates; `SessionTimeline` (2.11) turns them into cues.
public struct SessionTemplate: Codable, Equatable, Identifiable, Sendable {
    public enum Kind: String, Codable, Sendable { case firstWalk, walk, chair, stretch, cooldown }

    public struct Segment: Codable, Equatable, Sendable {
        public enum Kind: String, Codable, Sendable { case intro, warmup, brisk, easy, cooldown, move, stretch, rest, outro }

        public var kind: Kind
        public var seconds: Int
        public var exerciseID: String?
        public var cues: [Cue]

        public init(kind: Kind, seconds: Int, exerciseID: String? = nil, cues: [Cue] = []) {
            self.kind = kind; self.seconds = seconds; self.exerciseID = exerciseID; self.cues = cues
        }
    }

    /// A voice line placed `at` seconds after the segment starts.
    public struct Cue: Codable, Equatable, Sendable {
        public var at: Int
        public var line: String

        public init(at: Int, line: String) {
            self.at = at; self.line = line
        }
    }

    public var id: String
    public var kind: Kind
    public var segments: [Segment]

    public init(id: String, kind: Kind, segments: [Segment]) {
        self.id = id; self.kind = kind; self.segments = segments
    }
}
