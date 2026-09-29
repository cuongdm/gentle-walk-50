/// Captions for the player (spec: captions always equal the spoken words, shown while spoken).
public struct CaptionTimeline: Sendable {
    public struct Caption: Equatable, Sendable {
        public var lineID: String
        public var text: String
        /// Index of the word being spoken, when the line has recorded word timings.
        public var wordIndex: Int?
    }

    private let cues: [SessionTimeline.VoiceCue]

    public init(timeline: SessionTimeline) {
        cues = timeline.voice
    }

    public func caption(at time: Double) -> Caption? {
        guard let cue = cues.last(where: { $0.start <= time }), time < cue.end else { return nil }
        let local = time - cue.start
        let word = cue.words?.lastIndex { $0.start <= local }
        return Caption(lineID: cue.lineID, text: cue.text, wordIndex: word)
    }
}
