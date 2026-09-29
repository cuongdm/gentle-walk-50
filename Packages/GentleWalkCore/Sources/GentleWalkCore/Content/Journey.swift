/// A shortened landmark route. Distances are journey miles, driven by active minutes (task 2.1).
public struct Journey: Codable, Equatable, Identifiable, Sendable {
    public struct Stop: Codable, Equatable, Identifiable, Sendable {
        public var id: String
        public var name: String
        /// Journey mile at which this postcard unlocks; the first stop is at 0.
        public var mile: Double

        public init(id: String, name: String, mile: Double) {
            self.id = id; self.name = name; self.mile = mile
        }
    }

    public var id: String
    public var title: String
    public var isFree: Bool
    public var stops: [Stop]

    public init(id: String, title: String, isFree: Bool, stops: [Stop]) {
        self.id = id; self.title = title; self.isFree = isFree; self.stops = stops
    }
}
