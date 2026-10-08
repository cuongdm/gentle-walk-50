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

    /// Review I6: the next walk (steps only) must not reuse this walk's miles and route.
    @Test func endingAWalkForgetsItsRoute() {
        let manager = FakeLocationManager()
        let service = LocationService(manager: manager, background: FakeBackgroundActivity())
        let start = Date(timeIntervalSince1970: 1_790_000_000)
        service.startWalk(at: start)
        manager.send(RoutePoint(latitude: 40.7, longitude: -73.97, horizontalAccuracy: 5, timestamp: start))
        manager.send(RoutePoint(latitude: 40.701, longitude: -73.97, horizontalAccuracy: 5, timestamp: start.addingTimeInterval(20)))
        #expect(service.hasFix)
        service.endWalk()
        #expect(!service.hasFix)
        #expect(service.miles == 0)
        #expect(service.route.isEmpty)
    }
}

@MainActor final class FakePedometer: PedometerProviding {
    var available = true
    var denied = false
    var isAuthorized = false
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
        #expect(!service.isRunning)
    }

    /// Owner S1 (02/10/2026): steps on the live map only while this walk is counted.
    @Test func runningOnlyBetweenStartAndStop() {
        let pedometer = FakePedometer()
        pedometer.isAuthorized = true
        let service = PedometerService(pedometer: pedometer)
        #expect(service.isAuthorized)
        #expect(!service.isRunning)
        service.start(at: Date())
        #expect(service.isRunning)
        service.stop()
        #expect(!service.isRunning)
    }
}

/// Outdoor prep (plan 08/10/2026 task 1.17): she picks how to measure first; only "Map and distance"
/// leads to the one-button location prompt, and "Don't Allow" there means steps, never asked again.
@MainActor @Suite(.serialized) struct OutdoorPrepFlowTests {
    let defaults: UserDefaults = {
        let defaults = UserDefaults(suiteName: "outdoor-prep-flow-tests")!
        defaults.removePersistentDomain(forName: "outdoor-prep-flow-tests")
        return defaults
    }()

    @Test func dontAllowFallsBackToSteps() async {
        let flow = OutdoorPrepFlow(asksLocation: OutdoorLocationChoice.asks(in: defaults))
        #expect(flow.step == .ready)
        flow.readyDone()
        #expect(flow.step == .measure)
        flow.measure = .map
        #expect(flow.measureDone() == .continues)  // Map: the prompt comes first
        #expect(flow.step == .locationPrompt)
        let useLocation = await flow.requestLocation { false }  // "Don't Allow"
        #expect(useLocation == false)

        OutdoorLocationChoice.save(useLocation, in: defaults)
        #expect(!OutdoorLocationChoice.asks(in: defaults))
        #expect(!OutdoorLocationChoice.usesLocation(in: defaults))
        // Next time: straight from the checklist to the walk, no question.
        let next = OutdoorPrepFlow(asksLocation: OutdoorLocationChoice.asks(in: defaults))
        #expect(next.readyDone() == .finished(useLocation: nil))
    }

    @Test func stepsOnlyNeverOpensThePrompt() async {
        let flow = OutdoorPrepFlow(asksLocation: true)
        flow.readyDone()
        flow.measure = .steps
        #expect(flow.measureDone() == .finished(useLocation: false))
        #expect(flow.step == .measure)
    }

    @Test func allowUsesTheMap() async {
        let flow = OutdoorPrepFlow(asksLocation: true)
        flow.readyDone()
        flow.measure = .map
        _ = flow.measureDone()
        #expect(await flow.requestLocation { true } == true)
    }
}
