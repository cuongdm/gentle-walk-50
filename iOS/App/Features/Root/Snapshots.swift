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
        isLockedAhead = limit != nil && next != nil && !opened.isEmpty
    }

    var landmarkSoon: LandmarkSoon? {
        guard let nextStop, !isLockedAhead, milesToNext <= Self.oneSessionMiles else { return nil }
        return LandmarkSoon(stopName: nextStop.name)
    }

    var isComplete: Bool { completedJourneys.contains(journeyID) }
}

/// What Progress (S19) shows.
struct ProgressSnapshot: Equatable {
    struct WeekBar: Equatable, Identifiable {
        var id: Date { weekStart }
        var weekStart: Date
        var best: Int
    }

    var activeDays: Int
    var activeDates: Set<Date>
    var restDays: Set<Weekday>
    var sitToStand: [WeekBar]
    /// Longest walk with no Break, in minutes.
    var longestWalkMinutes: Int?
    var checkedWins: Set<String>

    static let empty = ProgressSnapshot(activeDays: 0, activeDates: [], restDays: [], sitToStand: [], longestWalkMinutes: nil,
                                        checkedWins: [])

    init(activeDays: Int, activeDates: Set<Date>, restDays: Set<Weekday>, sitToStand: [WeekBar], longestWalkMinutes: Int?,
         checkedWins: Set<String>) {
        self.activeDays = activeDays; self.activeDates = activeDates; self.restDays = restDays; self.sitToStand = sitToStand
        self.longestWalkMinutes = longestWalkMinutes; self.checkedWins = checkedWins
    }

    init(records: [WorkoutRecord], wins: [EverydayWin], restDays: Set<Weekday>, calendar: Calendar, now: Date) {
        let activity = ActivityCalendar(records: records.map(\.date), restDays: restDays, calendar: calendar)
        activeDays = activity.activeDays
        activeDates = Set(records.map { calendar.startOfDay(for: $0.date) })
        self.restDays = restDays
        var bars: [WeekBar] = []
        for back in (0..<6).reversed() {
            guard let date = calendar.date(byAdding: .weekOfYear, value: -back, to: now),
                  let week = calendar.dateInterval(of: .weekOfYear, for: date) else { continue }
            let best = records.filter { week.contains($0.date) }.compactMap(\.sitToStandCount).max() ?? 0
            bars.append(WeekBar(weekStart: week.start, best: best))
        }
        sitToStand = bars
        let walks = records.filter { ($0.kind == "walk" || $0.kind == "firstWalk") && $0.breakCount == 0 }
        longestWalkMinutes = walks.map(\.activeSeconds).max().map { max(1, Int((Double($0) / 60).rounded())) }
        checkedWins = Set(wins.map(\.key))
    }

    var tree: TreeLevel { TreeLevel.level(activeDays: activeDays) }
    var daysToNext: Int { TreeLevel.daysToNext(activeDays: activeDays) }
    var rings: Int { TreeLevel.rings(activeDays: activeDays) }
}
