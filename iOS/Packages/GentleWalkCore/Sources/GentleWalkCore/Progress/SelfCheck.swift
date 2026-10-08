import Foundation

/// One 2-week self-check: 30 seconds of sit-to-stands, counted by her (plan docs/plans/2026-10-08-steady-program.md).
/// It is general fitness, not a medical test: no age norms, no risk labels (docs/design/steady-claims.md).
public struct SelfCheckResult: Codable, Equatable, Sendable {
    public var date: Date
    public var count: Int
    /// Whether she pushed up from the chair with her hands. Only checks done the same way are compared.
    public var usedHands: Bool

    public init(date: Date, count: Int, usedHands: Bool) {
        self.date = date; self.count = count; self.usedHands = usedHands
    }
}

/// What Today shows about the next self-check.
public enum SelfCheckStatus: Equatable, Sendable {
    /// Nothing to show (no session yet, or "Later" was tapped less than two days ago).
    case none
    /// After the first session: invite her to see where she starts (week 0).
    case invite
    case dueIn(days: Int)
    case due
    /// Past the window: Today says "whenever you're ready", never "late".
    case overdue
}

public enum SelfCheckSchedule {
    public static let intervalDays = 14
    /// The check counts as due from two days early…
    public static let earlyDays = 2
    /// …to three days late.
    public static let lateDays = 3
    /// "Later" on the week-0 invite hides it for this many days.
    public static let laterDays = 2

    public static func status(firstWorkout: Date?, results: [Date], dismissedAt: Date?, now: Date,
                              calendar: Calendar) -> SelfCheckStatus {
        guard firstWorkout != nil else { return .none }
        guard let latest = results.max() else {
            guard let dismissedAt else { return .invite }
            return ProgramCalendar.days(from: dismissedAt, to: now, calendar: calendar) < laterDays ? .none : .due
        }
        let days = ProgramCalendar.days(from: latest, to: now, calendar: calendar)
        if days < intervalDays - earlyDays { return .dueIn(days: intervalDays - days) }
        return days <= intervalDays + lateDays ? .due : .overdue
    }

    /// The day the next check is due (two weeks after the latest), for the reminder; nil before the first.
    public static func dueDate(results: [Date], calendar: Calendar) -> Date? {
        results.max().flatMap { calendar.date(byAdding: .day, value: intervalDays, to: calendar.startOfDay(for: $0)) }
    }
}

/// Change in count against her own earlier checks done the same way; nil when there is nothing to compare.
public struct SelfCheckDelta: Equatable, Sendable {
    public var sinceFirst: Int?
    public var sinceLast: Int?
    /// The first check done this way (with or without hands): it starts a new line, compared with nothing.
    public var newMethodBaseline: Bool

    public init(sinceFirst: Int?, sinceLast: Int?, newMethodBaseline: Bool) {
        self.sinceFirst = sinceFirst; self.sinceLast = sinceLast; self.newMethodBaseline = newMethodBaseline
    }
}

public enum SelfCheckComparison {
    /// Counts outside this range are not saved.
    public static let countRange = 0...40

    public static func isValid(_ count: Int) -> Bool { countRange.contains(count) }

    public static func delta(latest: SelfCheckResult, history: [SelfCheckResult]) -> SelfCheckDelta {
        let sameWay = history.filter { $0.usedHands == latest.usedHands && $0.date < latest.date }.sorted { $0.date < $1.date }
        guard let first = sameWay.first, let last = sameWay.last else {
            return SelfCheckDelta(sinceFirst: nil, sinceLast: nil, newMethodBaseline: !history.isEmpty)
        }
        return SelfCheckDelta(sinceFirst: latest.count - first.count, sinceLast: latest.count - last.count,
                              newMethodBaseline: false)
    }
}
