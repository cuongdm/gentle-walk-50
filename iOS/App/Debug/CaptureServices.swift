#if DEBUG
import CoreLocation
import Foundation
import HealthKit
import SwiftData
import UserNotifications
import GentleWalkCore

/// Screenshot stand-ins: no system dialogs, no real sensors.
@MainActor final class CaptureHealthStore: HealthStoring {
    var connected: Bool
    init(connected: Bool) { self.connected = connected }
    var isAvailable: Bool { true }
    func requestAuthorization() async throws {}
    func canWriteWorkouts() -> Bool { connected }
    func saveWorkout(activity: HKWorkoutActivityType, indoor: Bool, start: Date, end: Date, route: [RoutePoint]) async throws {}
    func dailySteps(from start: Date, to end: Date, calendar: Calendar) async throws -> [Date: Double] {
        var result: [Date: Double] = [:]
        var day = calendar.startOfDay(for: start)
        var index = 0
        while day < end {
            result[day] = 4_200 + Double(index * 190 % 1_300)
            day = calendar.date(byAdding: .day, value: 1, to: day) ?? end
            index += 1
        }
        return result
    }
}

@MainActor final class CaptureNotificationCenter: NotificationCenterProtocol {
    func pendingRequests() async -> [UNNotificationRequest] { [] }
    func removePending(ids: [String]) {}
    func add(_ request: UNNotificationRequest) async throws {}
    func setCategories(_ categories: Set<UNNotificationCategory>) {}
    func isAllowed() async -> Bool { true }
}

@MainActor final class CaptureLocationManager: LocationManaging {
    var authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
    var allowsBackgroundLocationUpdates = false
    var onPoint: ((RoutePoint) -> Void)?
    func requestWhenInUseAuthorization() {}
    func startUpdatingLocation() {}
    func stopUpdatingLocation() {}
}

@MainActor final class CaptureBackgroundActivity: BackgroundActivityProviding {
    func begin() -> BackgroundActivityToken { BackgroundActivityToken {} }
}

@MainActor final class CapturePedometer: PedometerProviding {
    var isAuthorized: Bool { false }
    func start(from date: Date, onUpdate: @escaping (Int, Double?) -> Void, onDenied: @escaping () -> Void) {}
    func stop() {}
}

extension AppModel {
    /// An in-memory app with the Margaret fixture (App/Debug/Fixtures/en-US.json).
    /// - Parameter day: the capture day (default today), always at 9:05.
    static func capture(entitlement: Entitlement, healthConnected: Bool = true, day: Date = .now,
                        seed: (ModelContext, Date, Calendar) -> Void = { _, _, _ in }) -> AppModel {
        let container = try! ModelContainerFactory.make(inMemory: true)
        let defaults = UserDefaults(suiteName: "capture-app")!
        defaults.removePersistentDomain(forName: "capture-app")
        if healthConnected { defaults.set(true, forKey: HealthService.askedKey) }
        let calendar = Calendar.current
        let now = calendar.date(bySettingHour: 9, minute: 5, second: 0, of: day) ?? day
        if let fixture = try? CaptureFixture.load(bundle: .main) {
            try? CaptureHook.seed(fixture, into: container.mainContext, now: now, calendar: calendar)
        }
        seed(container.mainContext, now, calendar)
        try? container.mainContext.save()
        let app = AppModel(container: container, content: AppContent.bundle, store: StoreService(),
                           health: HealthService(store: CaptureHealthStore(connected: healthConnected), defaults: defaults),
                           notificationCenter: CaptureNotificationCenter(),
                           location: LocationService(manager: CaptureLocationManager(), background: CaptureBackgroundActivity()),
                           pedometer: PedometerService(pedometer: CapturePedometer()), motion: MotionService(), defaults: defaults)
        app.entitlementOverride = entitlement
        app.priceOverride = [ProductID.yearly: "$39.99", ProductID.monthly: "$7.99", ProductID.lifetime: "$79.99"]
        app.now = { now }
        app.calendar = calendar
        app.reload()
        return app
    }

    /// Plan cards filled from the local StoreKit file's test prices.
    static let capturePlanOptions = [
        PlanOption(id: ProductID.yearly, kind: .yearly, price: "$39.99", monthlyEquivalent: String(localized: "\("$3.33") a month")),
        PlanOption(id: ProductID.monthly, kind: .monthly, price: "$7.99"),
        PlanOption(id: ProductID.lifetime, kind: .lifetime, price: "$79.99"),
    ]
}
#endif
