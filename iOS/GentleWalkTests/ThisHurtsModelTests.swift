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

    /// A tap on This hurts by mistake: back to the session, nothing recorded (clarity review D14).
    @Test func goingBackRecordsNothing() async throws {
        let (player, engine, _) = try await chairPlayer()
        let recorder = FakePainRecorder()
        let model = ThisHurtsModel(player: player, recorder: recorder, now: { TestSupportDate.now })
        player.pause(.hurts)
        let outcome = model.goBack()
        #expect(outcome == .continueSession)
        #expect(recorder.reports.isEmpty)
        #expect(engine.loaded.count == 1)
        #expect(player.state == .playing)
    }

    @Test func onAWalkTheChoicesTalkAboutTheWalk() async throws {
        let (player, _, _) = try await chairPlayer()
        let model = ThisHurtsModel(player: player, recorder: FakePainRecorder(), now: { TestSupportDate.now })
        #expect(!model.isWalk)
        let engine = FakePlaybackEngine()
        let walk = SessionPlayer(engine: engine, notificationCenter: .init())
        try await walk.load(TestFixtures.firstWalkTimeline())
        walk.play()
        engine.advance(to: 60)
        #expect(ThisHurtsModel(player: walk, recorder: FakePainRecorder(), now: { TestSupportDate.now }).isWalk)
    }

    /// A walking move (march, side step…) is still the walk: "easier" slows a quicker part to easy.
    @Test func walkMovesKeepTheWalkChoices() async throws {
        let content = TestFixtures.content
        let plan = try SessionBuilder.build(kind: PlannedDay(main: .walk, chairMoves: 0, cooldown: false), level: .inPlace,
                                            intensity: .steady, limits: [], rotationIndex: 0, content: content)
        let engine = FakePlaybackEngine()
        let player = SessionPlayer(engine: engine, notificationCenter: .init())
        try await player.load(SessionTimeline.make(plan: plan, voice: content.voiceLines))
        player.play()
        let brisk = try #require(player.timeline.phases.first { $0.kind == .brisk })
        engine.advance(to: brisk.start + 5)
        let recorder = FakePainRecorder()
        let model = ThisHurtsModel(player: player, recorder: recorder, now: { TestSupportDate.now })
        #expect(model.isWalk)
        _ = await model.showEasier()
        #expect(player.currentPhase?.kind == .easy)
        #expect(recorder.reports.first?.exerciseID == "wk.march")
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
