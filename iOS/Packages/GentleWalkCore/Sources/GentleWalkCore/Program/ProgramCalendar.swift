import Foundation

/// The four stages of the 12-week steady program (plan docs/plans/2026-10-08-steady-program.md).
/// A stage is a label for where she is; reps and support go up only when she is ready (RepLadder,
/// SupportLadder), never because a week turned.
public enum ProgramStage: Int, CaseIterable, Codable, Sendable {
    case base = 1, build, challenge, routine

    /// Weeks 1–3, 4–6, 7–9, 10–12.
    public static func of(week: Int) -> ProgramStage {
        ProgramStage(rawValue: min(max((week - 1) / 3 + 1, 1), 4)) ?? .base
    }
}

/// Where she is in a round of the program.
public enum ProgramPosition: Equatable, Sendable {
    case week(Int, ProgramStage)
    case finished
}

/// One run through the 12 weeks. `pausedDays` are days she was away and chose to pick up where she
/// stopped; they do not count towards the weeks.
public struct ProgramRound: Codable, Equatable, Sendable {
    public var start: Date
    public var round: Int
    public var pausedDays: Int

    public init(start: Date, round: Int = 1, pausedDays: Int = 0) {
        self.start = start; self.round = round; self.pausedDays = pausedDays
    }
}

/// What Today offers after a long break: never "lost", only "pick up at week N".
public enum ProgramResumeOffer: Equatable, Sendable {
    case pickUp(atWeek: Int)
}

/// Week and stage of the program for a date.
public enum ProgramCalendar {
    public static let weeks = 12

    public static func position(_ round: ProgramRound, on date: Date, calendar: Calendar) -> ProgramPosition {
        let week = max(0, days(from: round.start, to: date, calendar: calendar) - round.pausedDays) / 7 + 1
        return week > weeks ? .finished : .week(week, .of(week: week))
    }

    /// Days without a session before Today offers to pick up where she stopped (plan 2.3).
    public static let pickUpGapDays = 14

    /// After `pickUpGapDays` or more without a session, offer to carry on from that session's week.
    public static func resumeOffer(_ round: ProgramRound, lastWorkout: Date?, now: Date,
                                   calendar: Calendar) -> ProgramResumeOffer? {
        guard let lastWorkout, days(from: lastWorkout, to: now, calendar: calendar) >= pickUpGapDays,
              case .week(let week, _) = position(round, on: lastWorkout, calendar: calendar) else { return nil }
        return .pickUp(atWeek: week)
    }

    /// The days since her last session stop counting, so today is the week she stopped in.
    public static func pickUp(_ round: ProgramRound, lastWorkout: Date, now: Date, calendar: Calendar) -> ProgramRound {
        var picked = round
        picked.pausedDays += max(0, days(from: lastWorkout, to: now, calendar: calendar))
        return picked
    }

    /// A new round from week 1 on `date` (plan 2.4). Self-check history is kept elsewhere and untouched.
    public static func restart(_ round: ProgramRound, on date: Date, calendar: Calendar) -> ProgramRound {
        ProgramRound(start: calendar.startOfDay(for: date), round: round.round + 1)
    }

    /// Calendar days in her time zone, so daylight saving and late starts never shift a week.
    static func days(from start: Date, to end: Date, calendar: Calendar) -> Int {
        calendar.dateComponents([.day], from: calendar.startOfDay(for: start), to: calendar.startOfDay(for: end)).day ?? 0
    }
}
