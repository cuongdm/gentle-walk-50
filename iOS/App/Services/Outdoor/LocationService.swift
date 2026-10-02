import CoreLocation
import Foundation
import Observation
import GentleWalkCore

/// The `CLLocationManager` calls the app makes, behind a protocol for tests.
@MainActor protocol LocationManaging: AnyObject {
    var authorizationStatus: CLAuthorizationStatus { get }
    var allowsBackgroundLocationUpdates: Bool { get set }
    var onPoint: ((RoutePoint) -> Void)? { get set }
    func requestWhenInUseAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}

/// Ends a background activity session when invalidated.
@MainActor final class BackgroundActivityToken {
    private let end: () -> Void
    init(end: @escaping () -> Void) { self.end = end }
    func invalidate() { end() }
}

/// `CLBackgroundActivitySession` in the app (keeps location updates going with the screen locked).
@MainActor protocol BackgroundActivityProviding: AnyObject {
    func begin() -> BackgroundActivityToken
}

/// Location for outdoor walks only (task 8.2, 2.5.4): While Using permission, background updates
/// and the background session switched on only while an outdoor walk runs, off at End.
@Observable @MainActor final class LocationService {
    private(set) var miles = 0.0
    private(set) var hasFix = false
    private(set) var route: [RoutePoint] = []

    @ObservationIgnored private let manager: LocationManaging
    @ObservationIgnored private let background: BackgroundActivityProviding
    @ObservationIgnored private var accumulator = RouteDistanceAccumulator()
    @ObservationIgnored private var token: BackgroundActivityToken?

    init(manager: LocationManaging, background: BackgroundActivityProviding) {
        self.manager = manager
        self.background = background
        manager.onPoint = { [weak self] point in self?.receive(point) }
    }

    var isAuthorized: Bool {
        [.authorizedWhenInUse, .authorizedAlways].contains(manager.authorizationStatus)
    }

    var isDenied: Bool { [.denied, .restricted].contains(manager.authorizationStatus) }

    /// Apple's "While Using the App" dialog; asked only from Outdoor prep (S10b).
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    /// Asks, then waits for her answer (at most a minute) before the walk starts: starting at once
    /// read "not allowed" while Apple's dialog was still up, so the first outdoor walk lost its map
    /// (review 02/10/2026). True when location may be used.
    func requestPermissionAndWait() async -> Bool {
        guard manager.authorizationStatus == .notDetermined else { return isAuthorized }
        manager.requestWhenInUseAuthorization()
        for _ in 0..<200 where manager.authorizationStatus == .notDetermined {
            try? await Task.sleep(for: .milliseconds(300))
        }
        return isAuthorized
    }

    func startWalk(at date: Date) {
        accumulator = RouteDistanceAccumulator()
        route = []
        miles = 0
        hasFix = false
        manager.allowsBackgroundLocationUpdates = true
        token = background.begin()
        manager.startUpdatingLocation()
    }

    /// The session has read the route and miles before this runs; forget them so a later walk
    /// counted by steps never reuses them (review I6).
    func endWalk() {
        manager.stopUpdatingLocation()
        manager.allowsBackgroundLocationUpdates = false
        token?.invalidate()
        token = nil
        accumulator = RouteDistanceAccumulator()
        route = []
        miles = 0
        hasFix = false
    }

    private func receive(_ point: RoutePoint) {
        miles = accumulator.add(point) / 1_609.344
        route = accumulator.accepted
        hasFix = !route.isEmpty
    }
}

/// The real manager: best accuracy for walking, fitness activity type, points converted to `RoutePoint`.
@MainActor final class SystemLocationManager: NSObject, LocationManaging, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var onPoint: ((RoutePoint) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.activityType = .fitness
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
    }

    var authorizationStatus: CLAuthorizationStatus { manager.authorizationStatus }

    var allowsBackgroundLocationUpdates: Bool {
        get { manager.allowsBackgroundLocationUpdates }
        set { manager.allowsBackgroundLocationUpdates = newValue }
    }

    func requestWhenInUseAuthorization() { manager.requestWhenInUseAuthorization() }
    func startUpdatingLocation() { manager.startUpdatingLocation() }
    func stopUpdatingLocation() { manager.stopUpdatingLocation() }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let points = locations.map {
            RoutePoint(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude,
                       horizontalAccuracy: $0.horizontalAccuracy, timestamp: $0.timestamp)
        }
        Task { @MainActor in points.forEach { self.onPoint?($0) } }
    }
}

@MainActor final class SystemBackgroundActivity: BackgroundActivityProviding {
    func begin() -> BackgroundActivityToken {
        let session = CLBackgroundActivitySession()
        return BackgroundActivityToken { session.invalidate() }
    }
}
