/// How far a journey may go for an entitlement. Free users walk the first leg of a paid route, from
/// the start to the second stop and its postcard ("First leg free", owner 30/09/2026), then see
/// what comes with Pro; total miles still count.
public enum JourneyAccess {
    /// The last journey mile the user may reach on this route, or nil for no limit.
    public static func limitMile(for journey: Journey, entitlement: Entitlement) -> Double? {
        guard !journey.isFree, !entitlement.isPro else { return nil }
        return freeLegEnd(of: journey)?.mile ?? 0
    }

    /// The stop a free user can walk to on a paid route ("First leg free").
    public static func freeLegEnd(of journey: Journey) -> Journey.Stop? {
        journey.stops.count > 1 ? journey.stops[1] : journey.stops.first
    }

    /// Miles shown on the route map: capped at the limit. Lifetime totals use the uncapped value.
    public static func routeMiles(total: Double, limit: Double?) -> Double {
        guard let limit else { return total }
        return min(total, limit)
    }
}
