/// Turns a workout into journey miles (spec: every active minute moves you along the route).
public enum ActivityDistance {
    /// Indoor rate: 12 active minutes = 0.6 journey miles, the same for every level.
    public static let milesPerActiveMinute = 0.05

    /// Journey miles earned by one workout. Outdoor walks use the measured distance instead.
    public static func miles(activeMinutes: Double, outdoorMiles: Double? = nil) -> Double {
        if let outdoorMiles { return max(0, outdoorMiles) }
        return max(0, activeMinutes) * milesPerActiveMinute
    }
}
