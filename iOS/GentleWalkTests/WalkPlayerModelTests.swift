import Testing
import GentleWalkCore
@testable import GentleWalk

@MainActor @Suite struct WalkPlayerModelTests {
    /// Strong seated walk: warm-up 2:00, three rounds of 1:00 brisk + 1:00 easy, cool-down 2:00 (10:00).
    func model(at seconds: Double) async throws -> WalkPlayerModel {
        let content = TestFixtures.content
        let plan = try SessionBuilder.build(kind: PlannedDay(main: .walk, chairMoves: 0, cooldown: false), level: .seated,
                                            intensity: .strong, limits: [], rotationIndex: 0, content: content)
        let engine = FakePlaybackEngine()
        let player = SessionPlayer(engine: engine, notificationCenter: .init())
        try await player.load(SessionTimeline.make(plan: plan, voice: content.voiceLines))
        player.play()
        engine.advance(to: seconds)
        return WalkPlayerModel(player: player, level: .seated)
    }

    @Test func briskRoundTwo() async throws {
        let model = try await model(at: 246)
        #expect(model.phaseLabel == "BRISK WALK")
        #expect(model.tone == .brisk)
        #expect(model.clock == "00:54")
        // The top line is the whole session; the big clock is this part (clarity review D11).
        #expect(model.statusLine == "Round 2 of 3 · 5:54 left in total")
        #expect(model.nextLine == "Next: easy walk · 1:00")
    }

    @Test func warmUpAndCoolDownLines() async throws {
        let warm = try await model(at: 34)
        // The warm-up is called the warm-up on the big label too.
        #expect(warm.phaseLabel == "WARM-UP")
        #expect(warm.tone == .easy)
        #expect(warm.clock == "01:26")
        #expect(warm.statusLine == "Warm-up · 9:26 left in total")
        #expect(warm.nextLine == "Next: brisk walk · 1:00")

        let cool = try await model(at: 540)
        #expect(cool.phaseLabel == "COOL-DOWN")
        #expect(cool.statusLine == "Cool-down · 1:00 left in total")
        #expect(cool.nextLine == nil)
    }

    @Test func captionFollowsThePlayer() async throws {
        let model = try await model(at: 121.5)
        #expect(model.captionText?.isEmpty == false)
        #expect(model.captionText == model.player.caption?.text)
        #expect((0...1).contains(model.phaseProgress))
    }
}
