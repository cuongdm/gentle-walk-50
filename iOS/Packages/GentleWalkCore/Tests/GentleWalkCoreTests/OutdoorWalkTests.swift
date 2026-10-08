import Foundation
import Testing
@testable import GentleWalkCore

/// Outdoors she walks along a street: the coach keeps the walk's timing and its walking lines, but no
/// chair, seat, floor or in-place move lines, and no stretch that needs a chair (review C, 09/10/2026).
@Suite struct OutdoorWalkTests {
    let content = TestSupport.appContent
    var texts: [String: String] { Dictionary(content.voiceLines.map { ($0.id, $0.text) }, uniquingKeysWith: { a, _ in a }) }

    func outdoor(_ intensity: Intensity, long: Bool = false, limits: Set<BodyLimit> = [], rotation: Int = 0) throws -> SessionPlan {
        let day = PlannedDay(main: long ? .longWalk : .walk, chairMoves: 0, cooldown: false)
        let plan = try SessionBuilder.build(kind: day, level: .inPlace, intensity: intensity, limits: limits,
                                            rotationIndex: rotation, content: content)
        return OutdoorWalk.adapt(plan)
    }

    static let cases: [(Intensity, Bool)] = [(.gentle, false), (.steady, false), (.strong, false), (.steady, true), (.strong, true)]

    @Test(arguments: cases)
    func noIndoorLinesOutdoors(_ intensity: Intensity, _ long: Bool) throws {
        let banned = ["chair", "seat", "floor", "sofa", "watch", "next up", "join in", "your turn", "together"]
        for rotation in 0..<4 {
            for limits: Set<BodyLimit> in [[], [.knees, .shoulders]] + BodyLimit.allCases.map({ [$0] }) {
                let plan = try outdoor(intensity, long: long, limits: limits, rotation: rotation)
                for line in plan.lineIDs {
                    let text = (texts[line] ?? "").lowercased()
                    #expect(!banned.contains { text.contains($0) }, "\(line): \(text)")
                }
            }
        }
    }

    @Test(arguments: cases)
    func keepsTheWalkAndEndsStanding(_ intensity: Intensity, _ long: Bool) throws {
        let indoor = try SessionBuilder.build(kind: PlannedDay(main: long ? .longWalk : .walk, chairMoves: 0, cooldown: false),
                                              level: .inPlace, intensity: intensity, limits: [], rotationIndex: 0, content: content)
        let plan = try outdoor(intensity, long: long)
        // Every walking part stays, with its time; only stretches that need a chair go.
        #expect(plan.segments.filter { $0.exerciseID?.hasPrefix("st.") != true }
                == indoor.segments.filter { $0.exerciseID?.hasPrefix("st.") != true }.map { OutdoorWalk.adapt(segment: $0) })
        let stretches = plan.segments.compactMap(\.exerciseID).filter { $0.hasPrefix("st.") }
        #expect(stretches.allSatisfy { OutdoorWalk.standingStretches.contains($0) }, "\(stretches)")
        // The coach still says it is over, and every line is a recorded one.
        #expect(plan.lineIDs.contains { $0.hasPrefix("a2.close.") })
        #expect(plan.lineIDs.allSatisfy { texts[$0] != nil })
        #expect(plan.segments.last?.kind == .cooldown)
    }

    @Test func indoorPlansAreUntouchedByTheRules() throws {
        let plan = try SessionBuilder.build(kind: PlannedDay(main: .walk, chairMoves: 0, cooldown: false), level: .inPlace,
                                            intensity: .steady, limits: [], rotationIndex: 0, content: content)
        #expect(plan.lineIDs.contains("a2.setup.inplace.1"))
        #expect(!OutdoorWalk.adapt(plan).lineIDs.contains("a2.setup.inplace.1"))
        #expect(OutdoorWalk.adapt(plan).lineIDs.contains("a2.open.1"))
    }
}
