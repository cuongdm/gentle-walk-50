/// Pace for the live outdoor map (minutes per mile), shown only once there is a real distance.
public enum WalkPace {
    /// Below this a GPS wobble would read as a silly pace.
    public static let minimumMiles = 0.05
    /// Slower than this reads as standing still: no pace shown.
    public static let slowestMinutes = 60.0

    public static func minutesPerMile(seconds: Double, miles: Double) -> Double? {
        guard miles >= minimumMiles, seconds > 0 else { return nil }
        return seconds / 60 / miles
    }

    /// "18:30"; "–:––" before a pace exists or when she is standing still.
    public static func text(minutesPerMile: Double?) -> String {
        guard let pace = minutesPerMile, pace < slowestMinutes else { return "–:––" }
        let total = Int((pace * 60).rounded())
        let seconds = total % 60
        return "\(total / 60):\(seconds < 10 ? "0" : "")\(seconds)"
    }
}
