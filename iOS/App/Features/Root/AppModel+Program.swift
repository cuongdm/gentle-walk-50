import Foundation
import GentleWalkCore
import SwiftData

/// The steady program (plan docs/plans/2026-10-08-steady-program.md): the 12 weeks start with the first
/// finished session, the 2-week self-check is free, the rep ladder is Pro.
extension AppModel {
    /// "Later" on the week-0 invite (Complete or Today): asked again two days on.
    nonisolated static let selfCheckDismissedKey = "selfCheckDismissedAt"

    var selfCheckDismissedAt: Date? { defaults.object(forKey: Self.selfCheckDismissedKey) as? Date }

    func selfCheckRecords() -> [SelfCheckRecord] {
        (try? container.mainContext.fetch(FetchDescriptor<SelfCheckRecord>(sortBy: [SortDescriptor(\.date)]))) ?? []
    }

    func selfCheckResults() -> [SelfCheckResult] { selfCheckRecords().map(\.result) }

    func programState() -> ProgramState? {
        (try? container.mainContext.fetch(FetchDescriptor<ProgramState>()))?.first
    }

    /// Week 1 is the week of her first finished session (also for anyone who trained before the program
    /// existed): created on the first reload that finds a session and no program.
    @discardableResult
    func ensureProgram(firstWorkout: Date?) -> ProgramState? {
        if let existing = programState() { return existing }
        guard let firstWorkout else { return nil }
        let state = ProgramState(start: calendar.startOfDay(for: firstWorkout))
        container.mainContext.insert(state)
        try? container.mainContext.save()
        return state
    }

    func selfCheckStatus() -> SelfCheckStatus {
        let first = (try? container.mainContext.fetch(FetchDescriptor<WorkoutRecord>(sortBy: [SortDescriptor(\.date)])))?.first?.date
        return SelfCheckSchedule.status(firstWorkout: first, results: selfCheckResults().map(\.date),
                                        dismissedAt: selfCheckDismissedAt, now: now(), calendar: calendar)
    }

    /// The program week a check done now belongs to: 0 for the first check, then the current week.
    func selfCheckWeek() -> Int {
        guard !selfCheckRecords().isEmpty, let state = programState() else { return 0 }
        switch ProgramCalendar.position(state.programRound, on: now(), calendar: calendar) {
        case .week(let week, _): return week
        case .finished: return ProgramCalendar.weeks
        }
    }

    // MARK: Self-check flow

    /// Opens the self-check (Today card, Complete invite, Program screen).
    func openSelfCheck() {
        let model = SelfCheckFlowModel(history: selfCheckResults(), week: selfCheckWeek(), now: now,
                                       audio: SelfCheckAudioPlayer(content: content, voiceSource: voiceSource))
        cover = .selfCheck(model)
    }

    /// "Not today" / "Later": the week-0 invite waits two days; a due check simply stays on Today.
    func selfCheckLater() {
        if selfCheckRecords().isEmpty { defaults.set(now(), forKey: Self.selfCheckDismissedKey) }
        if case .selfCheck? = cover { cover = nil }
        reload()
    }

    func saveSelfCheck(_ model: SelfCheckFlowModel) {
        model.save(in: container.mainContext)
        reload()
        Task { await notifications.reschedule() }
    }

    func closeSelfCheck() {
        cover = nil
        reload()
    }

    // MARK: Program lifecycle

    /// "Pick up at week 5" after a long break: the days away stop counting.
    func pickUpProgram() {
        guard let state = programState(),
              let last = (try? container.mainContext.fetch(FetchDescriptor<WorkoutRecord>()))?.map(\.date).max() else { return }
        state.apply(ProgramCalendar.pickUp(state.programRound, lastWorkout: last, now: now(), calendar: calendar))
        try? container.mainContext.save()
        // P13: after a long break the ladders start one step lower; the coach says so next time.
        SupportLadderStore(defaults: defaults).stepDownAll()
        RepLadderStore(defaults: defaults).stepDownAll()
        reload()
    }

    /// "Start a new 12 weeks" (finish screen, Me): week 1 from today; self-checks are kept.
    func restartProgram() {
        guard let state = programState() else { return }
        state.apply(ProgramCalendar.restart(state.programRound, on: now(), calendar: calendar))
        state.finishedAt = nil
        try? container.mainContext.save()
        if case .programFinished? = cover { cover = nil }
        todayPath = []
        reload()
    }

    /// "Keep my routine": the 12 weeks are done; Today keeps the weekly plan and the 2-week checks.
    func keepRoutine() {
        guard let state = programState() else { return }
        state.finishedAt = now()
        try? container.mainContext.save()
        if case .programFinished? = cover { cover = nil }
        reload()
    }

    /// The finish screen: her latest check against week 0, done the same way.
    func programFinishedSummary() -> ProgramFinishedSummary {
        let results = selfCheckResults()
        let delta = results.last.map { SelfCheckComparison.delta(latest: $0, history: results) }
        return ProgramFinishedSummary(activeDays: progress.activeDays, checks: results.count,
                                      first: results.first.map(\.count), latest: results.last.map(\.count),
                                      sinceFirst: delta?.sinceFirst)
    }
}

/// What the end of the 12 weeks shows.
struct ProgramFinishedSummary: Equatable {
    var activeDays: Int
    var checks: Int
    var first: Int?
    var latest: Int?
    /// Only when the latest check was done the same way as the first one.
    var sinceFirst: Int?
}
