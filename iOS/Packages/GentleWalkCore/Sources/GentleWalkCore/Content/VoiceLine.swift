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

    public init(id: String, text: String, file: String? = nil, duration: Double? = nil, words: [TimedWord]? = nil) {
        self.id = id; self.text = text; self.file = file; self.duration = duration; self.words = words
    }
}
