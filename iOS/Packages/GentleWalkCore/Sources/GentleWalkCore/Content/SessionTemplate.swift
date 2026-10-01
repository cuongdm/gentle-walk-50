/// A scripted session or part of one (First Walk, walk by level and intensity, chair frames and move
/// library, stretch day, cool-down, extras). `SessionBuilder` (task 2.8) assembles plans from
/// templates; `SessionTimeline` (2.11) turns them into cues.
public struct SessionTemplate: Codable, Equatable, Identifiable, Sendable {
    public enum Kind: String, Codable, Sendable { case firstWalk, walk, chair, stretch, cooldown, balance }

    public struct Segment: Codable, Equatable, Sendable {
        public enum Kind: String, Codable, Sendable { case intro, warmup, brisk, easy, cooldown, move, stretch, rest, outro }

        public var kind: Kind
        public var seconds: Int
        public var exerciseID: String?
        public var cues: [Cue]
        /// Stretch: seconds of each hold (per side), ending at the "switch" and "release" lines;
        /// 0 = a slow repeated move with no hold.
        public var hold: Int?
        /// Counted reps (all sides together), when the coach counts them.
        public var reps: Int?
        /// Played only for someone with one of these limits (e.g. the seated ankle stretch that
        /// replaces the calf stretch when standing is hard).
        public var onlyFor: [BodyLimit]?
        /// Left out for someone with one of these limits.
        public var notFor: [BodyLimit]?

        public init(kind: Kind, seconds: Int, exerciseID: String? = nil, cues: [Cue] = [], hold: Int? = nil,
                    reps: Int? = nil, onlyFor: [BodyLimit]? = nil, notFor: [BodyLimit]? = nil) {
            self.kind = kind; self.seconds = seconds; self.exerciseID = exerciseID; self.cues = cues
            self.hold = hold; self.reps = reps; self.onlyFor = onlyFor; self.notFor = notFor
        }

        public func applies(to limits: Set<BodyLimit>) -> Bool {
            Condition.applies(onlyFor: onlyFor, notFor: notFor, limits: limits)
        }
    }

    /// A voice line placed `at` seconds after the segment starts.
    public struct Cue: Codable, Equatable, Sendable {
        public var at: Int
        public var line: String
        /// Spoken only for someone with one of these limits (a safer variant of a line).
        public var onlyFor: [BodyLimit]?
        /// Not spoken for someone with one of these limits (e.g. "Want more?" for a joint replacement).
        public var notFor: [BodyLimit]?

        public init(at: Int, line: String, onlyFor: [BodyLimit]? = nil, notFor: [BodyLimit]? = nil) {
            self.at = at; self.line = line; self.onlyFor = onlyFor; self.notFor = notFor
        }

        public func applies(to limits: Set<BodyLimit>) -> Bool {
            Condition.applies(onlyFor: onlyFor, notFor: notFor, limits: limits)
        }
    }

    public var id: String
    public var kind: Kind
    public var segments: [Segment]
    /// Walks: the level the lines are written for (Seated never hears "brisk").
    public var level: WalkLevel?

    public init(id: String, kind: Kind, segments: [Segment], level: WalkLevel? = nil) {
        self.id = id; self.kind = kind; self.segments = segments; self.level = level
    }

    public var seconds: Int { segments.reduce(0) { $0 + $1.seconds } }
}

/// Body-limit conditions on cues and segments.
enum Condition {
    static func applies(onlyFor: [BodyLimit]?, notFor: [BodyLimit]?, limits: Set<BodyLimit>) -> Bool {
        if let onlyFor, limits.isDisjoint(with: onlyFor) { return false }
        if let notFor, !limits.isDisjoint(with: notFor) { return false }
        return true
    }
}
