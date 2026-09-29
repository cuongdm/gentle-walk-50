import Testing
@testable import GentleWalkCore

@Suite struct SessionBuilderTests {
    let content = TestSupport.appContent
    let walkOnly = PlannedDay(main: .walk, chairMoves: 0, cooldown: false)

    @Test(arguments: [
        (WalkLevel.seated, Intensity.gentle, 300),
        (.seated, .steady, 480),
        (.inPlace, .strong, 600),
        (.pad, .steady, 480),
    ])
    func walkLengthFollowsIntensity(_ level: WalkLevel, _ intensity: Intensity, _ seconds: Int) throws {
        let plan = try SessionBuilder.build(kind: walkOnly, level: level, intensity: intensity, limits: [], rotationIndex: 0, content: content)
        #expect(plan.totalSeconds == seconds)
        #expect(plan.segments.contains { $0.kind == .brisk })
    }

    @Test(arguments: [(Intensity.gentle, 4), (.steady, 5), (.strong, 6)])
    func chairDayHasFourToSixMovesWithRestsAndEndsWithCooldown(_ intensity: Intensity, _ moves: Int) throws {
        let day = PlannedDay(main: .chair, chairMoves: 0, cooldown: true)
        let plan = try SessionBuilder.build(kind: day, level: .seated, intensity: intensity, limits: [], rotationIndex: 0, content: content)
        let kinds = plan.segments.map(\.kind)
        #expect(plan.segments.filter { $0.kind == .move }.count == moves)
        #expect(plan.segments.filter { $0.kind == .rest }.allSatisfy { $0.seconds == 20 })
        #expect(kinds.filter { $0 == .rest }.count == moves - 1)
        // Last block is the cool-down stretch set (about 2 minutes).
        let last = try #require(plan.blocks.last)
        #expect(last.kind == .cooldown)
        #expect((100...150).contains(last.seconds))
    }

    @Test(arguments: [(Intensity.gentle, 10), (.steady, 20), (.strong, 30)])
    func stretchDayHasSixToEightPosesHeldPerIntensity(_ intensity: Intensity, _ hold: Int) throws {
        let day = PlannedDay(main: .stretch, chairMoves: 0, cooldown: false)
        let plan = try SessionBuilder.build(kind: day, level: .inPlace, intensity: intensity, limits: [], rotationIndex: 0, content: content)
        let poses = plan.segments.filter { $0.kind == .stretch }
        #expect((6...8).contains(poses.count))
        #expect(plan.holdSeconds == hold)
    }

    @Test func limitsRemoveHiddenPosesAndStandingMoves() throws {
        let stretch = try SessionBuilder.build(kind: PlannedDay(main: .stretch, chairMoves: 0, cooldown: false),
                                               level: .inPlace, intensity: .steady, limits: [.jointReplacement, .standingIsHard],
                                               rotationIndex: 0, content: content)
        #expect(!stretch.exerciseIDs.contains("st.thigh"))
        #expect(!stretch.exerciseIDs.contains("st.calf"))
        #expect((6...8).contains(stretch.segments.filter { $0.kind == .stretch }.count))

        let chair = try SessionBuilder.build(kind: PlannedDay(main: .chair, chairMoves: 0, cooldown: true),
                                             level: .seated, intensity: .strong, limits: [.standingIsHard],
                                             rotationIndex: 0, content: content)
        #expect(!chair.exerciseIDs.contains("mv.wall-push"))
        #expect(chair.segments.filter { $0.kind == .move }.count == 5)  // only 5 moves allowed
    }

    @Test func easierVersionsFollowBodyLimits() throws {
        let plan = try SessionBuilder.build(kind: PlannedDay(main: .chair, chairMoves: 0, cooldown: true),
                                            level: .seated, intensity: .strong, limits: [.knees], rotationIndex: 0, content: content)
        #expect(plan.easierExerciseIDs.contains("mv.sit-to-stand"))
        #expect(!plan.easierExerciseIDs.contains("mv.heel-toe"))
    }

    @Test func walkDayAddsChairMovesAndCooldown() throws {
        let day = PlannedDay(main: .walk, chairMoves: 2, cooldown: true)
        let plan = try SessionBuilder.build(kind: day, level: .seated, intensity: .gentle, limits: [], rotationIndex: 0, content: content)
        #expect(plan.blocks.map(\.kind) == [.walk, .chair, .cooldown])
        #expect(plan.segments.filter { $0.kind == .move }.count == 2)
    }

    @Test func longWalkAddsOneMoreRound() throws {
        let plan = try SessionBuilder.build(kind: PlannedDay(main: .longWalk, chairMoves: 0, cooldown: false),
                                            level: .seated, intensity: .steady, limits: [], rotationIndex: 0, content: content)
        #expect(plan.totalSeconds == 480 + 120)
        #expect(plan.segments.filter { $0.kind == .brisk }.count == 3)
    }

    @Test func rotationNeverRepeatsTheSameChairDayTwiceInARowOver28Days() throws {
        let day = PlannedDay(main: .chair, chairMoves: 0, cooldown: true)
        let plans = try (0..<28).map {
            try SessionBuilder.build(kind: day, level: .seated, intensity: .steady, limits: [], rotationIndex: $0, content: content)
        }
        for (a, b) in zip(plans, plans.dropFirst()) {
            #expect(a.exerciseIDs != b.exerciseIDs)
        }
        let used = Set(plans.flatMap(\.exerciseIDs).filter { $0.hasPrefix("mv.") })
        #expect(used.count == 6)
    }

    @Test func rotationVariesWalkVoiceLines() throws {
        let a = try SessionBuilder.build(kind: walkOnly, level: .seated, intensity: .steady, limits: [], rotationIndex: 0, content: content)
        let b = try SessionBuilder.build(kind: walkOnly, level: .seated, intensity: .steady, limits: [], rotationIndex: 1, content: content)
        #expect(a.lineIDs != b.lineIDs)
        let known = Set(content.voiceLines.map(\.id))
        #expect(Set(a.lineIDs + b.lineIDs).isSubset(of: known))
    }
}
