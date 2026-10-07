import Foundation

/// What a day holds: a main part (nil on a rest day), chair moves added after a walk, whether the
/// cool-down stretch set closes the session, and the two-minute steady set at the end.
public struct PlannedDay: Equatable, Sendable {
    public enum Main: Equatable, Hashable, Sendable { case walk, longWalk, chair, stretch }

    /// About two minutes of balance after the main part, on every training day (review 06/10/2026 Q2:
    /// World Falls Guidelines 2022 ask for balance on at least three days a week, and walking alone is
    /// not enough). Free: the gentle set, both hands on the chair. Pro: the set follows the intensity.
    public enum SteadySet: Equatable, Hashable, Sendable { case gentle, matchingIntensity }

    public var main: Main?
    /// Chair moves added after a walk. A chair day picks its own count from the intensity.
    public var chairMoves: Int
    public var cooldown: Bool
    /// Nil for sessions picked outside the plan ("All sessions", outdoors, the first walk).
    public var steadySet: SteadySet?

    public init(main: Main?, chairMoves: Int, cooldown: Bool, steadySet: SteadySet? = nil) {
        self.main = main; self.chairMoves = chairMoves; self.cooldown = cooldown; self.steadySet = steadySet
    }

    public static let rest = PlannedDay(main: nil, chairMoves: 0, cooldown: false)
    public var isRest: Bool { main == nil }
}

/// The weekly rhythm (spec S07 sample week: Walk · Stretch · Walk · Chair · Walk · Rest · Rest).
public enum WeeklyPlanner {
    /// Training days in order from Monday; rest days are skipped and the pattern shifts.
    static let order: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

    /// Pro pattern for the training days of a week, in order. Extra days (fewer than two rest days)
    /// repeat from the start.
    static let proPattern = [
        PlannedDay(main: .walk, chairMoves: 1, cooldown: false, steadySet: .matchingIntensity),
        PlannedDay(main: .stretch, chairMoves: 0, cooldown: false, steadySet: .matchingIntensity),
        PlannedDay(main: .walk, chairMoves: 2, cooldown: false, steadySet: .matchingIntensity),
        PlannedDay(main: .chair, chairMoves: 0, cooldown: true, steadySet: .matchingIntensity),
        PlannedDay(main: .longWalk, chairMoves: 0, cooldown: true, steadySet: .matchingIntensity),
    ]

    public static func week(restDays: Set<Weekday>, entitlement: Entitlement) -> [Weekday: PlannedDay] {
        let rest = RestDays.effective(chosen: restDays, entitlement: entitlement)
        let training = order.filter { !rest.contains($0) }
        var week = Dictionary(uniqueKeysWithValues: rest.map { ($0, PlannedDay.rest) })
        for (index, day) in training.enumerated() {
            week[day] = entitlement.isPro
                ? proPattern[index % proPattern.count]
                // Free: a walk every training day, 1 or 2 chair moves in turn, short cool-down, gentle steady set.
                : PlannedDay(main: .walk, chairMoves: index.isMultiple(of: 2) ? 1 : 2, cooldown: true, steadySet: .gentle)
        }
        return week
    }

    public static func day(for date: Date, restDays: Set<Weekday>, entitlement: Entitlement, calendar: Calendar) -> PlannedDay {
        week(restDays: restDays, entitlement: entitlement)[Weekday(of: date, in: calendar)] ?? .rest
    }
}
