/// One recorded coach line. `file`, `duration` and `words` are filled by tools/voice/build_manifest.py (task 1.6).
public struct VoiceLine: Codable, Equatable, Identifiable, Sendable {
    public struct TimedWord: Codable, Equatable, Sendable {
        public var word: String
        public var start: Double
        public var end: Double

        public init(word: String, start: Double, end: Double) {
            self.word = word; self.start = start; self.end = end
        }
    }

    public var id: String
    /// Exact caption text (captions always equal the spoken words).
    public var text: String
    public var file: String?
    public var duration: Double?
    public var words: [TimedWord]?
    /// Walking levels the line is written for ("chỉ In place / Pad" in A2); nil = every level.
    public var levels: [WalkLevel]?
    /// Body limits for which the line is never spoken ("không Joint replacement").
    public var hiddenFor: [BodyLimit]?

    public init(id: String, text: String, file: String? = nil, duration: Double? = nil, words: [TimedWord]? = nil,
                levels: [WalkLevel]? = nil, hiddenFor: [BodyLimit]? = nil) {
        self.id = id; self.text = text; self.file = file; self.duration = duration; self.words = words
        self.levels = levels; self.hiddenFor = hiddenFor
    }

    /// Whether the line fits a session at this level for someone with these limits.
    public func fits(level: WalkLevel?, limits: Set<BodyLimit>) -> Bool {
        if let levels, let level, !levels.contains(level) { return false }
        return limits.isDisjoint(with: hiddenFor ?? [])
    }
}
