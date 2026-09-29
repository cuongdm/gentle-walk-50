/// A shortened landmark route. Distances are journey miles, driven by active minutes (task 2.1).
public struct Journey: Codable, Equatable, Identifiable, Sendable {
    public struct Stop: Codable, Equatable, Identifiable, Sendable {
        public var id: String
        public var name: String
        /// Journey mile at which this postcard unlocks; the first stop is at 0.
        public var mile: Double
        /// Postcard back: two sentences about the place (D7).
        public var back: String?
        /// One warm line from the coach on the postcard (D7).
        public var coachLine: String?

        public init(id: String, name: String, mile: Double, back: String? = nil, coachLine: String? = nil) {
            self.id = id; self.name = name; self.mile = mile; self.back = back; self.coachLine = coachLine
        }
    }

    public var id: String
    public var title: String
    public var isFree: Bool
    public var stops: [Stop]
    /// "Central Park to Brooklyn Bridge" (D6).
    public var subtitle: String?
    /// One-line description under the name (D6).
    public var summary: String?

    public init(id: String, title: String, isFree: Bool, stops: [Stop], subtitle: String? = nil, summary: String? = nil) {
        self.id = id; self.title = title; self.isFree = isFree; self.stops = stops
        self.subtitle = subtitle; self.summary = summary
    }

    /// Length of the route in journey miles (the last stop's marker).
    public var length: Double { stops.last?.mile ?? 0 }
}
