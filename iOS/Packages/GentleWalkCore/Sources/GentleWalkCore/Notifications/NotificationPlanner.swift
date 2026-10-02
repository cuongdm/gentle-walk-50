import Foundation

/// Local notification kinds, most important first (spec "Thông báo · Luật chung").
public enum NotificationKind: String, CaseIterable, Codable, Sendable {
    case trialEnd, dayTwo, landmark, comeback, reminder, weeklyRecap, newJourney

    /// Lower wins when two fall on the same day.
    var priority: Int { Self.allCases.firstIndex(of: self) ?? 0 }
}

/// S20 "How often": every planned day, or only after two quiet days.
public enum ReminderFrequency: String, Codable, Sendable { case daily, quietDays }

/// S20 notification switches. New journeys is off until the user turns it on (4.5.4).
public struct NotificationSettings: Equatable, Codable, Sendable {
    public var walkReminders = true
    public var journeyMilestones = true
    public var weeklyRecap = true
    public var newJourneys = false
    public init() {}
}

/// The next postcard is less than one session away.
public struct LandmarkSoon: Equatable, Sendable {
    public var stopName: String
    public init(stopName: String) { self.stopName = stopName }
}

public struct PlannerInput: Equatable, Sendable {
    public var calendar: Calendar
    public var restDays: Set<Weekday>
    /// Minutes after midnight for the daily moment (S07).
    public var reminderMinutes: Int
    public var frequency: ReminderFrequency
    public var workouts: [Date]
    /// Day-12 trial reminder, when a trial is running and renews ("always sent").
    public var trialReminder: Date?
    public var landmark: LandmarkSoon?
    public var settings: NotificationSettings
    public var newJourneyName: String?

    public init(calendar: Calendar, restDays: Set<Weekday>, reminderMinutes: Int, frequency: ReminderFrequency, workouts: [Date],
                trialReminder: Date?, landmark: LandmarkSoon?, settings: NotificationSettings, newJourneyName: String?) {
        self.calendar = calendar; self.restDays = restDays; self.reminderMinutes = reminderMinutes; self.frequency = frequency
        self.workouts = workouts; self.trialReminder = trialReminder; self.landmark = landmark; self.settings = settings
        self.newJourneyName = newJourneyName
    }
}

/// One notification to schedule; the app picks the words (phrase bank) when it schedules.
public struct PlannedNotification: Equatable, Sendable {
    public var kind: NotificationKind
    public var fireDate: Date
    /// Values for the phrase: "stop" (landmark), "thisWeek"/"lastWeek" (recap), "journey" (new journey).
    public var values: [String: String]
}

/// Plans the next days of local notifications (tasks 7.1–7.8). At most one a day; never on a day
/// already walked or a planned rest day (except the trial reminder and the Sunday recap); only
/// between 8 AM and 8 PM; after a gap, only two gentle comebacks, then quiet.
public enum NotificationPlanner {
    public static let earliestMinutes = 8 * 60
    public static let latestMinutes = 20 * 60
    public static let recapHour = 17
    public static let comebackDays: Set<Int> = [3, 10]

    public static func plan(input: PlannerInput, now: Date, days: Int) -> [PlannedNotification] {
        let cal = input.calendar
        let walkedDays = Set(input.workouts.map { cal.startOfDay(for: $0) })
        let first = input.workouts.min()
        let last = input.workouts.max()
        let today = cal.startOfDay(for: now)
        let clamped = min(latestMinutes, max(earliestMinutes, input.reminderMinutes))
        var landmarkUsed = false
        var newJourneyUsed = false
        var result: [PlannedNotification] = []

        for offset in 0..<days {
            guard let day = cal.date(byAdding: .day, value: offset, to: today),
                  // Clock time, not minutes after midnight: on a daylight-saving day those are an hour off.
                  let remindAt = cal.date(bySettingHour: clamped / 60, minute: clamped % 60, second: 0, of: day) else { continue }
            var candidates: [PlannedNotification] = []
            let isRest = input.restDays.contains(Weekday(of: day, in: cal))
            let walked = walkedDays.contains(day)
            let canNudge = remindAt > now && !isRest && !walked

            if let trial = input.trialReminder, cal.isDate(trial, inSameDayAs: day), trial > now {
                candidates.append(.init(kind: .trialEnd, fireDate: trial, values: [:]))
            }
            if canNudge, input.settings.walkReminders {
                if let first, let dayAfterFirst = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: first)),
                   day == dayAfterFirst, input.workouts.count == 1 {
                    candidates.append(.init(kind: .dayTwo, fireDate: remindAt, values: [:]))
                }
                if let kind = nudgeKind(on: day, lastWorkout: last, input: input) {
                    if kind == .reminder, let landmark = input.landmark, input.settings.journeyMilestones, !landmarkUsed {
                        landmarkUsed = true
                        candidates.append(.init(kind: .landmark, fireDate: remindAt, values: ["stop": landmark.stopName]))
                    } else {
                        candidates.append(.init(kind: kind, fireDate: remindAt, values: [:]))
                    }
                }
            }
            if let recap = weeklyRecap(on: day, now: now, first: first, input: input) {
                candidates.append(recap)
            }
            if candidates.isEmpty, canNudge, input.settings.newJourneys, !newJourneyUsed, let name = input.newJourneyName {
                newJourneyUsed = true
                candidates.append(.init(kind: .newJourney, fireDate: remindAt, values: ["journey": name]))
            }
            if let winner = candidates.min(by: { $0.kind.priority < $1.kind.priority }) {
                result.append(winner)
            }
        }
        return result
    }

    /// Reminder, comeback or nothing, by planned days since the last walk.
    static func nudgeKind(on day: Date, lastWorkout: Date?, input: PlannerInput) -> NotificationKind? {
        guard let lastWorkout else { return .reminder }
        let gap = plannedDays(from: lastWorkout, to: day, input: input)
        switch input.frequency {
        case .daily:
            if gap < 3 { return .reminder }
            return comebackDays.contains(gap) ? .comeback : nil
        case .quietDays:
            if gap == 3 { return .reminder }
            return gap == 10 ? .comeback : nil
        }
    }

    /// Planned (non-rest) days after the last walk's day, up to and including `day`.
    static func plannedDays(from last: Date, to day: Date, input: PlannerInput) -> Int {
        let cal = input.calendar
        var count = 0
        var cursor = cal.startOfDay(for: last)
        while let next = cal.date(byAdding: .day, value: 1, to: cursor), next <= day {
            cursor = next
            if !input.restDays.contains(Weekday(of: cursor, in: cal)) { count += 1 }
        }
        return count
    }

    /// Sunday 5 PM from the second week, comparing only with the user's own last week, and
    /// only in a week with at least one walk (it never lists missed days).
    static func weeklyRecap(on day: Date, now: Date, first: Date?, input: PlannerInput) -> PlannedNotification? {
        let cal = input.calendar
        guard input.settings.weeklyRecap, Weekday(of: day, in: cal) == .sunday, let first,
              let at = cal.date(bySettingHour: recapHour, minute: 0, second: 0, of: day), at > now,
              let weekStart = cal.date(byAdding: .day, value: -6, to: day),
              let previousStart = cal.date(byAdding: .day, value: -7, to: weekStart),
              cal.startOfDay(for: first) <= previousStart.addingTimeInterval(6 * 86_400) else { return nil }
        let days = Set(input.workouts.map { cal.startOfDay(for: $0) })
        let thisWeek = days.filter { $0 >= weekStart && $0 <= day }.count
        let lastWeek = days.filter { $0 >= previousStart && $0 < weekStart }.count
        guard thisWeek > 0 else { return nil }
        return .init(kind: .weeklyRecap, fireDate: at, values: ["thisWeek": "\(thisWeek)", "lastWeek": "\(lastWeek)"])
    }

    /// Five walks in a row, each started before the reminder time (task 7.6): Today offers fewer reminders.
    public static func offersFewerReminders(workouts: [Date], reminderMinutes: Int, calendar: Calendar) -> Bool {
        let firstOfDay = Dictionary(grouping: workouts) { calendar.startOfDay(for: $0) }.mapValues { $0.min()! }
        let recent = firstOfDay.keys.sorted(by: >).prefix(5)
        guard recent.count == 5 else { return false }
        for (a, b) in zip(recent, recent.dropFirst()) where calendar.dateComponents([.day], from: b, to: a).day != 1 {
            return false
        }
        return recent.allSatisfy { day in
            let time = firstOfDay[day]!
            let minutes = calendar.component(.hour, from: time) * 60 + calendar.component(.minute, from: time)
            return minutes < reminderMinutes
        }
    }
}

public struct PhraseUse: Equatable, Sendable {
    public var phraseID: String
    public var date: Date
    public init(phraseID: String, date: Date) { self.phraseID = phraseID; self.date = date }
}

/// No phrase repeats within 14 days (task 7.4).
public enum PhraseRotation {
    public static let window: TimeInterval = 14 * 86_400

    /// The first phrase not used in the last 14 days, else the one used longest ago.
    public static func next(bank: [String], history: [PhraseUse], now: Date) -> String? {
        let lastUse = Dictionary(history.map { ($0.phraseID, $0.date) }, uniquingKeysWith: max)
        if let fresh = bank.first(where: { id in lastUse[id].map { now.timeIntervalSince($0) >= window } ?? true }) {
            return fresh
        }
        return bank.min { (lastUse[$0] ?? .distantPast) < (lastUse[$1] ?? .distantPast) }
    }
}
