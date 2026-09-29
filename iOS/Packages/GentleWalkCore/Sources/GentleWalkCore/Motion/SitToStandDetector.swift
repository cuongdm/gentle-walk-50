/// One motion reading with the phone held to the chest: acceleration along gravity (g, up is
/// positive, gravity removed) and forward lean (degrees).
public struct MotionSample: Equatable, Sendable {
    public var time: Double
    public var verticalAcceleration: Double
    public var pitchDegrees: Double

    public init(time: Double, verticalAcceleration: Double, pitchDegrees: Double) {
        self.time = time; self.verticalAcceleration = verticalAcceleration; self.pitchDegrees = pitchDegrees
    }
}

/// Counts sit-to-stands (task 8.7). Standing up is a push up followed by slowing down (a positive
/// then a negative lobe) with a forward lean; sitting down is the mirror. One stand followed by one
/// sit is one rep. "Counted for you" shows only when `confident`: every rep had the lean.
public struct SitToStandDetector: Sendable {
    /// Lobe threshold in g; smaller movements (hand jiggle, half stands) are ignored.
    public static let threshold = 0.12
    /// A lobe must last this long (seconds).
    public static let minLobe = 0.12
    /// The second lobe of a stand or sit must start this soon after the first ends.
    public static let maxGap = 0.6
    /// Forward lean that marks a real stand-up.
    public static let minLean = 10.0
    /// A sit must follow its stand within this time.
    public static let maxRep = 8.0

    private struct Lobe { var sign: Int; var start: Double; var end: Double; var maxLean: Double }

    public private(set) var count = 0
    private(set) var leanedReps = 0
    private var lobes: [Lobe] = []
    private var current: Lobe?
    private var pendingStand: (time: Double, leaned: Bool)?

    public init() {}

    /// True only when reps were seen and every one of them looked like a real sit-to-stand.
    public var confident: Bool { count > 0 && leanedReps == count }

    /// Adds a sample; returns true when it completed a rep.
    public mutating func add(_ sample: MotionSample) -> Bool {
        let a = sample.verticalAcceleration
        let sign = a > Self.threshold ? 1 : a < -Self.threshold ? -1 : 0
        if var lobe = current, lobe.sign == sign {
            lobe.end = sample.time
            lobe.maxLean = max(lobe.maxLean, abs(sample.pitchDegrees))
            current = lobe
            return false
        }
        var counted = false
        if let lobe = current, lobe.end - lobe.start >= Self.minLobe - 1e-9 {
            counted = close(lobe)
        }
        current = sign == 0 ? nil : Lobe(sign: sign, start: sample.time, end: sample.time, maxLean: abs(sample.pitchDegrees))
        return counted
    }

    /// A finished lobe: pairs with the previous one into a stand (+ −) or a sit (− +).
    private mutating func close(_ lobe: Lobe) -> Bool {
        defer { lobes.append(lobe) }
        guard let previous = lobes.last, lobe.start - previous.end <= Self.maxGap, previous.sign != lobe.sign else { return false }
        lobes.removeAll()
        let leaned = max(previous.maxLean, lobe.maxLean) >= Self.minLean
        if previous.sign > 0 {
            pendingStand = (lobe.end, leaned)
            return false
        }
        guard let stand = pendingStand, lobe.end - stand.time <= Self.maxRep else { return false }
        pendingStand = nil
        count += 1
        if stand.leaned { leanedReps += 1 }
        return true
    }
}
