import Foundation
import GentleWalkCore

/// What her answers and habits change on Today (plan 08/10/2026 milestone 4), worked out once from
/// `TodayInput`: the check-in chosen in advance and why (P2, P6, P9), how much shorter or longer today
/// is, last week's note (P6), a move set aside (P3) and the coach's history line (P7).
struct TodayPersonalisation: Equatable {
    /// Why a check-in is chosen in advance: each reason says so in one line under the check-in.
    enum CheckInReason: Equatable { case lastTwoHard, lastTwoEasy, hardWeek, easyWeek, gentleStart, checkDown }

    var suggestedCheckIn: CheckIn?
    var reason: CheckInReason?
    /// Negative: shorter; positive: longer (a week she found easier). Shorter reasons never add up.
    var minutesDelta: Int
    /// Two Breaks last time or a habit of stopping early: the "a little shorter" card.
    var showsShorterCard: Bool
    var lastWeekChip: BetterChip?
    /// A move set aside in the last few days (P3), by name.
    var setAsideName: String?

    /// "How active are you now?" said "Mostly sitting": gentle and shorter at first (plan 4.2).
    static let gentleStartSessions = 10
    static let shorterStartDays = 14
    /// A move set aside shows its Today card for this long.
    static let setAsideCardDays = 3

    init(input: TodayInput, content: ContentBundle) {
        let history = input.workouts.sorted { $0.date < $1.date }.map {
            SessionFeedback(level: $0.level, feeling: $0.feeling, breakCount: $0.breakCount, date: $0.date)
        }
        let adaptation = Adaptation.next(state: LevelState(level: input.level, changedAt: input.levelChangedAt), history: history)
        let week = WeeklyCheckIn.effects(of: WeeklyCheckIn.current(notes: input.weeklyNotes, now: input.now, calendar: input.calendar))
        let firstWorkout = input.workouts.map(\.date).min()
        let mostlySits = input.activity == .mostlySit
        let gentleStart = mostlySits && input.workouts.count < Self.gentleStartSessions
        let shorterStart = mostlySits && firstWorkout.map {
            input.now.timeIntervalSince($0) < Double(Self.shorterStartDays) * 86_400
        } ?? false

        // The most recent signal wins: her last answers, then her last check, then last week, then the start.
        if let suggested = adaptation.suggestedCheckIn {
            suggestedCheckIn = suggested
            reason = suggested == .achy ? .lastTwoHard : .lastTwoEasy
        } else if input.checkTrend == .down {
            suggestedCheckIn = .okay
            reason = .checkDown
        } else if let weekly = week.defaultCheckIn {
            suggestedCheckIn = weekly
            reason = weekly == .achy ? .hardWeek : .easyWeek
        } else if gentleStart {
            suggestedCheckIn = .achy
            reason = .gentleStart
        } else {
            suggestedCheckIn = nil
            reason = nil
        }

        let lastBreaks = input.workouts.max { $0.date < $1.date }.map { $0.breakCount >= Adaptation.breaksForShorter } ?? false
        let habitShorter = input.lengthSignal == .shorter
        let cut = [adaptation.minutesDelta, min(0, week.minutesDelta), habitShorter ? -Adaptation.shorterByMinutes : 0,
                   shorterStart ? -Adaptation.shorterByMinutes : 0].min() ?? 0
        minutesDelta = cut < 0 ? cut : max(0, week.minutesDelta)
        showsShorterCard = lastBreaks || habitShorter

        lastWeekChip = WeeklyCheckIn.lastWeekChip(notes: input.weeklyNotes, now: input.now, calendar: input.calendar)
        let recent = input.exerciseRules.setAside.filter { _, back in
            let began = back.addingTimeInterval(-Double(PainRules.setAsideDays) * 86_400)
            return input.now.timeIntervalSince(began) < Double(Self.setAsideCardDays) * 86_400
        }
        setAsideName = recent.keys.sorted().first.flatMap { id in content.exercises.first { $0.id == id }?.name }
    }

    /// One line under the check-in that says why it is chosen; nil when nothing is chosen in advance.
    var checkInNote: String? {
        switch reason {
        case .lastTwoHard?: String(localized: "After last time, we'll keep it gentle. Change it if you like.")
        case .lastTwoEasy?: String(localized: "After last time, Great is picked. Change it if you like.")
        case .hardWeek?: String(localized: "After last week, a little shorter this week.")
        case .easyWeek?: String(localized: "After last week, a little longer this week.")
        case .gentleStart?: String(localized: "A gentle start for your first sessions. Change it if you like.")
        case .checkDown?, nil: nil
        }
    }

    /// "Last week you said stairs felt a bit better. Let's keep the leg work going." (Monday, Tuesday).
    var lastWeekLine: String? {
        switch lastWeekChip {
        case .gettingUp?: String(localized: "Last week you said getting up from a chair felt a bit better. Let's keep the leg work going.")
        case .stairs?: String(localized: "Last week you said stairs felt a bit better. Let's keep the leg work going.")
        case .morningStiffness?: String(localized: "Last week you said mornings felt a bit less stiff. Let's keep moving gently.")
        case .energy?: String(localized: "Last week you said your energy felt a bit better. Let's keep it going.")
        case .sleep?: String(localized: "Last week you said sleep felt a bit better. Let's keep it going.")
        case .walkingOutside?: String(localized: "Last week you said walking outside felt a bit better. Let's keep it going.")
        case .nothingYet?, nil: nil
        }
    }

    /// The one history line for today's planned session (P7).
    static func historyLine(input: TodayInput, isWalk: Bool, doneToday: Bool) -> HistoryLine? {
        let calendar = input.calendar
        var programWeek: Int?
        var firstOfWeek = false
        if let round = input.program, input.programFinishedAt == nil,
           case .week(let week, _) = ProgramCalendar.position(round, on: input.now, calendar: calendar) {
            programWeek = week
            let days = max(0, (calendar.dateComponents([.day], from: calendar.startOfDay(for: round.start),
                                                       to: calendar.startOfDay(for: input.now)).day ?? 0) - round.pausedDays)
            let weekBegan = calendar.date(byAdding: .day, value: -(days % 7), to: calendar.startOfDay(for: input.now)) ?? input.now
            firstOfWeek = !input.workouts.contains { $0.date >= weekBegan }
        }
        let thisWeek = calendar.dateInterval(of: .weekOfYear, for: input.now)
        let inWeek = input.workouts.filter { thisWeek?.contains($0.date) ?? false }
        let walks = inWeek.filter { $0.kind == "walk" || $0.kind == "firstWalk" }.count + (isWalk ? 1 : 0)
        let days = Set(inWeek.map { calendar.startOfDay(for: $0.date) }).count + (doneToday ? 0 : 1)
        return HistoryLine.pick(programWeek: programWeek, firstOfProgramWeek: firstOfWeek, isWalk: isWalk, walkNumber: walks,
                                activeDays: days)
    }
}
