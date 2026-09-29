/// "How did that feel?" after a session (S15).
public enum Feeling: String, CaseIterable, Codable, Sendable { case tooEasy, justRight, tooHard }

/// What adaptation needs to know about one finished session.
public struct SessionFeedback: Equatable, Sendable {
    public var level: WalkLevel
    public var feeling: Feeling?
    public var breakCount: Int

    public init(level: WalkLevel, feeling: Feeling?, breakCount: Int) {
        self.level = level; self.feeling = feeling; self.breakCount = breakCount
    }
}

/// The Today card that explains an automatic change (spec "Tự điều chỉnh").
public enum AdaptationCard: Equatable, Sendable {
    /// "We moved you back to Seated for now."
    case movedDown(to: WalkLevel)
    case movedUp(to: WalkLevel)
    /// "We made today a little shorter. Build up at your pace."
    case shorter
}

public struct AdaptationResult: Equatable, Sendable {
    public var level: WalkLevel
    /// Minutes to add to the next session (negative = shorter); apply with `SessionPlan.shortened`.
    public var minutesDelta: Int
    public var card: AdaptationCard?
}

/// Level and length changes from feedback (task 2.9).
public enum Adaptation {
    /// Same answer this many times in a row at the current level changes the level.
    public static let streakLength = 3
    /// Break pressed this many times in one session shortens the next one.
    public static let breaksForShorter = 2
    public static let shorterByMinutes = 2

    /// `history` is oldest first.
    public static func next(level: WalkLevel, history: [SessionFeedback]) -> AdaptationResult {
        var result = AdaptationResult(level: level, minutesDelta: 0, card: nil)
        if let last = history.last, last.breakCount >= breaksForShorter {
            result.minutesDelta = -shorterByMinutes
            result.card = .shorter
        }
        let answers = history.filter { $0.level == level }.compactMap(\.feeling)
        let streak = answers.reversed().prefix { $0 == answers.last }
        guard streak.count >= streakLength, let feeling = answers.last else { return result }
        switch feeling {
        case .tooHard:
            if let easier = level.easier { result.level = easier; result.card = .movedDown(to: easier) }
        case .tooEasy:
            if let harder = level.harder { result.level = harder; result.card = .movedUp(to: harder) }
        case .justRight:
            break
        }
        return result
    }
}
