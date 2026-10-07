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
    /// "Rest today" was tapped on today's reminder: today is a rest day (review 02/10/2026).
    var restedToday = false
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
    var isToday = false
}

/// Extras (max 3): short sessions that add minutes to the journey without changing the day.
struct TodayExtra: Equatable, Identifiable {
    var id: String
    var title: String
    var minutes: Int
    var art: Art
    var hasVideo: Bool
    var request: WorkoutRequest
}

/// One choice of "Try something else" (milestone 10).
struct TodaySwapOption: Equatable, Identifiable {
    var id: String
    var title: String
    var art: Art
    var request: WorkoutRequest
    var isLocked: Bool
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
        plannedDay = input.restedToday ? .rest
            : WeeklyPlanner.day(for: input.now, restDays: restDays, entitlement: input.entitlement, calendar: input.calendar)
    }

    var isPro: Bool { input.entitlement.isPro }
    var activeDays: Int { activity.activeDays }

    /// How far the active days are towards the next tree level (0...1), for the ring on Today.
    /// After Tree, towards the next year ring.
    var treeProgress: Double {
        let days = max(0, activeDays)
        guard let next = TreeLevel.thresholds.first(where: { days < $0 }) else {
            let sinceTree = days - (TreeLevel.thresholds.last ?? 0)
            return Double(sinceTree % TreeLevel.ringEvery) / Double(TreeLevel.ringEvery)
        }
        let previous = TreeLevel.thresholds.last(where: { $0 <= days }) ?? 0
        return Double(days - previous) / Double(next - previous)
    }
    var doneToday: Bool { activity.isActive(input.now) }
    /// No session finished yet (she chose "Not yet" on the First Walk's "Up next"): today offers
    /// the First Walk, whatever the day (owner 01/10/2026).
    var isNew: Bool { input.workouts.isEmpty }
    /// The First Walk is set (gentle, seated), so there is nothing to check in for.
    var showsCheckIn: Bool { !doneToday && !isNew }

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

    /// "Your trial has ended · See Pro plans" on the session card: for a week after the trial, not for
    /// ever (Today never offers the plans on every open; app-context, review 02/10/2026).
    var showsTrialEndedNote: Bool {
        guard trialEnded, let ends = input.trialEnds else { return false }
        return input.now < ends.addingTimeInterval(7 * 86_400)
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
        if isNew, let request {
            return TodaySession(kind: .planned, title: String(localized: "Your first walk · \(minutes(of: request)) min"), main: .walk)
        }
        // "Rest today" on the reminder wins over a gentle restart too (review 02/10/2026).
        if input.restedToday { return TodaySession(kind: .rest, title: String(localized: "Rest day")) }
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
        case .done: String(localized: "Today counts as an active day.")
        case .rest: String(localized: "Rest days are part of the plan.")
        default: levelLine
        }
    }

    var isSeatedWalk: Bool { isNew || ((plannedDay.main == .walk || plannedDay.main == .longWalk) && level == .seated) }

    /// What the level means for today's kind of session (clarity review D6: "Seated walk" puzzled).
    private var levelLine: String {
        if isNew { return String(localized: "Seated · march in your chair") }
        return switch plannedDay.main {
        case .chair: String(localized: "With your chair")
        case .stretch: String(localized: "Gentle stretches")
        default:
            switch level {
            case .seated: String(localized: "Seated · march in your chair")
            case .inPlace: String(localized: "In place · march on the spot")
            case .pad: String(localized: "On your walking pad")
            }
        }
    }

    /// Done for today, but the planned session is still there for anyone who wants it (owner
    /// 30/09/2026: any session counts; the planned one stays open, no nagging).
    var stillOpenRequest: WorkoutRequest? {
        guard doneToday, !plannedDay.isRest else { return nil }
        return request
    }

    var request: WorkoutRequest? {
        if isNew { return .firstWalk(limits: input.limits) }
        if input.restedToday { return nil }
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
        // Not before a first session: Apple Health is asked after it (S16), never before.
        if !input.healthConnected, !isNew { return .connectHealth }
        if input.suggestFewerReminders { return .fewerReminders }
        return nil
    }

    /// "Try something else": the other kinds and five gentle minutes, built with her limits. It
    /// replaces today's session (any finished session makes the day active). None once done or on
    /// a rest day.
    var swapOptions: [TodaySwapOption] {
        switch session.kind {
        case .done, .rest: return []
        case .planned, .gentleRestart, .freeWalk: break
        }
        let planned: PlannedDay.Main = restart != nil ? .walk : (plannedDay.main ?? .walk)
        return SessionCatalog.swapOptions(planned: planned).map { preset in
            let request = preset.request(limits: input.limits, rotationIndex: activeDays)
            let minutes = minutes(of: request)
            let title = preset.id == SessionCatalog.justFiveMinutesID
                ? String(localized: "Just \(minutes) minutes: a gentle seated walk")
                : String(localized: "\(String(localized: preset.title)) · \(minutes) min")
            return TodaySwapOption(id: preset.id, title: title, art: preset.art, request: request,
                                   isLocked: !isPro && !preset.isFree)
        }
    }

    /// The "Short extras" of All sessions (same recipes, paintings and Video marks), so Today and
    /// All sessions never disagree (review U12).
    var extras: [TodayExtra] {
        let filmed = SessionVideo.filmed(in: content)
        return SessionCatalog.presets(in: .extras).map { preset in
            let request = preset.request(limits: input.limits, rotationIndex: activeDays + 1)
            return TodayExtra(id: preset.id, title: String(localized: preset.title), minutes: minutes(of: request),
                              art: preset.art, hasVideo: SessionVideo.has(request, filmed: filmed, content: content),
                              request: request)
        }
    }

    var week: [TodayDay] {
        let plan = WeeklyPlanner.week(restDays: restDays, entitlement: input.entitlement)
        return activity.week(containing: input.now).days.map { day in
            TodayDay(date: day.date, mark: day.mark, main: plan[Weekday(of: day.date, in: input.calendar)]?.main,
                     isToday: input.calendar.isDate(day.date, inSameDayAs: input.now))
        }
    }

    /// "4 of 5 active days so far · 2 rest days are part of the plan": a soft weekly target that is
    /// never lost (owner S3, 02/10/2026, past the "count up only" rule). Shown once a day is done
    /// and while the count fits the plan; otherwise the plain count up.
    var weekLine: String {
        let active = activity.week(containing: input.now).activeDays
        let planned = 7 - restDays.count
        if active > 0, active <= planned {
            return String(localized: "\(active) of \(planned) active days so far · \(restDays.count) rest days are part of the plan")
        }
        return String(localized: "\(Plural.activeDays(active)) this week · \(restDays.count) rest days are part of the plan")
    }

    private var journey: Journey? { content.journeys.first { $0.id == input.journeyID } }

    var journeyID: String { input.journeyID }

    var journeyLine: String {
        guard let journey else { return "" }
        let limit = JourneyAccess.limitMile(for: journey, entitlement: input.entitlement)
        let miles = JourneyAccess.routeMiles(total: input.journeyMiles, limit: limit)
        return JourneyText.progress(routeMiles: miles, journey: journey, limit: limit)
    }

    /// "New York City": the card says which journey the miles belong to (clarity review D7).
    var journeyTitle: String { journey?.title ?? "" }

    /// The bar stops where the words do: at the end of the free leg on a paid route (review 02/10/2026).
    var journeyProgress: Double {
        guard let journey, let last = journey.stops.last, last.mile > 0 else { return 0 }
        let limit = JourneyAccess.limitMile(for: journey, entitlement: input.entitlement)
        return min(1, JourneyAccess.routeMiles(total: input.journeyMiles, limit: limit) / last.mile)
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

/// How journey progress reads everywhere (Today, Complete): "1.8 of 5 mi · 0.4 mi to Times Square";
/// "You made it to Brooklyn Bridge!" at the end (clarity review D17).
enum JourneyText {
    static func progress(routeMiles: Double, journey: Journey, limit: Double?) -> String {
        guard let last = journey.stops.last else { return "" }
        if routeMiles >= last.mile - 1e-9 { return String(localized: "You made it to \(last.name)!") }
        let done = DistanceText.number(miles: routeMiles)
        let total = CompleteContent.miles(last.mile, trimmed: true)
        guard let next = journey.stops.first(where: { $0.mile > routeMiles + 1e-9 }) else {
            return String(localized: "\(done) of \(total)")
        }
        // Past the free leg the next stop is Pro: say where she is instead.
        if let limit, next.mile > limit + 1e-9 {
            return String(localized: "\(done) of \(total) · free leg walked")
        }
        return String(localized: "\(done) of \(total) · \(CompleteContent.miles(next.mile - routeMiles)) to \(next.name)")
    }
}
