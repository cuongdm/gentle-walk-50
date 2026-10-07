/// A built session: ordered blocks (walk, chair moves, stretch, cool-down), each a list of template
/// segments with voice cues. `SessionTimeline` (2.11) turns it into timed cues and captions.
public struct SessionPlan: Equatable, Sendable {
    public typealias Segment = SessionTemplate.Segment

    public struct Block: Equatable, Sendable {
        /// `steady`: the two-minute balance set that closes a planned day; played by the chair player.
        public enum Kind: Equatable, Sendable { case walk, chair, stretch, cooldown, steady }
        public var kind: Kind
        public var segments: [Segment]
        public var seconds: Int { segments.reduce(0) { $0 + $1.seconds } }
    }

    public var blocks: [Block] = []
    /// Stretch hold per side on a stretch day; nil otherwise.
    public var holdSeconds: Int?
    /// Exercises that start with the easier version because of a body limit.
    public var easierExerciseIDs: Set<String> = []

    /// Shortest session after automatic shortening (spec: never under 5 minutes).
    public static let minimumSeconds = 300

    public var segments: [Segment] { blocks.flatMap(\.segments) }
    public var totalSeconds: Int { blocks.reduce(0) { $0 + $1.seconds } }
    public var exerciseIDs: [String] { segments.compactMap(\.exerciseID) }
    public var lineIDs: [String] { segments.flatMap { $0.cues.map(\.line) } }

    /// A copy shorter by up to `minutes`, never under five minutes. Walks lose time from the middle
    /// of warm-up and cool-down (keeping every phase and its opening and closing lines); chair and
    /// stretch blocks drop their last exercise. The steady set is never shortened.
    public func shortened(byMinutes minutes: Int) -> SessionPlan {
        var remaining = min(minutes * 60, max(0, totalSeconds - Self.minimumSeconds))
        var copy = self
        for b in copy.blocks.indices where copy.blocks[b].kind == .walk {
            for s in copy.blocks[b].segments.indices where remaining > 0 {
                let segment = copy.blocks[b].segments[s]
                // Only the walking itself shrinks; a cool-down stretch keeps its holds.
                guard let keepHead = Self.trimStart[segment.kind], !(segment.exerciseID?.hasPrefix("st.") ?? false) else { continue }
                let cut = min(remaining, segment.seconds - Self.minimumPhaseSeconds)
                guard cut > 0 else { continue }
                copy.blocks[b].segments[s] = Self.trim(segment, by: cut, from: keepHead)
                remaining -= cut
            }
        }
        for b in copy.blocks.indices.reversed() where remaining > 0 && ![.walk, .steady].contains(copy.blocks[b].kind) {
            while remaining > 0, let last = copy.blocks[b].segments.lastIndex(where: \.isExercise),
                  copy.blocks[b].segments.filter(\.isExercise).count > 1 {
                remaining -= copy.blocks[b].segments[last].seconds
                copy.blocks[b].segments.remove(at: last)
                if last > 0, copy.blocks[b].segments[last - 1].kind == .rest {
                    remaining -= copy.blocks[b].segments[last - 1].seconds
                    copy.blocks[b].segments.remove(at: last - 1)
                }
            }
        }
        return copy
    }

    /// Warm-up and cool-down keep at least a minute.
    static let minimumPhaseSeconds = 60
    /// Where the removable window starts: after the opening, set-up and safety lines (A2 §3.3: the
    /// "stop if…" lines end by about 0:45 of a 2:00 warm-up).
    static let trimStart: [Segment.Kind: Int] = [.warmup: 45, .cooldown: 22]

    /// Removes `cut` seconds starting at `start`: cues inside the window go, later cues move earlier.
    static func trim(_ segment: Segment, by cut: Int, from start: Int) -> Segment {
        var trimmed = segment
        trimmed.seconds -= cut
        trimmed.cues = segment.cues.compactMap { cue in
            if cue.at < start { return cue }
            if cue.at < start + cut { return nil }
            return SessionTemplate.Cue(at: cue.at - cut, line: cue.line)
        }
        return trimmed
    }
}

public extension SessionTemplate.Segment {
    /// A chair move or a stretch pose (not a warm-up march or a walking move): what the move bar counts.
    var isExercise: Bool { exerciseID != nil && (kind == .move || kind == .stretch) }
}

public extension SessionPlan {
    /// "a4.v1.1" (the six first moves) or "a4.side-leg.intro" (A4-chair-moves.md).
    static func isMoveIntroduction(_ line: String) -> Bool {
        guard line.hasPrefix("a4.") else { return false }
        if line.hasSuffix(".intro") { return true }
        let parts = line.split(separator: ".")
        return parts.count == 3 && parts[1].hasPrefix("v") && parts[2] == "1"
    }

    /// The same plan without each chair move's opening line (its name and what it is for), for
    /// people who know the moves ("Move introductions" off in Me). Timing does not change.
    func withoutMoveIntroductions() -> SessionPlan {
        var plan = self
        for b in plan.blocks.indices {
            for s in plan.blocks[b].segments.indices where plan.blocks[b].segments[s].kind == .move {
                let cues = plan.blocks[b].segments[s].cues
                // Only a chair move's opening line (A4 intro) at the start, and never the move's only line.
                // Balance keeps its openings: they say how to stand and where the hands go.
                if cues.count > 1, let first = cues.first, first.at == 0, Self.isMoveIntroduction(first.line) {
                    plan.blocks[b].segments[s].cues = Array(cues.dropFirst())
                }
            }
        }
        return plan
    }
}
