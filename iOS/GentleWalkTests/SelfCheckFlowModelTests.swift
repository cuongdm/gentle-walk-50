import Foundation
import SwiftData
import Testing
import GentleWalkCore
@testable import GentleWalk

/// Audio stand-in: starts at once (or when told), records stops.
@MainActor final class FakeSelfCheckAudio: SelfCheckAudioPlaying {
    var startsImmediately = true
    private(set) var pending: (@MainActor () -> Void)?
    private(set) var stops = 0

    func start(onPlaying: @escaping @MainActor () -> Void) {
        if startsImmediately { onPlaying() } else { pending = onPlaying }
    }
    func stop() { stops += 1 }
    func begin() { pending?(); pending = nil }
}

/// The 2-week self-check flow (steady program task 4.5).
@MainActor @Suite(.serialized) struct SelfCheckFlowModelTests {
    let start = Date(timeIntervalSince1970: 1_791_000_000)

    func check(_ daysAgo: Double, _ count: Int, hands: Bool) -> SelfCheckResult {
        SelfCheckResult(date: start.addingTimeInterval(-daysAgo * 86_400), count: count, usedHands: hands)
    }

    @Test func flowIntroTimerCountSave() throws {
        let container = try ModelContainerFactory.make(inMemory: true)
        var clock = start
        let audio = FakeSelfCheckAudio()
        let model = SelfCheckFlowModel(history: [check(14, 7, hands: true)], week: 2, now: { clock }, audio: audio)
        #expect(model.step == .intro)
        #expect(model.count == 7)
        #expect(model.usedHands)
        #expect(model.lastTime == 7)

        model.ready()
        #expect(model.step == .timer)
        #expect(model.timerPhase(at: clock) == .getReady(0))
        #expect(model.timerPhase(at: clock.addingTimeInterval(SessionTimeline.selfCheckGoAt - 2.5)) == .getReady(3))
        #expect(model.timerPhase(at: clock.addingTimeInterval(SessionTimeline.selfCheckGoAt + 0.1)) == .counting(secondsLeft: 30))
        #expect(model.timerPhase(at: clock.addingTimeInterval(SessionTimeline.selfCheckGoAt + 30)) == .done)
        #expect(model.timerEnds == clock.addingTimeInterval(SessionTimeline.selfCheckGoAt + 30))

        clock = clock.addingTimeInterval(40)
        model.timerFinished()
        #expect(model.step == .count)
        model.increment()
        model.increment()
        let saved = try #require(model.save(in: container.mainContext))
        #expect(saved.count == 9)
        let rows = try container.mainContext.fetch(FetchDescriptor<SelfCheckRecord>())
        #expect(rows.count == 1)
        #expect(rows.first?.week == 2)
        #expect(rows.first?.usedHands == true)
        #expect(model.step == .saved(SelfCheckDelta(sinceFirst: 2, sinceLast: 2, newMethodBaseline: false)))
        #expect(SelfCheckFlowModel.deltaLine(SelfCheckDelta(sinceFirst: 2, sinceLast: 2, newMethodBaseline: false), isFirst: false)
            == "2 more than your first check.")
    }

    /// The clock starts with the audio, not when "I'm ready" is tapped.
    @Test func clockWaitsForTheAudio() {
        var clock = start
        let audio = FakeSelfCheckAudio()
        audio.startsImmediately = false
        let model = SelfCheckFlowModel(history: [], week: 0, now: { clock }, audio: audio)
        model.ready()
        #expect(model.startedAt == nil)
        #expect(model.timerPhase(at: clock.addingTimeInterval(60)) == .getReady(0))
        clock = clock.addingTimeInterval(2)
        audio.begin()
        #expect(model.startedAt == clock)
    }

    @Test func notTodayAndHurtsStopTheAudio() {
        let audio = FakeSelfCheckAudio()
        let model = SelfCheckFlowModel(history: [], week: 0, now: { self.start }, audio: audio)
        model.ready()
        model.hurts()
        #expect(model.step == .stopped)
        #expect(audio.stops == 1)
        model.close()
        #expect(audio.stops == 2)
    }

    @Test func countStaysInRange() {
        let model = SelfCheckFlowModel(history: [], week: 0, now: { self.start })
        #expect(model.count == SelfCheckFlowModel.firstGuess)
        for _ in 0..<60 { model.increment() }
        #expect(model.count == SelfCheckComparison.countRange.upperBound)
        for _ in 0..<60 { model.decrement() }
        #expect(model.count == 0)
        #expect(model.canSave)
    }

    /// "Last time" and the starting count follow the way she does it (hands or not).
    @Test func defaultsFollowTheSameWay() {
        let history = [check(28, 6, hands: true), check(14, 9, hands: false)]
        let model = SelfCheckFlowModel(history: history, week: 4, now: { self.start })
        #expect(!model.usedHands)
        #expect(model.count == 9)
        model.setUsedHands(true)
        #expect(model.lastTime == 6)
    }

    /// Nothing is saved before the count step (a double tap on Save after Done is ignored too).
    @Test func savesOnlyFromTheCountStep() throws {
        let container = try ModelContainerFactory.make(inMemory: true)
        let model = SelfCheckFlowModel(history: [], week: 0, now: { self.start })
        #expect(model.save(in: container.mainContext) == nil)
        model.ready()
        model.stopEarly()
        #expect(model.save(in: container.mainContext) != nil)
        #expect(model.save(in: container.mainContext) == nil)
        #expect(try container.mainContext.fetchCount(FetchDescriptor<SelfCheckRecord>()) == 1)
    }
}
