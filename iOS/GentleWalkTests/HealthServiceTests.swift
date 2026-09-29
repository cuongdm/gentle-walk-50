import Foundation
import HealthKit
import Testing
import GentleWalkCore
@testable import GentleWalk

@MainActor final class FakeHealthStore: HealthStoring {
    var isAvailable = true
    var authorized = false
    private(set) var requests = 0
    private(set) var saved: [(type: HKWorkoutActivityType, indoor: Bool, seconds: Double)] = []
    var steps: [Date: Double] = [:]

    func requestAuthorization() async throws { requests += 1; authorized = true }
    func canWriteWorkouts() -> Bool { authorized }
    private(set) var routes: [[RoutePoint]] = []
    func saveWorkout(activity: HKWorkoutActivityType, indoor: Bool, start: Date, end: Date, route: [RoutePoint]) async throws {
        saved.append((activity, indoor, end.timeIntervalSince(start)))
        routes.append(route)
    }
    func dailySteps(from start: Date, to end: Date, calendar: Calendar) async throws -> [Date: Double] {
        steps.filter { $0.key >= start && $0.key < end }
    }
}

@MainActor @Suite(.serialized) struct HealthServiceTests {
    let defaults = UserDefaults(suiteName: "health-tests")!
    let calendar = { var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(identifier: "America/New_York")!; return c }()

    init() { defaults.removePersistentDomain(forName: "health-tests") }

    func summary(_ kind: SessionTemplate.Kind, place: WorkoutPlace = .indoors) -> SessionSummary {
        SessionSummary(date: Date(timeIntervalSince1970: 1_790_000_000), kind: kind, level: .seated, intensity: .steady,
                       place: place, activeSeconds: 600, breakCount: 0)
    }

    @Test func nothingIsWrittenBeforePermission() async {
        let store = FakeHealthStore()
        let service = HealthService(store: store, defaults: defaults)
        await service.saveWorkout(summary(.walk))
        #expect(store.saved.isEmpty)
        #expect(store.requests == 0)
    }

    @Test func workoutTypesFollowTheSession() async {
        let store = FakeHealthStore()
        let service = HealthService(store: store, defaults: defaults)
        #expect(await service.requestAuthorization())
        #expect(service.hasAskedForAuthorization)
        await service.saveWorkout(summary(.walk))
        await service.saveWorkout(summary(.chair))
        await service.saveWorkout(summary(.stretch))
        await service.saveWorkout(summary(.walk, place: .outdoors))
        #expect(store.saved.map(\.type) == [.walking, .functionalStrengthTraining, .flexibility, .walking])
        #expect(store.saved.map(\.indoor) == [true, true, true, false])
        #expect(store.saved.first?.seconds == 600)
    }

    @Test func outdoorRouteGoesToHealthWithTheWorkout() async {
        let store = FakeHealthStore()
        let service = HealthService(store: store, defaults: defaults)
        _ = await service.requestAuthorization()
        var outdoor = summary(.walk, place: .outdoors)
        outdoor.route = [RoutePoint(latitude: 40.78, longitude: -73.96, horizontalAccuracy: 5, timestamp: outdoor.date)]
        await service.saveWorkout(outdoor)
        #expect(store.routes.last?.count == 1)
    }

    @Test func stepsThisWeekAgainstLastWeek() async throws {
        let store = FakeHealthStore()
        store.authorized = true
        let now = calendar.date(from: DateComponents(year: 2026, month: 9, day: 30, hour: 12))!  // Wednesday
        for day in 20...29 {
            let date = calendar.date(from: DateComponents(year: 2026, month: 9, day: day))!
            store.steps[date] = day >= 27 ? 6_000 : 4_000
        }
        let service = HealthService(store: store, defaults: defaults)
        let steps = try #require(await service.weeklySteps(now: now, calendar: calendar))
        #expect(steps.thisWeek == 6_000)
        #expect(steps.lastWeek == 4_000)
    }

    @Test func unavailableHealthIsQuiet() async {
        let store = FakeHealthStore()
        store.isAvailable = false
        let service = HealthService(store: store, defaults: defaults)
        #expect(await service.requestAuthorization() == false)
        await service.saveWorkout(summary(.walk))
        #expect(store.saved.isEmpty)
    }
}
