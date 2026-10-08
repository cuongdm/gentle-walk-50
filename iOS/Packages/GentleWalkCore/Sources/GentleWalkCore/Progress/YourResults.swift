import Foundation

/// Minutes moving in one calendar week (P8 "Your results").
public struct WeekPoint: Equatable, Sendable {
    public var weekStart: Date
    public var minutes: Int
    public var activeDays: Int

    public init(weekStart: Date, minutes: Int, activeDays: Int) {
        self.weekStart = weekStart; self.minutes = minutes; self.activeDays = activeDays
    }
}

/// One finished session as the results card sees it.
public struct MovedSession: Equatable, Sendable {
    public var date: Date
    public var seconds: Int
    /// A walk with no Break (for "Longest walk without a break").
    public var unbrokenWalk: Bool

    public init(date: Date, seconds: Int, unbrokenWalk: Bool) {
        self.date = date; self.seconds = seconds; self.unbrokenWalk = unbrokenWalk
    }
}

/// "Your results" at the top of Progress (plan 4.10, P8; design claude-design/Outcomes.dc.html): the last
/// four weeks of minutes, compared only with her own earlier weeks; never a score, never a norm.
public enum YourResults {
    public static let weeksShown = 4
    /// Weeks before this one whose median is "your usual".
    public static let usualWeeks = 4
    /// Active days in a week for it to count in "weeks in a row".
    public static let steadyWeekDays = 3

    /// Minutes and active days per calendar week, oldest first, ending with the week of `now`.
    public static func weeklyMinutes(_ sessions: [MovedSession], now: Date, calendar: Calendar,
                                     weeks: Int = weeksShown) -> [WeekPoint] {
        guard let thisWeek = calendar.dateInterval(of: .weekOfYear, for: now) else { return [] }
        return (0..<weeks).reversed().compactMap { back -> WeekPoint? in
            guard let start = calendar.date(byAdding: .weekOfYear, value: -back, to: thisWeek.start),
                  let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start) else { return nil }
            let inWeek = sessions.filter { $0.date >= start && $0.date < end }
            let seconds = inWeek.reduce(0) { $0 + $1.seconds }
            let days = Set(inWeek.map { calendar.startOfDay(for: $0.date) }).count
            return WeekPoint(weekStart: start, minutes: Int((Double(seconds) / 60).rounded()), activeDays: days)
        }
    }

    /// Her usual minutes a week: the median of the four weeks before this one that had any minutes; nil
    /// when none had.
    public static func usualMinutes(_ sessions: [MovedSession], now: Date, calendar: Calendar) -> Int? {
        let before = weeklyMinutes(sessions, now: now, calendar: calendar, weeks: usualWeeks + 1).dropLast()
            .map(\.minutes).filter { $0 > 0 }.sorted()
        guard !before.isEmpty else { return nil }
        let middle = before.count / 2
        return before.count.isMultiple(of: 2) ? (before[middle - 1] + before[middle]) / 2 : before[middle]
    }

    /// Weeks in a row with three or more active days, counting back from this week (or last week while
    /// this one is still under way). Rest days never break it: only active days count.
    public static func steadyWeeksInARow(_ sessions: [MovedSession], now: Date, calendar: Calendar) -> Int {
        let weeks = weeklyMinutes(sessions, now: now, calendar: calendar, weeks: 52)
        var run = weeks.reversed().drop { $0.activeDays < steadyWeekDays && $0.weekStart == weeks.last?.weekStart }
        var count = 0
        while let week = run.first, week.activeDays >= steadyWeekDays {
            count += 1
            run = run.dropFirst()
        }
        return count
    }

    /// Longest unbroken walk in her first week of sessions, in whole minutes (at least one); nil without one.
    public static func firstWeekLongestWalk(_ sessions: [MovedSession]) -> Int? {
        guard let first = sessions.map(\.date).min() else { return nil }
        let end = first.addingTimeInterval(7 * 86_400)
        return sessions.filter { $0.unbrokenWalk && $0.date < end }.map(\.seconds).max()
            .map { max(1, Int((Double($0) / 60).rounded())) }
    }
}
