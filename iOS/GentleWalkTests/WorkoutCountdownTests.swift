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

    /// Owner 30/09/2026: ended in under a minute, nothing is saved and nobody is congratulated.
    @Test func endingInUnderAMinuteSavesNothing() async throws {
        let session = try await loadedSession()
        session.startWithCountdown()
        session.countdownFinished()
        session.player.tick(30)
        await session.finish()
        #expect(session.stage == .notSaved)
    }

    @Test func aMinuteOrMoreCounts() async throws {
        let session = try await loadedSession()
        session.startWithCountdown()
        session.countdownFinished()
        session.player.tick(75)
        await session.finish()
        #expect(session.isComplete)
    }

    /// Stopping because something hurts always counts ("Today still counts").
    @Test func stoppingForPainCountsEvenWhenShort() async throws {
        let session = try await loadedSession()
        session.startWithCountdown()
        session.countdownFinished()
        session.player.tick(20)
        await session.closeHurts(.endSession(counts: true))
        #expect(session.isComplete)
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
