import Foundation

/// Day of the week, numbered like `Calendar.component(.weekday, …)` (Sunday = 1).
public enum Weekday: Int, CaseIterable, Codable, Comparable, Sendable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

    public static func < (lhs: Weekday, rhs: Weekday) -> Bool { lhs.rawValue < rhs.rawValue }

    public init(of date: Date, in calendar: Calendar) {
        self = Weekday(rawValue: calendar.component(.weekday, from: date)) ?? .sunday
    }
}

/// Planned rest days (spec S20: the user picks two; the free tier is fixed to Saturday + Sunday).
public enum RestDays {
    public static let maximum = 2
    public static let freeTier: Set<Weekday> = [.saturday, .sunday]

    /// The chosen days, or nil when more than two were chosen.
    public static func validated(_ days: Set<Weekday>) -> Set<Weekday>? {
        days.count <= maximum ? days : nil
    }

    /// Rest days that apply: the free tier ignores the choice.
    public static func effective(chosen: Set<Weekday>, entitlement: Entitlement) -> Set<Weekday> {
        entitlement.isPro ? (validated(chosen) ?? freeTier) : freeTier
    }
}

/// Active days from workout dates, counted in the user's calendar and time zone.
/// Planned rest days are marked as part of the plan; missed days are never called out.
public struct ActivityCalendar: Sendable {
    public enum Mark: Equatable, Sendable { case active, rest, open }

    /// This week against last week. `fewer` carries no number: the UI never states missed days.
    public enum Comparison: Equatable, Sendable { case more(Int), same, fewer }

    public struct Day: Equatable, Sendable {
        public var date: Date
        public var mark: Mark
    }

    public struct Week: Equatable, Sendable {
        /// Seven days from the calendar's first weekday.
        public var days: [Day]
        public var activeDays: Int { days.filter { $0.mark == .active }.count }
        public var restDays: Int { days.filter { $0.mark == .rest }.count }
    }

    private let activeStarts: Set<Date>
    private let restDays: Set<Weekday>
    private let calendar: Calendar

    public init(records: [Date], restDays: Set<Weekday>, calendar: Calendar) {
        self.activeStarts = Set(records.map { calendar.startOfDay(for: $0) })
        self.restDays = restDays
        self.calendar = calendar
    }

    /// Distinct days with at least one workout.
    public var activeDays: Int { activeStarts.count }

    public func isActive(_ date: Date) -> Bool {
        activeStarts.contains(calendar.startOfDay(for: date))
    }

    public func week(containing date: Date) -> Week {
        let start = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? calendar.startOfDay(for: date)
        let days = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }.map { day in
            Day(date: day, mark: mark(for: day))
        }
        return Week(days: days)
    }

    public func weekComparison(at date: Date) -> Comparison {
        let thisWeek = week(containing: date).activeDays
        guard let lastWeekDate = calendar.date(byAdding: .weekOfYear, value: -1, to: date) else { return .same }
        let lastWeek = week(containing: lastWeekDate).activeDays
        if thisWeek > lastWeek { return .more(thisWeek - lastWeek) }
        return thisWeek == lastWeek ? .same : .fewer
    }

    private func mark(for day: Date) -> Mark {
        if isActive(day) { return .active }
        return restDays.contains(Weekday(of: day, in: calendar)) ? .rest : .open
    }
}
