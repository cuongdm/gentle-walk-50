import CoreLocation
import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

@MainActor final class FakeLocationManager: LocationManaging {
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var allowsBackgroundLocationUpdates = false
    var onPoint: ((RoutePoint) -> Void)?
    private(set) var whenInUseRequests = 0
    private(set) var alwaysRequests = 0
    private(set) var updating = false

    func requestWhenInUseAuthorization() { whenInUseRequests += 1; authorizationStatus = .authorizedWhenInUse }
    func requestAlwaysAuthorization() { alwaysRequests += 1 }
    func startUpdatingLocation() { updating = true }
    func stopUpdatingLocation() { updating = false }
    func send(_ point: RoutePoint) { onPoint?(point) }
}

@MainActor final class FakeBackgroundActivity: BackgroundActivityProviding {
    private(set) var active = 0
    private(set) var began = 0
    func begin() -> BackgroundActivityToken {
        active += 1
        began += 1
        return BackgroundActivityToken { [weak self] in self?.active -= 1 }
    }
}

@MainActor @Suite struct LocationServiceTests {
    @Test func backgroundLocationOnlyWhileAnOutdoorWalkRuns() {
        let manager = FakeLocationManager()
        let activity = FakeBackgroundActivity()
        let service = LocationService(manager: manager, background: activity)
        #expect(!manager.allowsBackgroundLocationUpdates)
        #expect(activity.active == 0)
        service.startWalk(at: Date())
        #expect(manager.allowsBackgroundLocationUpdates)
        #expect(activity.active == 1)
        #expect(manager.updating)
        service.endWalk()
        #expect(!manager.allowsBackgroundLocationUpdates)
        #expect(activity.active == 0)
        #expect(!manager.updating)
    }

    @Test func asksOnlyForWhileUsing() {
        let manager = FakeLocationManager()
        let service = LocationService(manager: manager, background: FakeBackgroundActivity())
        service.requestPermission()
        #expect(manager.whenInUseRequests == 1)
        #expect(manager.alwaysRequests == 0)
        #expect(service.isAuthorized)
    }

    @Test func pointsAddUpIntoMiles() {
        let manager = FakeLocationManager()
        let service = LocationService(manager: manager, background: FakeBackgroundActivity())
        let start = Date(timeIntervalSince1970: 1_790_000_000)
        service.startWalk(at: start)
        for step in 0...160 {
            manager.send(RoutePoint(latitude: 40.7 + Double(step) * 10 / 111_194.93, longitude: -73.97, horizontalAccuracy: 5,
                                    timestamp: start.addingTimeInterval(Double(step) * 7)))
        }
        #expect(abs(service.miles - 1.0) < 0.02)
        #expect(service.hasFix)
        #expect(service.route.count == 161)
    }
}

@MainActor final class FakePedometer: PedometerProviding {
    var available = true
    var denied = false
    private(set) var started: Date?
    private var handler: ((Int, Double?) -> Void)?
    func start(from date: Date, onUpdate: @escaping (Int, Double?) -> Void, onDenied: @escaping () -> Void) {
        started = date
        if denied { onDenied() } else { handler = onUpdate }
    }
    func stop() { handler = nil }
    func emit(steps: Int, meters: Double?) { handler?(steps, meters) }
}

@MainActor @Suite struct PedometerServiceTests {
    @Test func stepsAndDistanceFromTheStartOfTheWalk() {
        let pedometer = FakePedometer()
        let service = PedometerService(pedometer: pedometer)
        let start = Date(timeIntervalSince1970: 1_790_000_000)
        service.start(at: start)
        #expect(pedometer.started == start)
        pedometer.emit(steps: 1_200, meters: 804.672)
        #expect(service.steps == 1_200)
        #expect(abs((service.miles ?? 0) - 0.5) < 0.001)
    }

    @Test func deniedMotionFallsBackQuietly() {
        let pedometer = FakePedometer()
        pedometer.denied = true
        let service = PedometerService(pedometer: pedometer)
        service.start(at: Date())
        #expect(service.isDenied)
        #expect(service.miles == nil)
    }
}
