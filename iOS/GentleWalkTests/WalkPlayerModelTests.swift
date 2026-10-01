import Testing
import GentleWalkCore
@testable import GentleWalk

@MainActor @Suite struct WalkPlayerModelTests {
    /// Strong walk (content plan 30/09/2026): warm-up 2:00, six moves of 0:30 easy + 0:30 quicker, cool-down.
    func model(at seconds: Double, level: WalkLevel = .seated) async throws -> WalkPlayerModel {
        let content = TestFixtures.content
        let plan = try SessionBuilder.build(kind: PlannedDay(main: .walk, chairMoves: 0, cooldown: false), level: level,
                                            intensity: .strong, limits: [], rotationIndex: 0, content: content)
        let engine = FakePlaybackEngine()
        let player = SessionPlayer(engine: engine, notificationCenter: .init())
        try await player.load(SessionTimeline.make(plan: plan, voice: content.voiceLines))
        player.play()
        engine.advance(to: seconds)
        let exercises = Dictionary(uniqueKeysWithValues: content.exercises.map { ($0.id, $0) })
        return WalkPlayerModel(player: player, level: level, exercises: exercises)
    }

    @Test func quickerPartIsQuickerSeatedAndBriskStanding() async throws {
        // Second move (side step), its quicker half: 2:00 + 0:30 + 0:30 + 0:30 + 5 s.
        let seated = try await model(at: 215)
        #expect(seated.phaseLabel == "QUICKER")
        #expect(seated.tone == .brisk)
        #expect(seated.clock == "00:25")
        #expect(seated.statusLine.hasPrefix("Round 2 of 6 · "))
        #expect(seated.nextLine == "Next: easy walk · 0:30")
        #expect(seated.move?.id == "wk.side-step")
        #expect(seated.levelNote == "Seated · Side step")

        let standing = try await model(at: 215, level: .inPlace)
        #expect(standing.phaseLabel == "BRISK WALK")
        #expect(standing.levelNote == "In place · Side step")
    }

    @Test func warmUpAndCoolDownLines() async throws {
        let warm = try await model(at: 34)
        #expect(warm.phaseLabel == "WARM-UP")
        #expect(warm.tone == .easy)
        #expect(warm.clock == "01:26")
        #expect(warm.statusLine.hasPrefix("Warm-up · "))
        #expect(warm.nextLine == "Next: easy walk · 0:30")
        // The warm-up marches.
        #expect(warm.move?.id == "wk.march")

        let total = warm.player.timeline.total
        let cool = try await model(at: total - 5)
        #expect(cool.phaseLabel == "COOL-DOWN")
        #expect(cool.statusLine == "Cool-down · 0:05 left in total")
        #expect(cool.nextLine == nil)
        // The last part of the cool-down is the chest stretch.
        #expect(cool.move?.id == "st.chest")
    }

    @Test func clipFollowsTheMoveAndPace() async throws {
        let quicker = try await model(at: 215)
        let move = try #require(quicker.move)
        #expect(quicker.videoFile(isOutdoors: false) == ExerciseVideo.firstBundled(move.videoCandidates(level: .seated, pace: .quicker)))
        #expect(quicker.videoFile(isOutdoors: true) == nil)
        // The seated march clip ships with the app.
        let warm = try await model(at: 34)
        #expect(warm.videoFile(isOutdoors: false)?.hasPrefix("W1-1") == true)
    }

    @Test func captionFollowsThePlayer() async throws {
        let model = try await model(at: 121.5)
        #expect(model.captionText?.isEmpty == false)
        #expect(model.captionText == model.player.caption?.text)
        #expect((0...1).contains(model.phaseProgress))
    }
}
