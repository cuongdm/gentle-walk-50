import Foundation

/// "How did that feel?" after a session (S15).
public enum Feeling: String, CaseIterable, Codable, Sendable { case tooEasy, justRight, tooHard }

/// What adaptation needs to know about one finished session.
public struct SessionFeedback: Equatable, Sendable {
    public var level: WalkLevel
    public var feeling: Feeling?
    public var breakCount: Int
    /// When the session was done; `nil` in old callers (then it always counts).
    public var date: Date?

    public init(level: WalkLevel, feeling: Feeling?, breakCount: Int, date: Date? = nil) {
        self.level = level; self.feeling = feeling; self.breakCount = breakCount; self.date = date
    }
}

/// The walking level she is on now and when it last changed (`nil` = never changed since onboarding).
public struct LevelState: Equatable, Sendable {
    public var level: WalkLevel
    public var changedAt: Date?

    public init(level: WalkLevel, changedAt: Date?) {
        self.level = level; self.changedAt = changedAt
    }
}

/// The Today card that explains an automatic change (spec "Tự điều chỉnh").
public enum AdaptationCard: Equatable, Codable, Sendable {
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
    /// The check-in chosen in advance on Today (she can change it with one tap; P2, D16): Achy after two
    /// "Too hard" in a row, Great after two "Too easy" at a level with no automatic step up.
    public var suggestedCheckIn: CheckIn? = nil
}

/// Level and length changes from feedback (task 2.9).
public enum Adaptation {
    /// Same answer this many times in a row at the current level changes the level.
    public static let streakLength = 3
    /// Break pressed this many times in one session shortens the next one.
    public static let breaksForShorter = 2
    public static let shorterByMinutes = 2
    /// Same answer this many times in a row at the current level: a gentler (or stronger) day first.
    public static let suggestLength = 2

    /// `history` is oldest first. Same as `next(state:history:)` for a level that never changed.
    public static func next(level: WalkLevel, history: [SessionFeedback]) -> AdaptationResult {
        next(state: LevelState(level: level, changedAt: nil), history: history)
    }

    /// Only answers given at the current level, after its last change, can move her again
    /// (so a step up can be undone by "Too hard" at the new level, and old answers never re-trigger).
    public static func next(state: LevelState, history: [SessionFeedback]) -> AdaptationResult {
        let level = state.level
        var result = AdaptationResult(level: level, minutesDelta: 0, card: nil)
        if let last = history.last, last.breakCount >= breaksForShorter {
            result.minutesDelta = -shorterByMinutes
            result.card = .shorter
        }
        let answers = history.filter { feedback in
            guard feedback.level == level else { return false }
            guard let changedAt = state.changedAt, let date = feedback.date else { return true }
            return date > changedAt
        }.compactMap(\.feeling)
        let streak = answers.reversed().prefix { $0 == answers.last }
        // Two in a row (P2): the next day starts gentler and a little shorter, or stronger where the level
        // cannot go up by itself. A third one moves the level (below).
        let movesDown = streak.count >= streakLength && answers.last == .tooHard && level.easier != nil
        if streak.count >= suggestLength, !movesDown, let feeling = answers.last {
            switch feeling {
            case .tooHard:
                result.suggestedCheckIn = .achy
                result.minutesDelta = -shorterByMinutes
            case .tooEasy where level.harder == nil:
                result.suggestedCheckIn = .great
            case .tooEasy, .justRight:
                break
            }
        }
        guard streak.count >= streakLength, let feeling = answers.last else { return result }
        switch feeling {
        case .tooHard:
            // A new, easier level is the change: no gentler, shorter day on top of it.
            if let easier = level.easier { result.level = easier; result.card = .movedDown(to: easier) }
        case .tooEasy:
            if let harder = level.harder { result.level = harder; result.card = .movedUp(to: harder) }
        case .justRight:
            break
        }
        return result
    }
}
