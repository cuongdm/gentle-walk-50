import Foundation
import GentleWalkCore
import SwiftData

/// A move her pain reports set aside (P3), for Me → "Moves set aside".
struct SetAsideMove: Identifiable, Equatable {
    var id: String
    var name: String
    /// When it comes back by itself.
    var back: Date
}

/// Today's busy-day answer (P11), worked out once a day from Apple Health.
struct BusyDayCache: Equatable {
    var day: Date
    var isBusy: Bool
}

/// Personalisation P1–P13 (docs/plans/2026-10-08-ui-onboarding-personalization.md, milestone 4): what she
/// tells the app and what she does change her sessions, the coach's lines and Today. Everything stays on
/// the phone (UserDefaults stores in `PersonalisationStores.swift`, cleared by "Delete all my data").
extension AppModel {
    var exerciseMemory: ExerciseMemoryStore { ExerciseMemoryStore(defaults: defaults) }
    var weeklyNoteStore: WeeklyNoteStore { WeeklyNoteStore(defaults: defaults) }
    var sessionHabits: SessionHabitStore { SessionHabitStore(defaults: defaults) }

    // MARK: Moves (P3, P5, P12)

    /// Moves set aside or started easier by her pain reports, and moves she chose Easier twice lately.
    func exerciseRules(now: Date) -> ExerciseRules {
        let memory = exerciseMemory.memory
        let window = Double(PainRules.setAsideWindowDays + PainRules.setAsideDays) * 86_400
        let reports = painRecorder.snapshots(since: now.addingTimeInterval(-window))
        return PainRules.exerciseRules(reports: reports, now: now, restored: memory.restored)
            .merging(memory.exerciseRules(now: now))
    }

    /// Her rules and remembered swaps on any session she starts (not the First Walk: it is set).
    func personalised(_ request: WorkoutRequest) -> WorkoutRequest {
        guard !request.isFirstWalk else { return request }
        var request = request
        request.exerciseRules = exerciseRules(now: now())
        request.swapMemory = exerciseMemory.memory.activeSwaps(now: now())
        return request
    }

    /// Me → "Moves set aside", soonest back first.
    var setAsideMoves: [SetAsideMove] {
        exerciseRules(now: now()).setAside.compactMap { id, back in
            content.exercises.first { $0.id == id }.map { SetAsideMove(id: id, name: $0.name, back: back) }
        }
        .sorted { ($0.back, $0.id) < ($1.back, $1.id) }
    }

    /// "Bring it back": the move plays again; reports before now no longer count.
    func bringBack(_ exerciseID: String) {
        exerciseMemory.update { $0.restore(exerciseID, at: now()) }
        reload()
    }

    /// Wires a session to the memory: Easier taps, "Try the usual one", the Pro note, and what the habit
    /// signals need once it is saved.
    func attachMemory(to session: WorkoutSessionModel, request: WorkoutRequest, plannedSeconds: Int) {
        let memory = exerciseMemory.memory
        let chosen = memory.defaultsEasier(now: now())
        var reasons: [String: WorkoutSessionModel.EasierReason] = [:]
        for id in request.exerciseRules.easier { reasons[id] = chosen.contains(id) ? .chosen : .hurt }
        session.rememberedEasier = reasons
        session.isPro = isPro
        session.offersHarderProNote = !isPro && !memory.harderProNoteShown
        let store = exerciseMemory
        let now = now
        session.onEasierChosen = { id in store.update { $0.noteEasier(id, at: now()) } }
        session.onUsualVersion = { id in store.update { $0.useUsualVersion(id) } }
        session.onHarderProNoteShown = { store.update { $0.harderProNoteShown = true } }
        session.onAddLimit = { [weak self] limit in
            self?.updateProfile { profile in
                if !profile.bodyLimits.contains(limit.rawValue) { profile.bodyLimits.append(limit.rawValue) }
            }
        }
        let habits = sessionHabits
        let isExtra = request.presetID.flatMap(SessionCatalog.preset(id:))?.group == .extras
        session.onSaved = { result in
            habits.add(SessionHabit(recordID: result.recordID, date: now(), plannedSeconds: plannedSeconds, isExtra: isExtra))
        }
    }

    // MARK: Self-check trend (P9)

    var selfCheckTrend: SelfCheckTrend {
        SelfCheckComparison.trend(history: selfCheckResults(), now: now(), calendar: calendar)
    }

    // MARK: Weekly check-in (P6)

    var weekEffects: WeekEffects {
        WeeklyCheckIn.effects(of: WeeklyCheckIn.current(notes: weeklyNoteStore.notes, now: now(), calendar: calendar))
    }

    /// The first open from Sunday to Tuesday asks about last week, once (D11). Never over another screen.
    func offerWeeklyCheckInIfDue() {
        guard cover == nil, onboardingDone else { return }
        let workouts = ((try? container.mainContext.fetch(FetchDescriptor<WorkoutRecord>())) ?? []).map(\.date)
        guard WeeklyCheckIn.isDue(now: now(), notes: weeklyNoteStore.notes, workouts: workouts, calendar: calendar) else { return }
        cover = .weeklyCheckIn
    }

    /// Her answer (or Skip, `effort == nil`): it shapes the rest of this week and next week.
    func saveWeeklyCheckIn(effort: WeeklyEffort?, better: BetterChip?) {
        if let week = WeeklyCheckIn.reviewedWeek(now: now(), calendar: calendar) {
            weeklyNoteStore.add(WeeklyNote(weekStart: week, effort: effort, better: effort == nil ? nil : better,
                                           answeredAt: now()))
        }
        if case .weeklyCheckIn? = cover { cover = nil }
        reload()
    }

    // MARK: Habits (P10)

    /// "Move your reminder to 9:15?" and "shorter / longer" from what she actually does.
    func habitSignals(records: [WorkoutRecord], reminderMinutes: Int) -> (reminder: Int?, length: LengthSignal?) {
        let habits = sessionHabits.habits
        let byID = Dictionary(habits.map { ($0.recordID, $0) }, uniquingKeysWith: { first, _ in first })
        let main = records.filter { byID[$0.id]?.isExtra != true && $0.kind != "firstWalk" }
        var reminder: Int?
        let answered = sessionHabits.reminderAnsweredAt.map { now().timeIntervalSince($0) < 30 * 86_400 } ?? false
        if !answered {
            reminder = HabitSignals.suggestedReminderMinutes(starts: main.map { $0.date.addingTimeInterval(-Double($0.activeSeconds)) },
                                                             reminderMinutes: reminderMinutes, calendar: calendar)
        }
        let oldest = main.suffix(3).first?.date.addingTimeInterval(-3_600) ?? now()
        let pains = painRecorder.snapshots(since: oldest)
        let timings = main.suffix(3).compactMap { record -> SessionTiming? in
            guard let habit = byID[record.id] else { return nil }
            let start = record.date.addingTimeInterval(-Double(record.activeSeconds))
            let extraAfter = habits.contains { other in
                other.isExtra && other.date > record.date && other.date.timeIntervalSince(record.date) <= 30 * 60 + Double(other.plannedSeconds)
            }
            return SessionTiming(start: start, plannedSeconds: habit.plannedSeconds, activeSeconds: record.activeSeconds,
                                 stoppedForPain: pains.contains { $0.date >= start && $0.date <= record.date }, extraAfter: extraAfter)
        }
        return (reminder, HabitSignals.lengthSignal(timings))
    }

    /// "Move it": the reminder moves to her usual time.
    func moveReminder(to minutes: Int) {
        sessionHabits.answerReminder(at: now())
        updateProfile { $0.reminderMinutes = minutes }
    }

    func keepReminder() {
        sessionHabits.answerReminder(at: now())
        reload()
    }

    /// "Try the longer walk today?" and a busy day's "Gentle stretch instead": the session's preview.
    func startPreset(_ id: String) {
        guard let preset = SessionCatalog.preset(id: id) else { return }
        preview(preset.request(limits: profile?.limits ?? [], rotationIndex: today?.activeDays ?? 0), checkIn: nil)
    }

    // MARK: Busy day (P11)

    /// Reads today's and her usual steps once a day (only when Apple Health was asked), then rebuilds Today.
    func refreshBusyDayIfNeeded() {
        let day = calendar.startOfDay(for: now())
        guard busyDayCache?.day != day, let profile, health.hasAskedForAuthorization else { return }
        busyDayCache = BusyDayCache(day: day, isBusy: false)
        let minutes = profile.reminderMinutes
        Task { [weak self] in
            guard let self else { return }
            let busy = await health.isBusyDay(now: now(), reminderMinutes: minutes, calendar: calendar)
            busyDayCache = BusyDayCache(day: day, isBusy: busy)
            if busy { reload() }
        }
    }

    var isBusyToday: Bool {
        guard let cache = busyDayCache else { return false }
        return cache.isBusy && calendar.isDate(cache.day, inSameDayAs: now())
    }
}
