import Foundation
import Observation
import GentleWalkCore

/// Everything Today needs, read once from the store (tests build it by hand).
struct TodayInput: Equatable {
    struct Workout: Equatable {
        var date: Date
        var feeling: Feeling?
        var breakCount: Int
        var level: WalkLevel
    }

    var now: Date
    var calendar: Calendar
    var name: String?
    var restDays: Set<Weekday>
    var limits: Set<BodyLimit>
    var level: WalkLevel
    var entitlement: Entitlement
    /// End of the free trial if one was ever started (for "Your trial has ended").
    var trialEnds: Date?
    var workouts: [Workout]
    var pains: [PainReportSnapshot]
    var healthConnected: Bool
    /// Habit detected (task 7.6): offer fewer reminders.
    var suggestFewerReminders: Bool
    var journeyID: String
    var journeyMiles: Double
}

/// At most one of these shows at a time, in this order of priority.
enum TodaySpecialCard: Equatable, Sendable {
    case pain(area: BodyArea)
    case shorter
    case movedDown(to: WalkLevel)
    case connectHealth
    case fewerReminders
}

struct TodaySession: Equatable {
    enum Kind: Equatable { case planned, done, rest, gentleRestart, freeWalk }
    var kind: Kind
    var title: String
    /// What the day holds, for the card's icon.
    var main: PlannedDay.Main? = nil
}

struct TodayDay: Equatable, Identifiable {
    var id: Date { date }
    var date: Date
    var mark: ActivityCalendar.Mark
    var main: PlannedDay.Main?
}

/// Extras (max 3): short sessions that add minutes to the journey without changing the day.
struct TodayExtra: Equatable, Identifiable {
    var id: String
    var title: String
    var symbol: String
    var request: WorkoutRequest
}

/// S17 Today (task 6.2). Works everything out once from `TodayInput`; only the check-in changes it.
@Observable @MainActor final class TodayModel {
    private(set) var checkedIn: CheckIn?
    private(set) var intensity: Intensity = .steady

    @ObservationIgnored private let input: TodayInput
    @ObservationIgnored private let content: ContentBundle
    @ObservationIgnored private let activity: ActivityCalendar
    @ObservationIgnored private let restDays: Set<Weekday>
    @ObservationIgnored private let adaptation: AdaptationResult
    @ObservationIgnored private let restart: WelcomeBackState?
    @ObservationIgnored private let painAlert: PainAlert?
    @ObservationIgnored private let plannedDay: PlannedDay

    init(input: TodayInput, content: ContentBundle) {
        self.input = input
        self.content = content
        restDays = RestDays.effective(chosen: input.restDays, entitlement: input.entitlement)
        activity = ActivityCalendar(records: input.workouts.map(\.date), restDays: restDays, calendar: input.calendar)
        let history = input.workouts.sorted { $0.date < $1.date }
            .map { SessionFeedback(level: $0.level, feeling: $0.feeling, breakCount: $0.breakCount) }
        adaptation = Adaptation.next(level: input.level, history: history)
        let done = activity.isActive(input.now)
        restart = done ? nil : WelcomeBack.state(lastWorkout: input.workouts.map(\.date).max(), restDays: restDays,
                                                 now: input.now, calendar: input.calendar)
        painAlert = PainRules.evaluate(reports: input.pains, now: input.now)
        plannedDay = WeeklyPlanner.day(for: input.now, restDays: restDays, entitlement: input.entitlement, calendar: input.calendar)
    }

    var isPro: Bool { input.entitlement.isPro }
    var activeDays: Int { activity.activeDays }
    var doneToday: Bool { activity.isActive(input.now) }
    var showsCheckIn: Bool { !doneToday }

    var greeting: String {
        let hour = input.calendar.component(.hour, from: input.now)
        switch (hour, input.name) {
        case (..<12, let name?): return String(localized: "Good morning, \(name)")
        case (..<12, nil): return String(localized: "Good morning")
        case (12..<17, let name?): return String(localized: "Good afternoon, \(name)")
        case (12..<17, nil): return String(localized: "Good afternoon")
        case (_, let name?): return String(localized: "Good evening, \(name)")
        case (_, nil): return String(localized: "Good evening")
        }
    }

    func checkIn(_ value: CheckIn) {
        checkedIn = value
        intensity = Intensity(checkIn: value)
    }

    var trialEnded: Bool {
        guard !isPro, let ends = input.trialEnds else { return false }
        return ends < input.now
    }

    /// Day 10 of the trial until billing (I1): shown whether or not notifications are allowed.
    var trialEndingDate: Date? {
        guard case .trial(let ends) = input.entitlement else { return nil }
        let timeline = TrialTimeline(start: ends.addingTimeInterval(-14 * 86_400), trialLength: 14, calendar: input.calendar)
        return timeline.bannerWindow.contains(input.now) ? ends : nil
    }

    var welcomeBack: String? {
        guard restart != nil else { return nil }
        if let name = input.name { return String(localized: "Welcome back, \(name). Your journey is right where you left it.") }
        return String(localized: "Welcome back. Your journey is right where you left it.")
    }

    /// The level today: seated after repeated pain in one area, otherwise the adapted level.
    private var level: WalkLevel { painAlert != nil ? .seated : adaptation.level }

    var session: TodaySession {
        if doneToday { return TodaySession(kind: .done, title: String(localized: "Done for today")) }
        if case .gentleRestart(let minutes)? = restart {
            return TodaySession(kind: .gentleRestart, title: String(localized: "Gentle restart · \(minutes) min"))
        }
        if plannedDay.isRest { return TodaySession(kind: .rest, title: String(localized: "Rest day")) }
        let minutes = request.map(minutes(of:)) ?? 0
        if trialEnded { return TodaySession(kind: .freeWalk, title: String(localized: "Free walk of the day · \(minutes) min")) }
        return TodaySession(kind: .planned, title: title(for: plannedDay.main, minutes: minutes), main: plannedDay.main)
    }

    var sessionDetail: String? {
        switch session.kind {
        case .done: String(localized: "Extras still add to your journey.")
        case .rest: String(localized: "Rest days are part of the plan.")
        default: String(localized: level.title)
        }
    }

    var request: WorkoutRequest? {
        if case .gentleRestart? = restart {
            return WorkoutRequest(day: PlannedDay(main: .walk, chairMoves: 0, cooldown: false), level: .seated, intensity: .gentle,
                                  place: .indoors, limits: input.limits, rotationIndex: activeDays)
        }
        guard !plannedDay.isRest else { return nil }
        return WorkoutRequest(day: plannedDay, level: level, intensity: intensity, place: .indoors, limits: input.limits,
                              rotationIndex: activeDays, minutesDelta: adaptation.minutesDelta)
    }

    var specialCard: TodaySpecialCard? {
        if let painAlert { return .pain(area: painAlert.area) }
        if adaptation.minutesDelta < 0 { return .shorter }
        if case .movedDown(let to)? = adaptation.card { return .movedDown(to: to) }
        if !input.healthConnected { return .connectHealth }
        if input.suggestFewerReminders { return .fewerReminders }
        return nil
    }

    var extras: [TodayExtra] {
        let walk = WorkoutRequest(day: PlannedDay(main: .walk, chairMoves: 0, cooldown: false), level: .seated, intensity: .gentle,
                                  place: .indoors, limits: input.limits, rotationIndex: activeDays + 1)
        let stretch = WorkoutRequest(day: PlannedDay(main: .stretch, chairMoves: 0, cooldown: false), level: .seated,
                                     intensity: .gentle, place: .indoors, limits: input.limits.union([.standingIsHard]),
                                     rotationIndex: activeDays + 1)
        let balance = WorkoutRequest(day: PlannedDay(main: .chair, chairMoves: 0, cooldown: false), level: .seated,
                                     intensity: .gentle, place: .indoors, limits: input.limits, rotationIndex: 5)
        return [
            TodayExtra(id: "walk", title: String(localized: "Commercial break walk · \(minutes(of: walk)) min"), symbol: "tv", request: walk),
            TodayExtra(id: "stretch", title: String(localized: "Morning stretch · \(minutes(of: stretch)) min"), symbol: "sun.max", request: stretch),
            TodayExtra(id: "balance", title: String(localized: "Balance · \(minutes(of: balance)) min"), symbol: "figure.stand", request: balance),
        ]
    }

    var week: [TodayDay] {
        let plan = WeeklyPlanner.week(restDays: restDays, entitlement: input.entitlement)
        return activity.week(containing: input.now).days.map { day in
            TodayDay(date: day.date, mark: day.mark, main: plan[Weekday(of: day.date, in: input.calendar)]?.main)
        }
    }

    var weekLine: String {
        let active = activity.week(containing: input.now).activeDays
        return String(localized: "\(Plural.activeDays(active)) this week · \(restDays.count) rest days are part of the plan")
    }

    private var journey: Journey? { content.journeys.first { $0.id == input.journeyID } }

    var journeyLine: String {
        guard let journey, let last = journey.stops.last else { return "" }
        let limit = JourneyAccess.limitMile(for: journey, entitlement: input.entitlement)
        let miles = JourneyAccess.routeMiles(total: input.journeyMiles, limit: limit)
        let done = miles.formatted(.number.precision(.fractionLength(0...1)))
        let total = Measurement(value: last.mile, unit: UnitLength.miles)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0...1))))
        return String(localized: "\(done) of \(total) to \(last.name)")
    }

    var journeyProgress: Double {
        guard let last = journey?.stops.last, last.mile > 0 else { return 0 }
        return min(1, input.journeyMiles / last.mile)
    }

    private func minutes(of request: WorkoutRequest) -> Int {
        let seconds = (try? request.plan(content: content).totalSeconds) ?? 0
        return max(1, Int((Double(seconds) / 60).rounded()))
    }

    private func title(for main: PlannedDay.Main?, minutes: Int) -> String {
        switch main {
        case .chair: return String(localized: "Chair moves · \(minutes) min")
        case .stretch: return String(localized: "Gentle stretch · \(minutes) min")
        default:
            switch intensity {
            case .gentle: return String(localized: "Gentle walk · \(minutes) min")
            case .steady: return String(localized: "Steady walk · \(minutes) min")
            case .strong: return String(localized: "Strong walk · \(minutes) min")
            }
        }
    }
}
