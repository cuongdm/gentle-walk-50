import Foundation

/// Why this Complete screen is special (plan 3.6; anti-boredom #4). The app works it out from the
/// session; "stopped for pain" keeps its own calm screen and never gets a cheer.
public enum CheerContext: String, CaseIterable, Sendable {
    case firstSession, ordinary, cameBack, personalBest, weekDone, stageDone
}

/// A title and one line for Complete. `title` and `line` are the English source: the app shows them
/// through the String Catalog (Vietnamese in docs/i18n/vi/ui-extra-11.json).
public struct Cheer: Equatable, Sendable {
    public var id: String
    public var title: String
    public var line: String
}

/// Varied, kind words after a session: the same place on the screen, different words each time. Only
/// ever compared with herself; never guilt, never a claim.
public enum CompleteCheer {
    /// Back after this many days or more without a session.
    public static let cameBackDays = 3

    public static func context(isFirstSession: Bool, daysSinceLastSession: Int, personalBest: Bool, weekDone: Bool,
                               stageDone: Bool) -> CheerContext {
        if isFirstSession { return .firstSession }
        if stageDone { return .stageDone }
        if personalBest { return .personalBest }
        if weekDone { return .weekDone }
        if daysSinceLastSession >= cameBackDays { return .cameBack }
        return .ordinary
    }

    /// The line for this session: rotates with `sessionIndex` (her active days), and never repeats the
    /// line shown last time (`lastID`).
    public static func pick(_ context: CheerContext, sessionIndex: Int, lastID: String?) -> Cheer {
        let pool = pool(context)
        let index = ((sessionIndex % pool.count) + pool.count) % pool.count
        let cheer = pool[index]
        return cheer.id == lastID ? pool[(index + 1) % pool.count] : cheer
    }

    public static func pool(_ context: CheerContext) -> [Cheer] {
        let lines: [(String, String)] = switch context {
        case .firstSession: [
            ("That's your first one!", "You showed up, and that's the hardest part."),
            ("Day one, done.", "One session at a time, at your own pace."),
            ("Your first session!", "Well done for starting. Come back whenever you like."),
        ]
        case .ordinary: [
            ("You did it!", "Another session in the book."),
            ("Nicely done.", "Every minute here counts."),
            ("That's another one.", "Steady, and at your own pace."),
            ("Well done.", "Your legs did good work today."),
            ("Good work today.", "Thank you for making time for yourself."),
            ("There you go.", "Small sessions add up."),
        ]
        case .cameBack: [
            ("Good to have you back.", "Your plan picked up right where you left it."),
            ("Welcome back!", "Starting again is something to be proud of."),
            ("Nice to see you again.", "One session, and you're back in your rhythm."),
        ]
        case .personalBest: [
            ("A new best for you.", "Compared with yourself, that's your best so far."),
            ("Your best yet.", "Only you to beat, and you did."),
            ("Look at that.", "That's more than your last best."),
        ]
        case .weekDone: [
            ("That's your week.", "Every planned day done. Enjoy your rest days."),
            ("A full week!", "You did every session you planned this week."),
            ("Week complete.", "Rest well. Next week is ready when you are."),
        ]
        case .stageDone: [
            ("Stage complete.", "The next stage starts whenever you're ready."),
            ("On to the next stage.", "You've finished this part of your 12 weeks."),
            ("A stage behind you.", "Look how far you've come, at your own pace."),
        ]
        }
        return lines.enumerated().map { Cheer(id: "cheer.\(context.rawValue).\($0.offset + 1)", title: $0.element.0, line: $0.element.1) }
    }
}

/// One saved session, as the cheer needs it: when, how long, and whether it was a walk with no Break.
public struct CheerSession: Equatable, Sendable {
    public var date: Date
    public var seconds: Int
    public var isUnbrokenWalk: Bool

    public init(date: Date, seconds: Int, isUnbrokenWalk: Bool) {
        self.date = date; self.seconds = seconds; self.isUnbrokenWalk = isUnbrokenWalk
    }
}

public extension CompleteCheer {
    /// Unbroken walks she needs before a longer one counts as "a new best".
    static let bestNeedsWalks = 2
    /// A best is at least a whole minute longer, so the minutes shown go up too.
    static let bestMarginSeconds = 60
    /// Program weeks that close a stage (3, 6, 9, 12).
    static let stageWeeks: Set<Int> = [3, 6, 9, 12]

    /// The context of a session that was just saved, from her own sessions before it (plan 3.6):
    /// - came back: three calendar days or more since the last one;
    /// - personal best: her longest unbroken walk by a whole minute, once she has two to beat;
    /// - week done: this session fills the last planned day of the week (days off excluded);
    /// - stage done: a week done in week 3, 6, 9 or 12 of the program.
    static func context(session: CheerSession, previous: [CheerSession], restDays: Set<Weekday>, programWeek: Int?,
                        calendar: Calendar) -> CheerContext {
        let today = calendar.startOfDay(for: session.date)
        let days = previous.map { calendar.startOfDay(for: $0.date) }
        let gap = days.max().map { calendar.dateComponents([.day], from: $0, to: today).day ?? 0 } ?? 0

        let walks = previous.filter(\.isUnbrokenWalk).map(\.seconds)
        let best = session.isUnbrokenWalk && walks.count >= bestNeedsWalks
            && session.seconds >= (walks.max() ?? 0) + bestMarginSeconds

        var weekDone = false
        if !days.contains(today), let week = calendar.dateInterval(of: .weekOfYear, for: session.date) {
            let planned = max(1, Weekday.allCases.count - restDays.count)
            let active = Set(days.filter { week.contains($0) } + [today])
            weekDone = active.count >= planned
        }
        let stageDone = weekDone && programWeek.map(stageWeeks.contains) == true
        return context(isFirstSession: previous.isEmpty, daysSinceLastSession: gap, personalBest: best, weekDone: weekDone,
                       stageDone: stageDone)
    }
}
