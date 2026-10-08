/// One line from her own history a session (P7, script docs/scripts/A13-coach-history.md): the program
/// week at the start of the week's first session, or the walks / active days this week at the end.
public enum HistoryLine: Equatable, Sendable {
    /// "Week five of twelve. At your own pace." (opening).
    case week(Int)
    /// "Third walk this week. Nice and steady." (closing).
    case walk(Int)
    /// "That's three active days this week." (closing).
    case activeDays(Int)

    /// The recorded line, or nil when the number has no recording (silence beats a wrong sentence).
    public var lineID: String? {
        switch self {
        case .week(let week): CoachHistory.weekLine(week: week)
        case .walk(let number): CoachHistory.walkLine(walkNumber: number)
        case .activeDays(let days): CoachHistory.daysLine(activeDays: days)
        }
    }

    public var opensTheSession: Bool { if case .week = self { true } else { false } }

    /// The one history line for a session: the program week on the first session of a program week;
    /// otherwise the walk number on a walk (2nd to 5th), else the active days this week (2 to 7).
    /// `walkNumber` and `activeDays` count this session.
    public static func pick(programWeek: Int?, firstOfProgramWeek: Bool, isWalk: Bool, walkNumber: Int,
                            activeDays: Int) -> HistoryLine? {
        if let programWeek, firstOfProgramWeek, CoachHistory.weekLine(week: programWeek) != nil { return .week(programWeek) }
        if isWalk, CoachHistory.walkLine(walkNumber: walkNumber) != nil { return .walk(walkNumber) }
        if activeDays >= 2, CoachHistory.daysLine(activeDays: activeDays) != nil { return .activeDays(activeDays) }
        return nil
    }
}

/// How the day starts (P1, plan 4.1): the coach says the check-in or the state of the day in one line
/// before the first block, and at most one history line (P7, 4.15). Never for the First Walk, extras or
/// outdoor walks: the app passes no opening for those.
public struct OpeningContext: Equatable, Sendable {
    public var intensity: Intensity
    /// Back after a break (Welcome back).
    public var restart: Bool
    /// Shorter than planned today (two Breaks last time, a hard week, an early-stop habit).
    public var shortened: Bool
    /// The walking level changed since her last session.
    public var levelChange: AdaptationCard?
    public var history: HistoryLine?

    public init(intensity: Intensity, restart: Bool = false, shortened: Bool = false, levelChange: AdaptationCard? = nil,
                history: HistoryLine? = nil) {
        self.intensity = intensity; self.restart = restart; self.shortened = shortened
        self.levelChange = levelChange; self.history = history
    }

    /// The day's state line, in this priority: restart > level change > shorter > the check-in. A week
    /// line takes the place of the plain check-in line on the first session of a program week.
    public func stateLine(rotationIndex: Int) -> String {
        if restart { return "a9.back.\(max(0, rotationIndex) % 2 + 1)" }
        switch levelChange {
        case .movedUp?: return "a9.levelup"
        case .movedDown?: return "a9.leveldown"
        case .shorter?, nil: break
        }
        if shortened { return "a9.shorter" }
        if let history, history.opensTheSession, let line = history.lineID { return line }
        return "a9.\(intensity.rawValue)"
    }

    /// The history line said at the end of the session, if any.
    public var closingLine: String? {
        guard let history, !history.opensTheSession else { return nil }
        return history.lineID
    }
}

extension SessionPlan {
    /// Seconds of the opening segment: the line plus a breath, 4 to 6 seconds (plan 4.1).
    static let openingRange = 4...6
    /// Seconds added to the last segment for the closing history line.
    static let closingPad = 1

    /// Adds the opening line in its own short segment before the first block, and the closing history
    /// line after the last cue of the session (the done bell comes just before it).
    func withOpening(_ opening: OpeningContext, rotationIndex: Int, lines: [String: VoiceLine]) -> SessionPlan {
        guard !blocks.isEmpty, !blocks[0].segments.isEmpty else { return self }
        var plan = self
        let state = opening.stateLine(rotationIndex: rotationIndex)
        if lines[state] != nil {
            let spoken = Int((lines[state]?.duration ?? 4).rounded(.up)) + 1
            let seconds = min(max(spoken, Self.openingRange.lowerBound), Self.openingRange.upperBound)
            plan.blocks[0].segments.insert(Segment(kind: .intro, seconds: seconds, cues: [.init(at: 0, line: state)]), at: 0)
        }
        if let closing = opening.closingLine, lines[closing] != nil,
           let b = plan.blocks.indices.last, let s = plan.blocks[b].segments.indices.last {
            var last = plan.blocks[b].segments[s]
            // After the bell lead (`SessionTimeline.bellLead`) and a breath.
            let spoken = Int((lines[closing]?.duration ?? 3).rounded(.up)) + Self.closingPad + 1
            let lastWords = last.cues.map { $0.at + Int((lines[$0.line]?.duration ?? 2).rounded(.up)) }.max() ?? 0
            let end = max(last.seconds, lastWords + 1)
            last.cues.append(.init(at: end, line: closing))
            last.seconds = end + spoken
            plan.blocks[b].segments[s] = last
        }
        return plan
    }
}
