/// How far a journey may go for an entitlement (spec: free users reach the first postcard of a
/// locked route, then see "Keep going to [next stop]"; total miles still count).
public enum JourneyAccess {
    /// The last journey mile the user may reach on this route, or nil for no limit.
    public static func limitMile(for journey: Journey, entitlement: Entitlement) -> Double? {
        guard !journey.isFree, !entitlement.isPro else { return nil }
        return journey.stops.first?.mile ?? 0
    }

    /// Miles shown on the route map: capped at the limit. Lifetime totals use the uncapped value.
    public static func routeMiles(total: Double, limit: Double?) -> Double {
        guard let limit else { return total }
        return min(total, limit)
    }
}
