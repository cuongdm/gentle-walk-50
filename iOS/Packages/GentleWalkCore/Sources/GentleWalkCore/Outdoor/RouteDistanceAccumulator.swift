import Foundation

/// One GPS fix, as a plain value (the app converts `CLLocation`).
public struct RoutePoint: Equatable, Sendable {
    public var latitude: Double
    public var longitude: Double
    /// Metres; negative means invalid.
    public var horizontalAccuracy: Double
    public var timestamp: Date

    public init(latitude: Double, longitude: Double, horizontalAccuracy: Double, timestamp: Date) {
        self.latitude = latitude; self.longitude = longitude; self.horizontalAccuracy = horizontalAccuracy; self.timestamp = timestamp
    }
}

/// Adds up an outdoor walk (task 8.1), skipping fixes that are too rough or impossible for a walker.
public struct RouteDistanceAccumulator: Sendable {
    /// Fixes less precise than this are dropped.
    public static let maxAccuracy = 20.0
    /// Faster than this between fixes is a GPS jump, not walking.
    public static let maxSpeed = 10.0
    static let earthRadius = 6_371_000.0

    public private(set) var meters = 0.0
    public private(set) var accepted: [RoutePoint] = []

    public init() {}

    /// Adds a fix and returns the total metres so far.
    public mutating func add(_ point: RoutePoint) -> Double {
        guard point.horizontalAccuracy >= 0, point.horizontalAccuracy <= Self.maxAccuracy else { return meters }
        guard let last = accepted.last else {
            accepted.append(point)
            return meters
        }
        let step = Self.distance(last, point)
        let seconds = point.timestamp.timeIntervalSince(last.timestamp)
        guard seconds > 0, step / seconds <= Self.maxSpeed else { return meters }
        meters += step
        accepted.append(point)
        return meters
    }

    public var miles: Double { meters / 1_609.344 }

    /// Great-circle distance in metres (haversine).
    static func distance(_ a: RoutePoint, _ b: RoutePoint) -> Double {
        let lat1 = a.latitude * .pi / 180, lat2 = b.latitude * .pi / 180
        let dLat = lat2 - lat1, dLon = (b.longitude - a.longitude) * .pi / 180
        let h = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2)
        return 2 * earthRadius * asin(min(1, sqrt(h)))
    }
}
