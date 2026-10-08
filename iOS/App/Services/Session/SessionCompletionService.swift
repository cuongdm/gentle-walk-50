import Foundation
import SwiftData
import GentleWalkCore

enum WorkoutPlace: String, Codable, CaseIterable, Sendable { case indoors, outdoors, pad }

/// What a finished (or stopped) session did, handed over by the player screens.
struct SessionSummary: Equatable, Sendable {
    var date: Date
    var kind: SessionTemplate.Kind
    var level: WalkLevel
    var intensity: Intensity
    var place: WorkoutPlace
    var activeSeconds: Int
    var breakCount: Int
    var outdoorMiles: Double? = nil
    var sitToStandCount: Int? = nil
    /// Outdoor route for Apple Health (never shared).
    var route: [RoutePoint] = []
}

/// Writes the workout to Apple Health (task 6.7).
@MainActor protocol WorkoutHealthWriting: AnyObject {
    func saveWorkout(_ summary: SessionSummary) async
}

/// Re-plans local notifications after anything that changes them (task 7.9).
@MainActor protocol NotificationRescheduling: AnyObject {
    func reschedule() async
}

/// What S15 Complete shows.
struct CompletionResult: Equatable, Sendable {
    var recordID = UUID()
    var sessionMiles = 0.0
    var journeyID = ""
    var routeMiles = 0.0
    var unlockedStops: [Journey.Stop] = []
    var nextStop: Journey.Stop?
    var milesToNext = 0.0
    var journeyComplete = false
    /// Free user on a paid route who walked its free first leg.
    var isLockedAhead = false
    /// Free user on a paid route: the last mile of the free leg.
    var routeLimit: Double?
    var activeDays = 0
    /// Set when this session reached a new tree level.
    var reachedLevel: TreeLevel?
    var isFirstWorkout = false
    /// Why this Complete is special, and its words (plan 08/10/2026 task 3.6); nil only in old callers.
    var cheerContext: CheerContext?
    var cheer: Cheer?
    /// "Session 13 · done": how many sessions she has finished, this one included.
    var sessionNumber = 0
}

/// Saves a session and moves everything that depends on it (task 4.11): the workout record, the
/// journey and its postcards, active days and tree level, Apple Health and notifications.
@MainActor final class SessionCompletionService {
    private let context: ModelContext
    private let content: ContentBundle
    private let entitlement: () -> Entitlement
    private let health: WorkoutHealthWriting
    private let notifications: NotificationRescheduling
    /// Her current walking level; "How did that feel?" can change it (plan 08/10/2026 task 0.3).
    private let levels: WalkLevelStore?
    /// The cheer shown last, so the next one differs (task 3.6).
    private let cheers: CheerMemoryStore?
    private let calendar: Calendar

    init(context: ModelContext, content: ContentBundle, entitlement: @escaping () -> Entitlement,
         health: WorkoutHealthWriting, notifications: NotificationRescheduling, levels: WalkLevelStore? = nil,
         cheers: CheerMemoryStore? = nil, calendar: Calendar = .current) {
        self.context = context
        self.content = content
        self.entitlement = entitlement
        self.health = health
        self.notifications = notifications
        self.levels = levels
        self.cheers = cheers
        self.calendar = calendar
    }

    func complete(_ summary: SessionSummary) async throws -> CompletionResult {
        let previous = try context.fetch(FetchDescriptor<WorkoutRecord>())
        let daysBefore = ActivityCalendar(records: previous.map(\.date), restDays: [], calendar: calendar).activeDays

        let miles = ActivityDistance.miles(activeMinutes: Double(summary.activeSeconds) / 60, outdoorMiles: summary.outdoorMiles)
        let record = WorkoutRecord(
            date: summary.date, kind: summary.kind.rawValue, level: summary.level.rawValue,
            intensity: summary.intensity.rawValue, place: summary.place.rawValue, activeSeconds: summary.activeSeconds,
            journeyMiles: miles, outdoorMiles: summary.outdoorMiles, breakCount: summary.breakCount,
            sitToStandCount: summary.sitToStandCount)
        context.insert(record)

        var result = CompletionResult(recordID: record.id, sessionMiles: miles, isFirstWorkout: previous.isEmpty)
        try advanceJourney(by: miles, on: summary.date, into: &result)

        let daysAfter = ActivityCalendar(records: previous.map(\.date) + [summary.date], restDays: [], calendar: calendar).activeDays
        result.activeDays = daysAfter
        let before = TreeLevel.level(activeDays: daysBefore)
        let after = TreeLevel.level(activeDays: daysAfter)
        if after > before { result.reachedLevel = after }
        try pickCheer(for: summary, previous: previous, activeDays: daysAfter, into: &result)

        try context.save()
        await health.saveWorkout(summary)
        await notifications.reschedule()
        return result
    }

    /// The Complete cheer: the context from her own sessions, rest days and program week, then a line
    /// that turns with her active days and never repeats the last one shown (task 3.6).
    private func pickCheer(for summary: SessionSummary, previous: [WorkoutRecord], activeDays: Int,
                           into result: inout CompletionResult) throws {
        func isUnbrokenWalk(kind: String, breaks: Int) -> Bool { (kind == "walk" || kind == "firstWalk") && breaks == 0 }
        let profile = try context.fetch(FetchDescriptor<UserProfile>()).first { $0.onboardingCompleted }
        let chosen = Set((profile?.restDays ?? []).compactMap(Weekday.init(rawValue:)))
        let restDays = RestDays.effective(chosen: chosen, entitlement: entitlement())
        let week: Int? = try context.fetch(FetchDescriptor<ProgramState>()).first.flatMap { state in
            guard case .week(let week, _) = ProgramCalendar.position(state.programRound, on: summary.date, calendar: calendar)
            else { return nil }
            return week
        }
        let session = CheerSession(date: summary.date, seconds: summary.activeSeconds,
                                   isUnbrokenWalk: isUnbrokenWalk(kind: summary.kind.rawValue, breaks: summary.breakCount))
        let before = previous.map {
            CheerSession(date: $0.date, seconds: $0.activeSeconds, isUnbrokenWalk: isUnbrokenWalk(kind: $0.kind, breaks: $0.breakCount))
        }
        let cheerContext = CompleteCheer.context(session: session, previous: before, restDays: restDays, programWeek: week,
                                                 calendar: calendar)
        let cheer = CompleteCheer.pick(cheerContext, sessionIndex: activeDays, lastID: cheers?.lastID)
        cheers?.lastID = cheer.id
        result.cheerContext = cheerContext
        result.cheer = cheer
        result.sessionNumber = previous.count + 1
    }

    func recordFeeling(_ feeling: Feeling, for recordID: UUID) throws {
        let descriptor = FetchDescriptor<WorkoutRecord>(predicate: #Predicate { $0.id == recordID })
        guard let record = try context.fetch(descriptor).first else { return }
        record.feeling = feeling.rawValue
        try context.save()
        try adaptLevel(after: record)
    }

    /// The level changes here, once, when the answer is saved, so Today, Preview and Me all read
    /// the same level and the Today card shows exactly once (plan 08/10/2026 decision 2).
    private func adaptLevel(after record: WorkoutRecord) throws {
        guard let levels else { return }
        let profile = try context.fetch(FetchDescriptor<UserProfile>()).first { $0.onboardingCompleted }
        let startLevel = profile.flatMap { WalkLevel(rawValue: $0.startLevel) } ?? .seated
        let state = levels.state(startLevel: startLevel)
        let history = try context.fetch(FetchDescriptor<WorkoutRecord>(sortBy: [SortDescriptor(\.date)])).map {
            SessionFeedback(level: WalkLevel(rawValue: $0.level) ?? .seated, feeling: $0.feeling.flatMap(Feeling.init),
                            breakCount: $0.breakCount, date: $0.date)
        }
        let result = Adaptation.next(state: state, history: history)
        guard result.level != state.level else { return }
        levels.set(level: result.level, changedAt: record.date, card: result.card)
    }

    private func advanceJourney(by miles: Double, on date: Date, into result: inout CompletionResult) throws {
        let states = try context.fetch(FetchDescriptor<JourneyState>())
        let state: JourneyState
        if let current = states.first(where: \.isCurrent) {
            state = current
        } else {
            state = JourneyState(journeyID: "jr.ny", isCurrent: true, startedAt: date)
            context.insert(state)
        }
        guard let journey = content.journeys.first(where: { $0.id == state.journeyID }) else { return }

        let limit = JourneyAccess.limitMile(for: journey, entitlement: entitlement())
        let from = JourneyAccess.routeMiles(total: state.miles, limit: limit)
        state.miles += miles
        let to = JourneyAccess.routeMiles(total: state.miles, limit: limit)
        // A locked route still unlocks its first postcard: move a hair past the limit mile.
        let reachable = limit.map { _ in max(to, miles > 0 ? 1e-6 : 0) } ?? to
        let step = JourneyProgress.advance(journey: journey, from: from, to: reachable)

        // Every stop reached and not yet opened, not only the ones crossed in this session: miles
        // walked on the free plan past a locked stop open it once she upgrades.
        let already = Set(try context.fetch(FetchDescriptor<PostcardUnlock>()).filter { $0.journeyID == journey.id }.map(\.stopID))
        let reached = JourneyProgress.reached(journey, at: reachable)
        let unlocked = journey.stops.filter { reached.contains($0.id) && !already.contains($0.id) }
        for stop in unlocked {
            context.insert(PostcardUnlock(journeyID: journey.id, stopID: stop.id, unlockedAt: date))
        }
        // Complete only in the session that reached the end; later sessions on a finished route are
        // not "journey complete" again (each one offered the plans; review 02/10/2026).
        let finishedNow = step.isComplete && state.completedAt == nil
        if finishedNow { state.completedAt = date }

        result.journeyID = journey.id
        result.routeMiles = to
        result.unlockedStops = unlocked
        result.nextStop = step.next
        result.milesToNext = step.milesToNext
        result.journeyComplete = finishedNow
        result.isLockedAhead = limit != nil && step.next != nil && to >= (limit ?? 0)
        result.routeLimit = limit
    }
}
