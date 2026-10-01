import Testing
@testable import GentleWalkCore

/// Competitor ideas (30/09/2026): progress per move, move introductions off, the next tree milestone.
@Suite struct PlayerGuidanceTests {
    let content = TestSupport.appContent

    func chairDay() throws -> SessionPlan {
        try SessionBuilder.build(kind: PlannedDay(main: .chair, chairMoves: 0, cooldown: false), level: .seated,
                                 intensity: .gentle, limits: [], rotationIndex: 0, content: content)
    }

    @Test func progressCountsTheMovesOfTheCurrentBlock() throws {
        let timeline = SessionTimeline.make(plan: try chairDay(), voice: content.voiceLines)
        let moves = timeline.phases.filter { $0.isExercise && $0.block == .chair }
        #expect(moves.count >= 3)

        // Halfway through the second move: one done, the second half full.
        let second = moves[1]
        let middle = (second.start + second.end) / 2
        let progress = try #require(timeline.moveProgress(at: middle))
        #expect(progress.count == moves.count)
        #expect(progress.index == 1)
        #expect(abs(progress.fraction - 0.5) < 0.01)

        // During the rest before the third move: two done, the third not started.
        let rest = try #require(timeline.phases.first { $0.kind == .rest && $0.start >= moves[1].end })
        let resting = try #require(timeline.moveProgress(at: rest.start + 1))
        #expect(resting.index == 2)
        #expect(resting.fraction == 0)

        // A walk has no moves.
        let walk = try SessionBuilder.build(kind: PlannedDay(main: .walk, chairMoves: 0, cooldown: false), level: .seated,
                                            intensity: .gentle, limits: [], rotationIndex: 0, content: content)
        #expect(SessionTimeline.make(plan: walk, voice: content.voiceLines).moveProgress(at: 60) == nil)
    }

    @Test func movesCanStartWithoutTheirIntroduction() throws {
        let plan = try chairDay()
        let trimmed = plan.withoutMoveIntroductions()
        let moves = plan.segments.filter { $0.kind == .move }
        let trimmedMoves = trimmed.segments.filter { $0.kind == .move }
        #expect(moves.count == trimmedMoves.count)
        for (move, short) in zip(moves, trimmedMoves) {
            // The opening line ("Sit-to-stand. It helps with getting up from any chair.") is gone,
            // the instructions stay, and the move keeps its length.
            #expect(short.cues.count == move.cues.count - 1)
            #expect(short.cues.first?.line == move.cues.dropFirst().first?.line)
            #expect(short.seconds == move.seconds)
        }
        #expect(trimmed.totalSeconds == plan.totalSeconds)
        // Walks are untouched.
        let walk = try SessionBuilder.build(kind: PlannedDay(main: .walk, chairMoves: 0, cooldown: false), level: .seated,
                                            intensity: .gentle, limits: [], rotationIndex: 0, content: content)
        #expect(walk.withoutMoveIntroductions() == walk)
    }

    @Test func balanceKeepsItsOpeningsWhenIntroductionsAreOff() throws {
        let balance = try SessionBuilder.build(kind: PlannedDay(main: .chair, chairMoves: 0, cooldown: false), level: .seated,
                                               intensity: .gentle, limits: [], rotationIndex: 0, content: content,
                                               variant: SessionBuilder.Variant.balance)
        #expect(balance.withoutMoveIntroductions() == balance)
        #expect(SessionPlan.isMoveIntroduction("a4.v1.1"))
        #expect(SessionPlan.isMoveIntroduction("a4.side-leg.intro"))
        #expect(!SessionPlan.isMoveIntroduction("a4.v1.2"))
        #expect(!SessionPlan.isMoveIntroduction("a11.tandem.intro"))
    }

    @Test(arguments: [
        (0, 0, 7, TreeLevel.sprout), (5, 5, 7, .sprout), (7, 0, 14, .sapling), (13, 6, 14, .sapling),
        (21, 0, 21, .tree), (40, 19, 21, .tree),
    ])
    func milestoneCountsFromTheLastLevel(_ days: Int, _ done: Int, _ total: Int, _ next: TreeLevel) throws {
        let milestone = try #require(TreeLevel.milestone(activeDays: days))
        #expect(milestone.done == done)
        #expect(milestone.total == total)
        #expect(milestone.next == next)
    }

    @Test func afterTheTreeTheMilestoneIsTheNextRing() {
        // 42 days: tree grown; rings every 42 days, so 0 of 42.
        let ring = TreeLevel.milestone(activeDays: 50)
        #expect(ring?.next == nil)
        #expect(ring?.done == 8)
        #expect(ring?.total == 42)
    }
}
