import CoreLocation
import Foundation
import HealthKit
import GentleWalkCore

/// The HealthKit calls the app makes, behind a protocol so tests use a fake store.
@MainActor protocol HealthStoring: AnyObject {
    var isAvailable: Bool { get }
    func requestAuthorization() async throws
    func canWriteWorkouts() -> Bool
    func saveWorkout(activity: HKWorkoutActivityType, indoor: Bool, start: Date, end: Date, route: [RoutePoint]) async throws
    func dailySteps(from start: Date, to end: Date, calendar: Calendar) async throws -> [Date: Double]
}

/// Apple Health (task 6.7): permission only from S16, workouts written after each session, steps
/// read for Progress. The journey never depends on Health.
@MainActor final class HealthService: WorkoutHealthWriting, HealthAuthorizing {
    static let askedKey = "healthAskedForAuthorization"

    private let store: HealthStoring
    private let defaults: UserDefaults

    init(store: HealthStoring, defaults: UserDefaults = .standard) {
        self.store = store
        self.defaults = defaults
    }

    var isAvailable: Bool { store.isAvailable }
    var hasAskedForAuthorization: Bool { defaults.bool(forKey: Self.askedKey) }
    /// Whether workouts can be saved (Health does not reveal read permission).
    var isConnected: Bool { store.isAvailable && hasAskedForAuthorization && store.canWriteWorkouts() }

    /// Opens Apple's Health permission sheet. Call only from S16 or Settings.
    func requestAuthorization() async -> Bool {
        guard store.isAvailable else { return false }
        do {
            try await store.requestAuthorization()
            defaults.set(true, forKey: Self.askedKey)
            return true
        } catch {
            return false
        }
    }

    func saveWorkout(_ summary: SessionSummary) async {
        guard store.isAvailable, hasAskedForAuthorization, store.canWriteWorkouts(), summary.activeSeconds > 0 else { return }
        let start = summary.date.addingTimeInterval(-Double(summary.activeSeconds))
        try? await store.saveWorkout(activity: Self.activity(for: summary.kind), indoor: summary.place != .outdoors,
                                     start: start, end: summary.date, route: summary.route)
    }

    static func activity(for kind: SessionTemplate.Kind) -> HKWorkoutActivityType {
        switch kind {
        case .chair, .balance: .functionalStrengthTraining
        case .stretch, .cooldown: .flexibility
        case .walk, .firstWalk: .walking
        }
    }

    /// Average daily steps this week and last week (days with data), for the Progress card.
    func weeklySteps(now: Date, calendar: Calendar) async -> (thisWeek: Double, lastWeek: Double)? {
        guard store.isAvailable, let thisWeek = calendar.dateInterval(of: .weekOfYear, for: now),
              let lastStart = calendar.date(byAdding: .weekOfYear, value: -1, to: thisWeek.start),
              let days = try? await store.dailySteps(from: lastStart, to: now, calendar: calendar) else { return nil }
        func average(_ range: Range<Date>) -> Double {
            let values = days.filter { range.contains($0.key) && $0.value > 0 }.map(\.value)
            return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
        }
        return (average(thisWeek.start..<now), average(lastStart..<thisWeek.start))
    }

    /// She has been on her feet a lot today (P11, plan 4.12): before her reminder, today's steps are over
    /// 1.5 × her own usual (`BusyDay`). Only after Apple Health was asked from S16; nothing is stored.
    func isBusyDay(now: Date, reminderMinutes: Int, calendar: Calendar) async -> Bool {
        let today = calendar.startOfDay(for: now)
        guard store.isAvailable, hasAskedForAuthorization,
              let start = calendar.date(byAdding: .day, value: -BusyDay.historyDays, to: today),
              let days = try? await store.dailySteps(from: start, to: now, calendar: calendar) else { return false }
        let stepsToday = days.filter { $0.key >= today }.reduce(0) { $0 + $1.value }
        return BusyDay.isBusy(stepsToday: stepsToday, dailySteps: days, now: now, reminderMinutes: reminderMinutes,
                              calendar: calendar)
    }
}

/// The real HealthKit store.
@MainActor final class SystemHealthStore: HealthStoring {
    private let store = HKHealthStore()

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    func requestAuthorization() async throws {
        try await store.requestAuthorization(toShare: [HKObjectType.workoutType(), HKSeriesType.workoutRoute()],
                                             read: [HKQuantityType(.stepCount)])
    }

    func canWriteWorkouts() -> Bool {
        store.authorizationStatus(for: HKObjectType.workoutType()) == .sharingAuthorized
    }

    func saveWorkout(activity: HKWorkoutActivityType, indoor: Bool, start: Date, end: Date, route: [RoutePoint]) async throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = activity
        configuration.locationType = indoor ? .indoor : .outdoor
        let builder = HKWorkoutBuilder(healthStore: store, configuration: configuration, device: .local())
        try await builder.beginCollection(at: start)
        try await builder.addMetadata([HKMetadataKeyIndoorWorkout: indoor])
        try await builder.endCollection(at: end)
        guard let workout = try await builder.finishWorkout(), !route.isEmpty else { return }
        // Outdoor route (task 8.6): saved with the workout, visible in the Health app.
        let routeBuilder = HKWorkoutRouteBuilder(healthStore: store, device: .local())
        let locations = route.map {
            CLLocation(coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude), altitude: 0,
                       horizontalAccuracy: $0.horizontalAccuracy, verticalAccuracy: -1, timestamp: $0.timestamp)
        }
        try await routeBuilder.insertRouteData(locations)
        _ = try await routeBuilder.finishRoute(with: workout, metadata: nil)
    }

    func dailySteps(from start: Date, to end: Date, calendar: Calendar) async throws -> [Date: Double] {
        let type = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        let descriptor = HKStatisticsCollectionQueryDescriptor(
            predicate: .quantitySample(type: type, predicate: predicate), options: .cumulativeSum,
            anchorDate: calendar.startOfDay(for: start), intervalComponents: DateComponents(day: 1))
        let collection = try await descriptor.result(for: store)
        var result: [Date: Double] = [:]
        collection.enumerateStatistics(from: start, to: end) { statistics, _ in
            result[statistics.startDate] = statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0
        }
        return result
    }
}
