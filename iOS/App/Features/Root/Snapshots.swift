import Foundation
import GentleWalkCore

/// Where the user is on the current journey, worked out once per reload.
struct JourneySnapshot: Equatable {
    var journeyID: String
    var journey: Journey?
    /// All miles walked on this route (free users keep counting past a locked stop).
    var totalMiles: Double
    /// Miles shown on the map: capped at a locked stop.
    var routeMiles: Double
    var unlocked: Set<String>
    var completedJourneys: Set<String>
    var nextStop: Journey.Stop?
    var milesToNext: Double
    /// Free user on a paid route who reached its first postcard (S18 "Keep going to …").
    var isLockedAhead: Bool
    /// When each postcard was opened, for "Reached Sep 28" on the route list.
    var openedOn: [String: Date] = [:]
    /// Free plan on a paid route: stops past this mile are locked (nil when nothing is locked).
    var limitMile: Double?

    /// How a stop reads on the map and the route list (Journey redesign, 29/09/2026).
    enum StopStatus: Equatable {
        case reached(on: Date?)
        case next(milesToGo: Double)
        case ahead
        case locked
    }

    func status(of stop: Journey.Stop) -> StopStatus {
        if unlocked.contains(stop.id) { return .reached(on: openedOn[stop.id]) }
        if let limitMile, stop.mile > limitMile + 1e-9 { return .locked }
        if stop.id == nextStop?.id { return .next(milesToGo: milesToNext) }
        return .ahead
    }

    static let empty = JourneySnapshot(journeyID: "jr.ny", journey: nil, totalMiles: 0, routeMiles: 0, unlocked: [],
                                       completedJourneys: [], nextStop: nil, milesToNext: 0, isLockedAhead: false)

    /// About one session of walking: the next postcard is "one walk away" within this.
    static let oneSessionMiles = 0.5

    init(journeyID: String, journey: Journey?, totalMiles: Double, routeMiles: Double, unlocked: Set<String>,
         completedJourneys: Set<String>, nextStop: Journey.Stop?, milesToNext: Double, isLockedAhead: Bool,
         openedOn: [String: Date] = [:], limitMile: Double? = nil) {
        self.journeyID = journeyID; self.journey = journey; self.totalMiles = totalMiles; self.routeMiles = routeMiles
        self.unlocked = unlocked; self.completedJourneys = completedJourneys; self.nextStop = nextStop
        self.milesToNext = milesToNext; self.isLockedAhead = isLockedAhead
        self.openedOn = openedOn; self.limitMile = limitMile
    }

    init(states: [JourneyState], unlocks: [PostcardUnlock], content: ContentBundle, entitlement: Entitlement) {
        let current = states.first(where: \.isCurrent)
        let id = current?.journeyID ?? "jr.ny"
        let found = content.journeys.first { $0.id == id }
        let total = current?.miles ?? 0
        let mine = unlocks.filter { $0.journeyID == id }
        let opened = Set(mine.map(\.stopID))
        openedOn = Dictionary(mine.map { ($0.stopID, $0.unlockedAt) }, uniquingKeysWith: min)
        journeyID = id
        journey = found
        totalMiles = total
        completedJourneys = Set(states.filter { $0.completedAt != nil }.map(\.journeyID))
        unlocked = opened
        guard let found else {
            routeMiles = 0; nextStop = nil; milesToNext = 0; isLockedAhead = false
            return
        }
        let limit = JourneyAccess.limitMile(for: found, entitlement: entitlement)
        limitMile = limit
        let shown = JourneyAccess.routeMiles(total: total, limit: limit)
        // Next stop: the first postcard not opened yet (a locked route's first stop is already open).
        let next = found.stops.first { !opened.contains($0.id) }
        routeMiles = shown
        nextStop = next
        milesToNext = next.map { max(0, $0.mile - shown) } ?? 0
        // Locked once the free first leg is walked (owner 30/09/2026), not before.
        isLockedAhead = limit.map { next != nil && shown >= $0 - 1e-9 } ?? false
    }

    var landmarkSoon: LandmarkSoon? {
        guard let nextStop, !isLockedAhead, milesToNext <= Self.oneSessionMiles else { return nil }
        return LandmarkSoon(stopName: nextStop.name)
    }

    var isComplete: Bool { completedJourneys.contains(journeyID) }
}

/// One 2-week self-check on the Progress chart.
struct SelfCheckPoint: Equatable, Identifiable {
    var id: UUID
    var date: Date
    var count: Int
    var usedHands: Bool
    /// Program week when it was done (0 = the first check).
    var week: Int
}

/// What Progress (S19) shows.
struct ProgressSnapshot: Equatable {
    var activeDays: Int
    var activeDates: Set<Date>
    var restDays: Set<Weekday>
    /// 2-week self-checks, oldest first (steady program task 4.10; replaces "most sit-to-stands in one
    /// session", which depended on the session she was given).
    var selfChecks: [SelfCheckPoint]
    /// Longest walk with no Break, in minutes.
    var longestWalkMinutes: Int?
    var checkedWins: Set<String>
    /// Every finished session, newest first (history, owner 01/10/2026).
    var sessions: [SessionHistoryItem]
    /// Pro: today's hands level per balance exercise (`SupportLadder`); empty for free.
    var supportLevels: [String: SupportLevel] = [:]
    /// "Your results" (P8, plan 4.10).
    var results = ResultsSummary.empty
    /// Her weekly check-in answers, newest first (P6).
    var weeklyNotes: [WeeklyNote] = []

    static let empty = ProgressSnapshot(activeDays: 0, activeDates: [], restDays: [], selfChecks: [], longestWalkMinutes: nil,
                                        checkedWins: [])

    init(activeDays: Int, activeDates: Set<Date>, restDays: Set<Weekday>, selfChecks: [SelfCheckPoint], longestWalkMinutes: Int?,
         checkedWins: Set<String>, sessions: [SessionHistoryItem] = [], supportLevels: [String: SupportLevel] = [:]) {
        self.activeDays = activeDays; self.activeDates = activeDates; self.restDays = restDays; self.selfChecks = selfChecks
        self.longestWalkMinutes = longestWalkMinutes; self.checkedWins = checkedWins; self.sessions = sessions
        self.supportLevels = supportLevels
    }

    init(records: [WorkoutRecord], wins: [EverydayWin], checks: [SelfCheckRecord] = [], supportLevels: [String: SupportLevel] = [:],
         restDays: Set<Weekday>, calendar: Calendar, now: Date) {
        let activity = ActivityCalendar(records: records.map(\.date), restDays: restDays, calendar: calendar)
        activeDays = activity.activeDays
        activeDates = Set(records.map { calendar.startOfDay(for: $0.date) })
        self.restDays = restDays
        selfChecks = checks.sorted { $0.date < $1.date }
            .map { SelfCheckPoint(id: $0.id, date: $0.date, count: $0.count, usedHands: $0.usedHands, week: $0.week) }
        let walks = records.filter { ($0.kind == "walk" || $0.kind == "firstWalk") && $0.breakCount == 0 }
        longestWalkMinutes = walks.map(\.activeSeconds).max().map { max(1, Int((Double($0) / 60).rounded())) }
        checkedWins = Set(wins.map(\.key))
        sessions = SessionHistoryItem.list(records)
        self.supportLevels = supportLevels
        let moved = records.map {
            MovedSession(date: $0.date, seconds: $0.activeSeconds,
                         unbrokenWalk: ($0.kind == "walk" || $0.kind == "firstWalk") && $0.breakCount == 0)
        }
        results = ResultsSummary(sessions: moved, checks: selfChecks, longestWalk: longestWalkMinutes, now: now, calendar: calendar)
    }

    var tree: TreeLevel { TreeLevel.level(activeDays: activeDays) }
    var daysToNext: Int { TreeLevel.daysToNext(activeDays: activeDays) }
    var rings: Int { TreeLevel.rings(activeDays: activeDays) }

    /// Change since the first check done the same way as the latest; nil with nothing to compare.
    var selfCheckDelta: SelfCheckDelta? {
        guard let latest = selfChecks.last else { return nil }
        let result = { (point: SelfCheckPoint) in SelfCheckResult(date: point.date, count: point.count, usedHands: point.usedHands) }
        return SelfCheckComparison.delta(latest: result(latest), history: selfChecks.map(result))
    }
}
