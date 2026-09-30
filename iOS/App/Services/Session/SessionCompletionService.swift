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
}

/// Saves a session and moves everything that depends on it (task 4.11): the workout record, the
/// journey and its postcards, active days and tree level, Apple Health and notifications.
@MainActor final class SessionCompletionService {
    private let context: ModelContext
    private let content: ContentBundle
    private let entitlement: () -> Entitlement
    private let health: WorkoutHealthWriting
    private let notifications: NotificationRescheduling
    private let calendar: Calendar

    init(context: ModelContext, content: ContentBundle, entitlement: @escaping () -> Entitlement,
         health: WorkoutHealthWriting, notifications: NotificationRescheduling, calendar: Calendar = .current) {
        self.context = context
        self.content = content
        self.entitlement = entitlement
        self.health = health
        self.notifications = notifications
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

        try context.save()
        await health.saveWorkout(summary)
        await notifications.reschedule()
        return result
    }

    func recordFeeling(_ feeling: Feeling, for recordID: UUID) throws {
        let descriptor = FetchDescriptor<WorkoutRecord>(predicate: #Predicate { $0.id == recordID })
        guard let record = try context.fetch(descriptor).first else { return }
        record.feeling = feeling.rawValue
        try context.save()
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
        if step.isComplete, state.completedAt == nil { state.completedAt = date }

        result.journeyID = journey.id
        result.routeMiles = to
        result.unlockedStops = unlocked
        result.nextStop = step.next
        result.milesToNext = step.milesToNext
        result.journeyComplete = step.isComplete
        result.isLockedAhead = limit != nil && step.next != nil && to >= (limit ?? 0)
        result.routeLimit = limit
    }
}
