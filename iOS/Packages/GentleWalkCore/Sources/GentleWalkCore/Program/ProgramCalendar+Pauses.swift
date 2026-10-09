import Foundation

/// A break she chose to pick up from ("Pick up at week 5", plan 2.3): the `days` after her last session
/// (`after`) stopped counting. Kept so sessions before the break keep their week and stage
/// (docs/plans/2026-10-09-plan-journey-link.md); `ProgramRound.pausedDays` is the sum of these.
public struct ProgramPause: Codable, Equatable, Sendable {
    /// Her last session before the break.
    public var after: Date
    public var days: Int

    public init(after: Date, days: Int) {
        self.after = after; self.days = days
    }
}

extension ProgramCalendar {
    /// The pause that `pickUp(_:lastWorkout:now:calendar:)` adds, to keep beside the round.
    public static func pickUpPause(lastWorkout: Date, now: Date, calendar: Calendar) -> ProgramPause {
        ProgramPause(after: lastWorkout, days: max(0, days(from: lastWorkout, to: now, calendar: calendar)))
    }

    /// Program day of `date`: 0 on the day week 1 began. The days of a recorded pause stop counting only from
    /// her last session before it, so earlier dates keep their day; paused days with no record (a store from
    /// before pauses were kept) shift every date, as `position(_:on:calendar:)` does. On the day she picked up,
    /// and after, it agrees with `position`.
    public static func programDay(_ round: ProgramRound, pauses: [ProgramPause], on date: Date, calendar: Calendar) -> Int {
        let recorded = pauses.reduce(0) { $0 + max(0, $1.days) }
        let unrecorded = max(0, round.pausedDays - recorded)
        // During a pause the day stands still; once it is over, all of its days are taken off.
        let paused = pauses.reduce(0) { sum, pause in
            sum + min(max(0, pause.days), max(0, days(from: pause.after, to: date, calendar: calendar)))
        }
        return max(0, days(from: round.start, to: date, calendar: calendar) - unrecorded - paused)
    }

    /// Program week of `date`: 1, 2 … and past 12 once the round is over.
    public static func week(_ round: ProgramRound, pauses: [ProgramPause], on date: Date, calendar: Calendar) -> Int {
        programDay(round, pauses: pauses, on: date, calendar: calendar) / 7 + 1
    }
}
