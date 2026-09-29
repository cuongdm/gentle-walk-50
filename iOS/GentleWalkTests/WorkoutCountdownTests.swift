import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

/// 3-2-1 before a session: nothing plays until the count ends or she skips it.
@MainActor struct WorkoutCountdownTests {
    func loadedSession() async throws -> WorkoutSessionModel {
        let request = WorkoutRequest(day: PlannedDay(main: .walk, chairMoves: 0, cooldown: false), level: .seated,
                                     intensity: .gentle, place: .indoors, limits: [], rotationIndex: 0)
        let session = WorkoutSessionModel(request: request, content: TestFixtures.content, engine: SilentPlaybackEngine(),
                                          completion: nil, prepareMedia: false)
        try await session.load()
        return session
    }

    @Test func theCountdownHoldsPlaybackUntilItEnds() async throws {
        let session = try await loadedSession()
        session.startWithCountdown()
        #expect(session.stage == .countdown)
        #expect(session.player.state != .playing)

        session.countdownFinished()
        #expect(session.stage == .playing)
        #expect(session.player.state == .playing)
    }

    @Test func aLateTickAfterTheStartChangesNothing() async throws {
        let session = try await loadedSession()
        session.startWithCountdown()
        session.countdownFinished()
        session.togglePause()
        session.countdownFinished()
        #expect(session.player.state == .paused(.user))
    }
}
