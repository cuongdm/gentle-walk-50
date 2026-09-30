extension SessionPlan {
    /// A plan made of one template as-is (First Walk, tests).
    public init(template: SessionTemplate) {
        let kind: Block.Kind = switch template.kind {
        case .firstWalk, .walk: .walk
        case .chair: .chair
        case .stretch: .stretch
        case .cooldown: .cooldown
        }
        self.init(blocks: [Block(kind: kind, segments: template.segments)])
    }
}

/// A session laid out in seconds (task 2.11): voice cues with their spoken length, bells, and the
/// phases the player shows. Built once when the session starts; edits go through `TimelineEditing`.
public struct SessionTimeline: Equatable, Sendable {
    public struct VoiceCue: Equatable, Sendable {
        public var lineID: String
        /// Exact caption text: always the spoken words.
        public var text: String
        public var start: Double
        public var duration: Double
        /// Recorded word timings (seconds from the start of the line), when the line has audio.
        public var words: [VoiceLine.TimedWord]?
        public var end: Double { start + duration }
    }

    public enum BellKind: Equatable, Sendable { case phase, done }

    public struct Bell: Equatable, Sendable {
        public var at: Double
        public var kind: BellKind
    }

    public struct Phase: Equatable, Sendable {
        public var kind: SessionTemplate.Segment.Kind
        /// Which part of the day this phase belongs to: picks the player screen (walk, chair, stretch).
        public var block: SessionPlan.Block.Kind
        public var exerciseID: String?
        public var start: Double
        public var end: Double
        /// The rest of this exercise uses the easier version (This hurts → Show an easier version).
        public var isEasier: Bool
    }

    public var voice: [VoiceCue] = []
    public var bells: [Bell] = []
    public var phases: [Phase] = []
    public var total: Double = 0
    /// True after "Walk home gently": the easy walk lasts until the user taps End.
    public var isOpenEnded = false
    /// Lines that edits insert (A7 safety lines, A3 walk home), resolved when the timeline is built.
    var editLines: [String: VoiceCue] = [:]

    /// An empty timeline (nothing loaded yet).
    public init() {}

    /// A bell plays this long before the line it introduces (A1: "chuông trước câu 1 giây").
    public static let bellLead = 1.0
    /// Speaking rate used when a line has no recording yet (DEBUG speech fallback).
    public static let estimatedWordsPerSecond = 2.5
    /// Segments that change walking pace get a phase bell.
    static let pacedKinds: Set<SessionTemplate.Segment.Kind> = [.warmup, .brisk, .easy, .cooldown]
    /// Lines an edit can insert; audio for them is prepared with the session.
    public static let editLineIDs = ["a7.hurt.easier", "a7.hurt.skip", "a3.home.1"]

    public static func make(plan: SessionPlan, voice lines: [VoiceLine]) -> SessionTimeline {
        let book = Dictionary(lines.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let segments = plan.segments
        let blockOf = plan.blocks.flatMap { block in block.segments.map { _ in block.kind } }
        let lastCue = segments.indices.last { !segments[$0].cues.isEmpty }.map { ($0, segments[$0].cues.count - 1) }

        var timeline = SessionTimeline()
        var planned: [(at: Double, line: String)] = []
        var t = 0.0
        for (i, segment) in segments.enumerated() {
            let end = t + Double(segment.seconds)
            timeline.phases.append(Phase(kind: segment.kind, block: blockOf[i], exerciseID: segment.exerciseID,
                                         start: t, end: end, isEasier: false))
            let bellHere = i > 0 && pacedKinds.contains(segment.kind)
            if bellHere { timeline.bells.append(Bell(at: t, kind: .phase)) }
            for (j, cue) in segment.cues.enumerated() {
                var at = t + Double(cue.at)
                if bellHere && cue.at == 0 { at += bellLead }
                if let lastCue, lastCue == (i, j) {
                    timeline.bells.append(Bell(at: at, kind: .done))
                    at += bellLead
                }
                planned.append((at, cue.line))
            }
            t = end
        }
        timeline.total = t
        timeline.voice = planned.map { cue(for: $0.line, at: $0.at, book: book) }
        timeline.normalizeVoice(from: 0)
        timeline.editLines = Dictionary(uniqueKeysWithValues: editLineIDs.map { ($0, cue(for: $0, at: 0, book: book)) })
        return timeline
    }

    static func cue(for id: String, at start: Double, book: [String: VoiceLine]) -> VoiceCue {
        let line = book[id]
        let text = line?.text ?? ""
        let words = Double(text.split(separator: " ").count)
        let duration = line?.duration ?? max(1, words / estimatedWordsPerSecond + 0.4)
        return VoiceCue(lineID: id, text: text, start: start, duration: duration, words: line?.words)
    }

    /// Sorts cues and pushes any cue (from `index` on) that would start while the previous one is
    /// still speaking: lines never talk over each other.
    mutating func normalizeVoice(from index: Int) {
        voice.sort { $0.start < $1.start }
        guard voice.count > 1 else { return }
        for k in max(1, index)..<voice.count where voice[k].start < voice[k - 1].end {
            voice[k].start = voice[k - 1].end
        }
    }
}

public extension SessionTimeline {
    /// Where she is among the moves of the current chair or stretch block, for the segmented bar.
    struct MoveProgress: Equatable, Sendable {
        public var count: Int
        /// The move in progress, or the next one during a rest.
        public var index: Int
        /// 0...1 through the move at `index`.
        public var fraction: Double
    }

    func moveProgress(at time: Double) -> MoveProgress? {
        guard let current = phases.last(where: { $0.start <= time }) ?? phases.first else { return nil }
        let moves = phases.filter { $0.block == current.block && $0.exerciseID != nil }
        guard !moves.isEmpty else { return nil }
        // The move under way, or the first one still ahead (rest, intro).
        if let index = moves.firstIndex(where: { $0.start <= time && time < $0.end }) {
            let move = moves[index]
            let length = max(move.end - move.start, 0.001)
            return MoveProgress(count: moves.count, index: index, fraction: min(1, max(0, (time - move.start) / length)))
        }
        let index = moves.firstIndex { $0.start > time } ?? moves.count
        return MoveProgress(count: moves.count, index: index, fraction: 0)
    }
}
