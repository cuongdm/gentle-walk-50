import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

/// Stage hand-offs added after the 02/10/2026 review: the stand-behind-the-chair gate has a way out
/// and is never bypassed, End from it comes back to it, and remote Play only resumes the session itself.
@MainActor @Suite struct SessionStageFlowTests {
    /// A chair session that has a standing move, played up to just before it.
    func sessionBeforeAStandingMove() async throws -> (WorkoutSessionModel, SessionTimeline.Phase) {
        let standing = Set(TestFixtures.content.exercises.filter(\.standing).map(\.id))
        for rotation in 0..<12 {
            for intensity in [Intensity.steady, .strong] {
                let request = WorkoutRequest(day: PlannedDay(main: .chair, chairMoves: 0, cooldown: false), level: .inPlace,
                                             intensity: intensity, place: .indoors, limits: [], rotationIndex: rotation)
                let session = WorkoutSessionModel(request: request, content: TestFixtures.content, engine: SilentPlaybackEngine(),
                                                  completion: nil, prepareMedia: false)
                try await session.load()
                if let phase = session.player.timeline.phases.first(where: { $0.kind == .move && standing.contains($0.exerciseID ?? "") }) {
                    session.startWithCountdown()
                    session.countdownFinished()
                    return (session, phase)
                }
            }
        }
        throw CocoaError(.featureUnsupported)
    }

    @Test func standingMoveWaitsAndSkipMovesOn() async throws {
        let (session, phase) = try await sessionBeforeAStandingMove()
        session.player.tick(phase.start + 0.1)
        #expect(session.stage == .standBehindChair(exerciseID: phase.exerciseID!))
        #expect(session.player.state == .paused(.getReady))
        let before = session.player.phaseIndex
        session.skipStandingMove()
        #expect(session.player.phaseIndex > before)
        // Either the next part plays, or it is standing too and has its own screen: never a standing
        // move playing without it.
        if case .standBehindChair = session.stage {
            #expect(session.player.state != .playing)
        } else {
            #expect(session.stage == .playing)
            #expect(session.player.state == .playing)
        }
    }

    @Test func keepGoingAfterEndComesBackToTheStandScreen() async throws {
        let (session, phase) = try await sessionBeforeAStandingMove()
        session.player.tick(phase.start + 0.1)
        session.askToEnd()
        #expect(session.stage == .confirmEnd)
        session.keepGoing()
        #expect(session.stage == .standBehindChair(exerciseID: phase.exerciseID!))
        #expect(session.player.state != .playing)
    }

    @Test func remotePlayNeverResumesBehindBreak() async throws {
        let (session, _) = try await sessionBeforeAStandingMove()
        session.takeBreak()
        session.remoteResume()
        #expect(session.player.state == .paused(.breakTaken))
        session.endBreak()
        session.player.pause(.user)
        session.remoteResume()
        #expect(session.player.state == .playing)
    }
}

/// The coach's stop line (A8) on Complete: the session that reaches a stop names it, as its postcard opens.
@MainActor @Suite struct JourneyArrivalLineTests {
    func session() -> WorkoutSessionModel {
        let request = WorkoutRequest(day: PlannedDay(main: .walk, chairMoves: 0, cooldown: true), level: .inPlace,
                                     intensity: .steady, place: .indoors, limits: [], rotationIndex: 0)
        return WorkoutSessionModel(request: request, content: TestFixtures.content, engine: SilentPlaybackEngine(),
                                   completion: nil, prepareMedia: false)
    }

    @Test func completeSaysTheFurthestNewStop() throws {
        let smoky = try #require(TestFixtures.content.journeys.first { $0.id == "jr.smoky" })
        let model = session()
        model.show(CompletionResult(journeyID: smoky.id, unlockedStops: [smoky.stops[1], smoky.stops[2]]), seconds: 600)
        #expect(model.arrivalLineID == "a8.smoky.3")
        let ny = try #require(TestFixtures.content.journeys.first { $0.id == "jr.ny" })
        let first = session()
        first.show(CompletionResult(journeyID: ny.id, unlockedStops: [ny.stops[0]]), seconds: 300)
        #expect(first.arrivalLineID == "a8.ny.1")
    }

    @Test func noLineWithoutANewStopOrAfterStoppingForPain() throws {
        let smoky = try #require(TestFixtures.content.journeys.first { $0.id == "jr.smoky" })
        let none = session()
        none.show(CompletionResult(journeyID: smoky.id, unlockedStops: []), seconds: 600)
        #expect(none.arrivalLineID == nil)
        let hurt = session()
        hurt.markStoppedForPain()
        hurt.show(CompletionResult(journeyID: smoky.id, unlockedStops: [smoky.stops[1]]), seconds: 600)
        #expect(hurt.arrivalLineID == nil)
        // Before Complete there is nothing to say.
        #expect(session().arrivalLineID == nil)
    }
}
