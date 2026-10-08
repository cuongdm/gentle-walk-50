public extension SessionPlan {
    /// Seconds before the end of an easy part kept as they are: the "ten seconds, then quicker" lines.
    static let easyTail = 12
    /// No easy part grows by more than this.
    static let maxEasyGrowth = 60

    /// A copy longer by about `minutes` (a week she found easier, P6): every easy part of the walk grows a
    /// little, in its middle, so the move's instructions stay at its start and the "ten seconds" lines
    /// stay ten seconds before the change. Chair, stretch and steady blocks stay as they are.
    func lengthened(byMinutes minutes: Int) -> SessionPlan {
        guard minutes > 0, let b = blocks.firstIndex(where: { $0.kind == .walk }) else { return self }
        let easy = blocks[b].segments.indices.filter { blocks[b].segments[$0].kind == .easy }
        guard !easy.isEmpty else { return self }
        let share = min(Self.maxEasyGrowth, Int((Double(minutes * 60) / Double(easy.count)).rounded(.up)))
        var copy = self
        for s in easy {
            var segment = copy.blocks[b].segments[s]
            let start = max(0, segment.seconds - Self.easyTail)
            segment.cues = segment.cues.map { cue in
                var moved = cue
                if cue.at >= start { moved.at += share }
                return moved
            }
            segment.seconds += share
            copy.blocks[b].segments[s] = segment
        }
        return copy
    }
}
