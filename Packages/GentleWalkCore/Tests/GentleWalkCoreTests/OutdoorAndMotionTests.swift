import Foundation
import Testing
@testable import GentleWalkCore

@Suite struct RouteDistanceAccumulatorTests {
    let start = Date(timeIntervalSince1970: 1_790_000_000)
    /// One degree of latitude ≈ 111,195 m (mean Earth radius 6,371 km).
    let metersPerDegree = 111_194.93

    func point(_ meters: Double, second: Double, accuracy: Double = 5) -> RoutePoint {
        RoutePoint(latitude: 40.7 + meters / metersPerDegree, longitude: -73.97, horizontalAccuracy: accuracy,
                   timestamp: start.addingTimeInterval(second))
    }

    @Test func oneKilometreRouteMeasuresOneKilometre() {
        var route = RouteDistanceAccumulator()
        var total = 0.0
        for step in 0...100 { total = route.add(point(Double(step) * 10, second: Double(step) * 7)) }
        #expect(abs(total - 1_000) < 10)
    }

    @Test func inaccurateFixesAreIgnored() {
        var route = RouteDistanceAccumulator()
        _ = route.add(point(0, second: 0))
        _ = route.add(point(300, second: 10, accuracy: 35))
        _ = route.add(point(-1, second: 11, accuracy: -1))
        #expect(route.add(point(10, second: 20)) < 10.5)
    }

    @Test func jumpsFasterThanTenMetresASecondAreIgnored() {
        var route = RouteDistanceAccumulator()
        _ = route.add(point(0, second: 0))
        _ = route.add(point(500, second: 1))
        #expect(abs(route.add(point(12, second: 10)) - 12) < 0.5)
    }
}

@Suite struct SitToStandDetectorTests {
    /// One sit-to-stand at 50 Hz: rise (vertical push up then slow down) with a forward lean,
    /// stand still, sit down (the mirror), rest. Accelerations in g, pitch in degrees.
    func rep(amplitude: Double = 0.3, lean: Double = 22) -> [(a: Double, pitch: Double)] {
        var samples: [(Double, Double)] = []
        for i in 0..<50 { let t = Double(i) / 50; samples.append((amplitude * sin(2 * .pi * t), lean * sin(.pi * t))) }
        samples += Array(repeating: (0, 0), count: 50)
        for i in 0..<50 { let t = Double(i) / 50; samples.append((-amplitude * sin(2 * .pi * t), lean * sin(.pi * t))) }
        samples += Array(repeating: (0, 0), count: 50)
        return samples
    }

    func run(_ samples: [(a: Double, pitch: Double)]) -> SitToStandDetector {
        var detector = SitToStandDetector()
        for (index, sample) in samples.enumerated() {
            _ = detector.add(MotionSample(time: Double(index) / 50, verticalAcceleration: sample.a, pitchDegrees: sample.pitch))
        }
        return detector
    }

    @Test func tenStandsAreCountedTen() {
        let detector = run((0..<10).flatMap { _ in rep() })
        #expect(detector.count == 10)
        #expect(detector.confident)
    }

    @Test func handJiggleCountsNothing() {
        var generator = SeededRandom(seed: 7)
        let noise = (0..<1_500).map { _ in (a: generator.next(in: -0.05...0.05), pitch: generator.next(in: -3...3)) }
        let detector = run(noise)
        #expect(detector.count == 0)
        #expect(!detector.confident)
    }

    @Test func halfStandsCountNothing() {
        #expect(run((0..<5).flatMap { _ in rep(amplitude: 0.08, lean: 8) }).count == 0)
    }

    @Test func bouncingWithoutLeaningIsNotConfident() {
        let detector = run((0..<4).flatMap { _ in rep(lean: 1) })
        #expect(!detector.confident)
    }
}

/// Deterministic noise for tests.
struct SeededRandom {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next(in range: ClosedRange<Double>) -> Double {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        let unit = Double(state >> 11) / Double(1 << 53)
        return range.lowerBound + unit * (range.upperBound - range.lowerBound)
    }
}

@Suite struct WalkingPadTests {
    @Test func walkingPadUsesTheInPlaceTimings() throws {
        let content = TestSupport.appContent
        let day = PlannedDay(main: .walk, chairMoves: 0, cooldown: false)
        for intensity in Intensity.allCases {
            let pad = try SessionBuilder.build(kind: day, level: .pad, intensity: intensity, limits: [], rotationIndex: 0, content: content)
            let inPlace = try SessionBuilder.build(kind: day, level: .inPlace, intensity: intensity, limits: [], rotationIndex: 0, content: content)
            #expect(pad.segments.map(\.seconds) == inPlace.segments.map(\.seconds))
            #expect(pad.segments.map(\.kind) == inPlace.segments.map(\.kind))
            #expect(pad.lineIDs.contains { $0.hasPrefix("a2.setup.pad") })
        }
    }
}
