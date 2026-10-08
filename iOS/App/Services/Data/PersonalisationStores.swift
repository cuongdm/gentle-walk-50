import Foundation
import GentleWalkCore

// Personalisation memory (plan 08/10/2026, milestone 4): small Codable values in UserDefaults, like the
// ladders (no SchemaV3 before 1.0). On the device only; "Delete all my data" clears every key
// (`AppDefaultsKeys`).

/// Reads and writes one Codable value under one key.
@MainActor struct DefaultsValue<Value: Codable> {
    let defaults: UserDefaults
    let key: String

    func load() -> Value? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(Value.self, from: data)
    }

    func save(_ value: Value) {
        if let data = try? JSONEncoder().encode(value) { defaults.set(data, forKey: key) }
    }
}

/// Easier taps, Harder done in full, moves brought back and preview swaps (P5, P3, P12).
@MainActor struct ExerciseMemoryStore {
    static let defaultsKey = "exerciseMemory"
    let defaults: UserDefaults

    private var value: DefaultsValue<ExerciseMemory> { DefaultsValue(defaults: defaults, key: Self.defaultsKey) }

    var memory: ExerciseMemory { value.load() ?? ExerciseMemory() }

    func update(_ change: (inout ExerciseMemory) -> Void) {
        var current = memory
        change(&current)
        value.save(current)
    }
}

/// Her weekly check-in answers (P6), at most `WeeklyCheckIn.kept`.
@MainActor struct WeeklyNoteStore {
    static let defaultsKey = "weeklyNotes"
    let defaults: UserDefaults

    private var value: DefaultsValue<[WeeklyNote]> { DefaultsValue(defaults: defaults, key: Self.defaultsKey) }

    var notes: [WeeklyNote] { value.load() ?? [] }

    func add(_ note: WeeklyNote) { value.save(WeeklyCheckIn.adding(note, to: notes)) }
}

/// Preview choices she started with (P12): a different walking level becomes her level from now on,
/// swapped chair moves are remembered for two weeks.
@MainActor struct PreviewChoiceStore {
    let defaults: UserDefaults

    func record(_ request: WorkoutRequest, currentLevel: WalkLevel, now: Date) {
        if !request.swaps.isEmpty {
            ExerciseMemoryStore(defaults: defaults).update { $0.noteSwaps(request.swaps, at: now) }
        }
        let isIndoorWalk = (request.day.main == .walk || request.day.main == .longWalk) && request.place == .indoors
        if isIndoorWalk, !request.isFirstWalk, request.level != currentLevel, request.level != .pad {
            WalkLevelStore(defaults: defaults).set(level: request.level, changedAt: now, card: nil)
        }
    }
}

/// What a finished session planned, for the habit signals (P10): the planned length and whether it was
/// an extra. Kept for the latest sessions only.
struct SessionHabit: Codable, Equatable {
    var recordID: UUID
    var date: Date
    var plannedSeconds: Int
    var isExtra: Bool
}

@MainActor struct SessionHabitStore {
    static let defaultsKey = "sessionHabits"
    /// "Move your reminder to 9:15?" answered: not asked again for a month.
    static let reminderAnsweredKey = "reminderSuggestionAnsweredAt"
    static let kept = 20
    let defaults: UserDefaults

    private var value: DefaultsValue<[SessionHabit]> { DefaultsValue(defaults: defaults, key: Self.defaultsKey) }

    var habits: [SessionHabit] { value.load() ?? [] }

    func add(_ habit: SessionHabit) {
        value.save(Array((habits.filter { $0.recordID != habit.recordID } + [habit]).sorted { $0.date < $1.date }.suffix(Self.kept)))
    }

    var reminderAnsweredAt: Date? { defaults.object(forKey: Self.reminderAnsweredKey) as? Date }

    func answerReminder(at date: Date) { defaults.set(date, forKey: Self.reminderAnsweredKey) }
}
