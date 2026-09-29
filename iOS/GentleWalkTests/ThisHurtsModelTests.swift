import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

@MainActor final class FakePainRecorder: PainReportRecording {
    private(set) var reports: [PainReportSnapshot] = []
    func record(_ report: PainReportSnapshot) { reports.append(report) }
}

@MainActor @Suite struct ThisHurtsModelTests {
    func chairPlayer() async throws -> (SessionPlayer, FakePlaybackEngine, SessionTimeline.Phase) {
        let content = TestFixtures.content
        let plan = try SessionBuilder.build(kind: PlannedDay(main: .chair, chairMoves: 0, cooldown: true), level: .seated,
                                            intensity: .gentle, limits: [], rotationIndex: 0, content: content)
        let engine = FakePlaybackEngine()
        let player = SessionPlayer(engine: engine, notificationCenter: .init())
        try await player.load(SessionTimeline.make(plan: plan, voice: content.voiceLines))
        player.play()
        let move = player.timeline.phases.first { $0.kind == .move }!
        engine.advance(to: move.start + 15)
        return (player, engine, move)
    }

    @Test func kneeAndEasierVersionRecordsAndSwaps() async throws {
        let (player, engine, move) = try await chairPlayer()
        let recorder = FakePainRecorder()
        let model = ThisHurtsModel(player: player, recorder: recorder, now: { TestSupportDate.now })
        model.area = .knee
        let outcome = await model.showEasier()
        #expect(outcome == .continueSession)
        #expect(recorder.reports == [PainReportSnapshot(date: TestSupportDate.now, area: .knees, exerciseID: move.exerciseID)])
        #expect(engine.loaded.count == 2)
        #expect(player.currentPhase?.isEasier == true)
    }

    @Test func stopForTodayEndsTheSessionAndStillCounts() async throws {
        let (player, _, _) = try await chairPlayer()
        let recorder = FakePainRecorder()
        let model = ThisHurtsModel(player: player, recorder: recorder, now: { TestSupportDate.now })
        model.area = .back
        #expect(model.stopForToday() == .endSession(counts: true))
        #expect(player.state == .finished)
        #expect(recorder.reports.map(\.area) == [.lowerBack])
    }

    @Test func noAreaChosenIsRecordedAsSomewhereElse() async throws {
        let (player, _, _) = try await chairPlayer()
        let recorder = FakePainRecorder()
        let model = ThisHurtsModel(player: player, recorder: recorder, now: { TestSupportDate.now })
        _ = await model.skipMove()
        #expect(recorder.reports.map(\.area) == [.other])
    }
}

enum TestSupportDate {
    static let now = Date(timeIntervalSince1970: 1_790_000_000)
}
