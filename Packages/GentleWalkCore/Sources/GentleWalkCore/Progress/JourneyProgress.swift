/// Moves a journey forward and reports which postcards a workout unlocked.
public enum JourneyProgress {
    /// Result of one advance: newly unlocked stops, the next stop and how far it is.
    public struct Step: Equatable, Sendable {
        public var unlocked: [Journey.Stop.ID]
        public var next: Journey.Stop?
        public var milesToNext: Double
        public var isComplete: Bool
    }

    /// Advances from `from` to `to` journey miles.
    ///
    /// A stop is reached once any distance has been walked and the miles reach its mile marker, so
    /// the first stop (mile 0) unlocks with the first walk, not when the journey is picked.
    public static func advance(journey: Journey, from: Double, to: Double) -> Step {
        let before = reached(journey, at: from)
        let after = reached(journey, at: to)
        let unlocked = journey.stops.filter { after.contains($0.id) && !before.contains($0.id) }.map(\.id)
        let next = journey.stops.first { !after.contains($0.id) }
        return Step(
            unlocked: unlocked,
            next: next,
            milesToNext: next.map { max(0, $0.mile - to) } ?? 0,
            isComplete: next == nil && !journey.stops.isEmpty
        )
    }

    /// Stops reached at a given mile count.
    public static func reached(_ journey: Journey, at miles: Double) -> Set<Journey.Stop.ID> {
        guard miles > 0 else { return [] }
        // Small tolerance so 2.2 reached by summing 0.05-mile steps is not missed by rounding.
        return Set(journey.stops.filter { $0.mile <= miles + 1e-9 }.map(\.id))
    }
}
