/// How much she holds on in a balance exercise (A11 §2.2): both hands, one hand, fingertips. Never
/// "no hands" and never eyes closed (review docs/reviews/2026-10-06-chuyen-gia-ra-soat-bai-tap-58-75.md).
public enum SupportLevel: Int, Codable, CaseIterable, Comparable, Sendable {
    case twoHands, oneHand, fingertips

    public static func < (lhs: SupportLevel, rhs: SupportLevel) -> Bool { lhs.rawValue < rhs.rawValue }

    /// The coach's line for this level (A11 §2.4).
    public var handsLine: String {
        switch self {
        case .twoHands: "a11.hands.two"
        case .oneHand: "a11.hands.one"
        case .fingertips: "a11.hands.tips"
        }
    }

    /// Lines that say where her hands go, any level.
    static let handsLines: Set<String> = Set(allCases.map(\.handsLine))
}

/// One balance exercise's step on the ladder, and whether the coach still has to announce a change.
public struct SupportProgress: Codable, Equatable, Sendable {
    public var level: SupportLevel
    /// Sessions in a row held through at this level without This hurts or a Break.
    public var steadySessions: Int
    /// Set when the level changed and the coach has not said so yet.
    public var pendingChange: SupportLadder.Change?

    public init(level: SupportLevel = .twoHands, steadySessions: Int = 0, pendingChange: SupportLadder.Change? = nil) {
        self.level = level; self.steadySessions = steadySessions; self.pendingChange = pendingChange
    }
}

/// The support ladder of the balance exercises (Pro; review 06/10/2026, Otago "progress from 2 hands
/// to 1 hand"): up one step after two sessions in a row held through, down one step after This hurts
/// or a Break in that exercise. Today's level is also capped by the day's intensity and her limits.
public enum SupportLadder {
    public enum Change: String, Codable, Equatable, Sendable { case up, down }

    /// Exercises that say where her hands go.
    public static let exercises: Set<String> = [
        "wk.shift", "bl.tandem", "mv.single-leg", "bl.side-walk", "mv.heel-toe", "bl.back-walk", "bl.walk-turn",
        "bl.heel-toe-walking",
    ]
    public static let sessionsToRaise = 2

    /// The highest step for an exercise (A11 §2.2, Strong column): fingertips only in tandem stance.
    public static func highest(_ exerciseID: String) -> SupportLevel {
        exerciseID == "bl.tandem" ? .fingertips : .oneHand
    }

    /// The most a day's intensity allows: an achy day always holds on with both hands.
    public static func cap(_ intensity: Intensity) -> SupportLevel {
        switch intensity {
        case .gentle: .twoHands
        case .steady: .oneHand
        case .strong: .fingertips
        }
    }

    /// Level for today. Dizziness or feeling unsteady keeps both hands on every time.
    public static func today(_ exerciseID: String, progress: [String: SupportProgress], intensity: Intensity,
                             limits: Set<BodyLimit>) -> SupportLevel {
        guard limits.isDisjoint(with: [.dizzy, .unsteady]) else { return .twoHands }
        let earned = progress[exerciseID]?.level ?? .twoHands
        return min(earned, cap(intensity), highest(exerciseID))
    }

    /// Levels for every ladder exercise today, and the changes the coach should announce.
    public static func plan(progress: [String: SupportProgress], intensity: Intensity, limits: Set<BodyLimit>)
        -> (levels: [String: SupportLevel], announce: [String: Change]) {
        var levels: [String: SupportLevel] = [:]
        var announce: [String: Change] = [:]
        for id in exercises {
            let level = today(id, progress: progress, intensity: intensity, limits: limits)
            levels[id] = level
            // Announce only what she will actually do today: a raise she cannot use on an achy day waits.
            if let change = progress[id]?.pendingChange, change == .down || level == progress[id]?.level {
                announce[id] = change
            }
        }
        return (levels, announce)
    }

    /// After a session: `steady` exercises were held through, `troubled` had This hurts or a Break.
    /// `holdRaises`: her last 2-week check went down by two (P9): sessions still count, no step up yet.
    public static func update(_ progress: [String: SupportProgress], steady: Set<String>, troubled: Set<String>,
                              holdRaises: Bool = false) -> [String: SupportProgress] {
        var result = progress
        for id in exercises.intersection(steady.union(troubled)) {
            var entry = result[id] ?? SupportProgress()
            if troubled.contains(id) {
                entry.steadySessions = 0
                if let lower = SupportLevel(rawValue: entry.level.rawValue - 1) {
                    entry.level = lower
                    entry.pendingChange = .down
                }
            } else {
                entry.steadySessions += 1
                if !holdRaises, entry.steadySessions >= sessionsToRaise, entry.level < highest(id),
                   let higher = SupportLevel(rawValue: entry.level.rawValue + 1) {
                    entry.level = higher
                    entry.steadySessions = 0
                    entry.pendingChange = .up
                }
            }
            result[id] = entry
        }
        return result
    }

    /// Back after a long break ("Pick up at week N", P13): every exercise one step down, never below
    /// both hands; the coach says so at the next session (`a11.ladder.down`). Counts start again.
    public static func stepDownAll(_ progress: [String: SupportProgress]) -> [String: SupportProgress] {
        progress.mapValues { entry in
            var copy = entry
            copy.steadySessions = 0
            if let lower = SupportLevel(rawValue: entry.level.rawValue - 1) {
                copy.level = lower
                copy.pendingChange = .down
            } else {
                copy.pendingChange = nil
            }
            return copy
        }
    }

    /// The coach's line that announces a change to `level`.
    static func announcement(_ change: Change, to level: SupportLevel) -> String {
        switch (change, level) {
        case (.down, _): "a11.ladder.down"
        case (.up, .fingertips): "a11.ladder.tips"
        case (.up, _): "a11.ladder.one"
        }
    }
}

/// "Hands on the chair" on Progress (plan 08/10/2026 task 3.7): how many of the balance moves sit on each
/// step of the ladder. A move with no level yet (free, or never done) is on two hands.
public struct SupportLadderSummary: Equatable, Sendable {
    public let levels: [String: SupportLevel]

    public init(levels: [String: SupportLevel]) {
        self.levels = levels.filter { SupportLadder.exercises.contains($0.key) }
    }

    /// Every balance move of the ladder.
    public var total: Int { SupportLadder.exercises.count }

    /// Moves on this step.
    public func count(_ level: SupportLevel) -> Int {
        SupportLadder.exercises.filter { (levels[$0] ?? .twoHands) == level }.count
    }

    /// The highest step any move has reached.
    public var highest: SupportLevel { levels.values.max() ?? .twoHands }
}
