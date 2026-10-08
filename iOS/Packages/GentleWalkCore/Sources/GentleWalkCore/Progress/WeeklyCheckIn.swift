import Foundation

/// "This week felt…" (P6, plan 4.9).
public enum WeeklyEffort: String, Codable, CaseIterable, Sendable { case easier, right, harder }

/// "One thing that felt a bit better?" Her own words, kept as she chose them; never a health claim.
public enum BetterChip: String, Codable, CaseIterable, Sendable {
    case gettingUp, stairs, morningStiffness, energy, sleep, walkingOutside, nothingYet

    /// English source of the chip (the app shows it through the String Catalog).
    public var title: String {
        switch self {
        case .gettingUp: "Getting up from a chair"
        case .stairs: "Stairs"
        case .morningStiffness: "Stiffness in the morning"
        case .energy: "Energy"
        case .sleep: "Sleep"
        case .walkingOutside: "Walking outside"
        case .nothingYet: "Nothing yet"
        }
    }
}

/// Her answer about one Monday–Sunday week. `effort == nil`: she tapped Skip (not asked again that week).
public struct WeeklyNote: Codable, Equatable, Sendable {
    public var weekStart: Date
    public var effort: WeeklyEffort?
    public var better: BetterChip?
    public var answeredAt: Date

    public init(weekStart: Date, effort: WeeklyEffort?, better: BetterChip?, answeredAt: Date) {
        self.weekStart = weekStart; self.effort = effort; self.better = better; self.answeredAt = answeredAt
    }
}

/// What an answer changes in the following week: walks a little shorter or longer, the check-in chosen
/// in advance (she can still change it), and no ladder raises after a hard week.
public struct WeekEffects: Equatable, Sendable {
    public var minutesDelta: Int
    public var defaultCheckIn: CheckIn?
    public var laddersFrozen: Bool

    public init(minutesDelta: Int, defaultCheckIn: CheckIn?, laddersFrozen: Bool) {
        self.minutesDelta = minutesDelta; self.defaultCheckIn = defaultCheckIn; self.laddersFrozen = laddersFrozen
    }

    public static let none = WeekEffects(minutesDelta: 0, defaultCheckIn: nil, laddersFrozen: false)
}

/// The weekly check-in (D11): the first open from Sunday to Tuesday asks about the Monday–Sunday week
/// just gone, once, skippable; no notification of its own. Notes stay on the device (≤ 24).
public enum WeeklyCheckIn {
    public static let kept = 24
    public static let minutesChange = 2

    /// The Monday that starts the week being asked about, on Sunday, Monday or Tuesday; nil otherwise.
    public static func reviewedWeek(now: Date, calendar: Calendar) -> Date? {
        let back: Int
        switch calendar.component(.weekday, from: now) {
        case 1: back = 6   // Sunday: the week ending today
        case 2: back = 7   // Monday: last week
        case 3: back = 8   // Tuesday: last week
        default: return nil
        }
        return calendar.date(byAdding: .day, value: -back, to: calendar.startOfDay(for: now))
    }

    /// Ask now: a week to ask about, she moved in it at least once, and it was not answered or skipped.
    public static func isDue(now: Date, notes: [WeeklyNote], workouts: [Date], calendar: Calendar) -> Bool {
        guard let start = reviewedWeek(now: now, calendar: calendar),
              let end = calendar.date(byAdding: .day, value: 7, to: start) else { return false }
        guard workouts.contains(where: { $0 >= start && $0 < end }) else { return false }
        return !notes.contains { calendar.isDate($0.weekStart, inSameDayAs: start) }
    }

    /// The answer that shapes now: given already, and the week after the one it is about not yet over.
    public static func current(notes: [WeeklyNote], now: Date, calendar: Calendar) -> WeeklyNote? {
        notes.filter { note in
            guard let until = calendar.date(byAdding: .day, value: 14, to: note.weekStart) else { return false }
            return note.answeredAt <= now && now < until
        }
        .max { $0.weekStart < $1.weekStart }
    }

    public static func effects(of note: WeeklyNote?) -> WeekEffects {
        switch note?.effort {
        case .harder?: WeekEffects(minutesDelta: -minutesChange, defaultCheckIn: .achy, laddersFrozen: true)
        case .easier?: WeekEffects(minutesDelta: minutesChange, defaultCheckIn: .great, laddersFrozen: false)
        case .right?, nil: .none
        }
    }

    /// "Last week you said stairs felt a bit better." on Monday and Tuesday; nil for "Nothing yet".
    public static func lastWeekChip(notes: [WeeklyNote], now: Date, calendar: Calendar) -> BetterChip? {
        guard [2, 3].contains(calendar.component(.weekday, from: now)),
              let chip = current(notes: notes, now: now, calendar: calendar)?.better, chip != .nothingYet else { return nil }
        return chip
    }

    /// One note per week (a new answer replaces the old one), oldest first, the latest `kept`.
    public static func adding(_ note: WeeklyNote, to notes: [WeeklyNote]) -> [WeeklyNote] {
        let others = notes.filter { $0.weekStart != note.weekStart }
        return Array((others + [note]).sorted { $0.weekStart < $1.weekStart }.suffix(kept))
    }
}
