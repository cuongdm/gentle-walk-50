import Foundation
import Observation
import SwiftData
import GentleWalkCore

/// Plays the 30-second self-check audio; calls `onPlaying` when the program actually starts, so the
/// clock on screen and the voice share one start.
@MainActor protocol SelfCheckAudioPlaying: AnyObject {
    func start(onPlaying: @escaping @MainActor () -> Void)
    func stop()
}

/// The 2-week self-check (steady program tasks 4.5–4.9): safety intro → 30 seconds → her count → saved.
/// Self-counted, compared only with her own checks done the same way; general fitness, not a medical
/// test (docs/design/steady-claims.md).
@Observable @MainActor final class SelfCheckFlowModel {
    enum Step: Equatable {
        case intro
        case timer
        case count
        /// This hurts: stopped, nothing saved.
        case stopped
        case saved(SelfCheckDelta)
    }

    enum TimerPhase: Equatable {
        /// Before "Go": 0 while the setup line plays, then 3, 2, 1.
        case getReady(Int)
        case counting(secondsLeft: Int)
        case done
    }

    let id = UUID()
    private(set) var step: Step = .intro
    private(set) var count: Int
    private(set) var usedHands: Bool
    /// When the audio started (the screen's clock counts from here); nil while it is being prepared.
    private(set) var startedAt: Date?

    @ObservationIgnored let history: [SelfCheckResult]
    @ObservationIgnored let week: Int
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let audio: SelfCheckAudioPlaying?

    /// Starting count when she has nothing to compare with.
    static let firstGuess = 8

    init(history: [SelfCheckResult], week: Int, now: @escaping () -> Date = Date.init, audio: SelfCheckAudioPlaying? = nil) {
        self.history = history.sorted { $0.date < $1.date }
        self.week = week
        self.now = now
        self.audio = audio
        let hands = history.max { $0.date < $1.date }?.usedHands ?? false
        usedHands = hands
        count = history.filter { $0.usedHands == hands }.max { $0.date < $1.date }?.count ?? Self.firstGuess
    }

    /// Her latest check done the same way ("Last time: 8"); nil if none.
    var lastTime: Int? { history.last { $0.usedHands == usedHands }?.count }

    // MARK: Timer

    func ready() {
        step = .timer
        startedAt = nil
        if let audio {
            audio.start { [weak self] in
                guard let self, self.step == .timer else { return }
                self.startedAt = self.now()
            }
        } else {
            startedAt = now()
        }
    }

    /// When the 30 seconds end, for the timer screen's wait.
    var timerEnds: Date? {
        startedAt?.addingTimeInterval(SessionTimeline.selfCheckGoAt + SessionTimeline.selfCheckSeconds)
    }

    func timerPhase(at date: Date) -> TimerPhase {
        guard let startedAt else { return .getReady(0) }
        let t = date.timeIntervalSince(startedAt)
        let go = SessionTimeline.selfCheckGoAt
        if t < go - 3 { return .getReady(0) }
        if t < go { return .getReady(Int((go - t).rounded(.up))) }
        let left = SessionTimeline.selfCheckSeconds - (t - go)
        return left > 0 ? .counting(secondsLeft: Int(left.rounded(.up))) : .done
    }

    /// The 30 seconds are up: the stop line keeps playing while she enters her count.
    func timerFinished() {
        guard step == .timer else { return }
        step = .count
    }

    func stopEarly() {
        audio?.stop()
        step = .count
    }

    func hurts() {
        audio?.stop()
        step = .stopped
    }

    func again() { ready() }

    // MARK: Count

    func increment() { count = min(count + 1, SelfCheckComparison.countRange.upperBound) }
    func decrement() { count = max(count - 1, SelfCheckComparison.countRange.lowerBound) }

    func setUsedHands(_ value: Bool) { usedHands = value }

    var canSave: Bool { SelfCheckComparison.isValid(count) }

    @discardableResult
    func save(in context: ModelContext) -> SelfCheckResult? {
        guard canSave, step == .count else { return nil }
        audio?.stop()
        let result = SelfCheckResult(date: now(), count: count, usedHands: usedHands)
        context.insert(SelfCheckRecord(date: result.date, count: result.count, usedHands: result.usedHands, week: week))
        try? context.save()
        step = .saved(SelfCheckComparison.delta(latest: result, history: history))
        return result
    }

    /// Not today, close, or the cover going away.
    func close() { audio?.stop() }

    /// What the saved screen says about the change, against herself only.
    static func deltaLine(_ delta: SelfCheckDelta, isFirst: Bool) -> String {
        if isFirst { return String(localized: "This is where you start. In two weeks, you can compare.") }
        if delta.newMethodBaseline {
            return String(localized: "Your first check done this way. Next time, you can compare.")
        }
        guard let sinceFirst = delta.sinceFirst else { return "" }
        if sinceFirst > 0 { return String(localized: "\(sinceFirst) more than your first check.") }
        if sinceFirst == 0 { return String(localized: "The same as your first check. Steady is good.") }
        return String(localized: "Some days are like that. What counts is that you keep going.")
    }
}
