/// Counted reps of a move: `sets` rounds of `reps`, a minute seated between rounds.
public struct RepStep: Codable, Equatable, Sendable {
    public var sets: Int
    public var reps: Int

    public init(sets: Int, reps: Int) {
        self.sets = sets; self.reps = reps
    }
}

/// One move's step on the rep ladder.
public struct RepProgress: Codable, Equatable, Sendable {
    /// Index into `RepLadder.steps(for:)`.
    public var step: Int
    /// Sessions in a row done in full at this step, without This hurts or a Break.
    public var fullSessions: Int
    /// Set when the step changed and Complete has not said so yet.
    public var pendingChange: SupportLadder.Change?

    public init(step: Int = 0, fullSessions: Int = 0, pendingChange: SupportLadder.Change? = nil) {
        self.step = step; self.fullSessions = fullSessions; self.pendingChange = pendingChange
    }
}

/// The rep ladder of the leg-strength moves (Pro; steady program plan 2.5, owner 08/10/2026):
/// up one step after two sessions in a row done in full, down one step after This hurts or a Break
/// (Otago "2 × 10 before progressing"). Every step is a pre-built segment with the coach's counts
/// (`ses.reps.<id>.<sets>x<reps>`), so only these moves and these steps exist. Heel and toe raises
/// are timed, not counted, so they are not on the ladder.
public enum RepLadder {
    public static let exercises = ["mv.sit-to-stand", "mv.mini-squat", "mv.side-leg"]
    public static let sessionsToRaise = 2

    public static func steps(for exerciseID: String) -> [RepStep] {
        switch exerciseID {
        case "mv.sit-to-stand":
            [RepStep(sets: 1, reps: 6), RepStep(sets: 1, reps: 8), RepStep(sets: 1, reps: 10),
             RepStep(sets: 2, reps: 8), RepStep(sets: 2, reps: 10)]
        case "mv.mini-squat", "mv.side-leg":
            [RepStep(sets: 1, reps: 8), RepStep(sets: 1, reps: 10), RepStep(sets: 1, reps: 12), RepStep(sets: 2, reps: 10)]
        default:
            []
        }
    }

    /// The pre-built template holding this step's segment (tools/content/sessions_chair.py `rep_variants`).
    public static func templateID(_ exerciseID: String, step: Int) -> String {
        let rep = steps(for: exerciseID)[step]
        return "ses.reps.\(exerciseID).\(rep.sets)x\(rep.reps)"
    }

    /// The step a day of this intensity gives everyone (the free plan): the reps in `ses.moves.<intensity>`
    /// (tools/content/sessions_chair.py `STS_REPS`, `STS_SETS`, `REPS`).
    public static func defaultStep(_ exerciseID: String, intensity: Intensity) -> Int {
        switch (exerciseID, intensity) {
        case (_, .gentle): 0
        case (_, .steady): 1
        case ("mv.sit-to-stand", .strong): 3
        case (_, .strong): 2
        }
    }

    /// Today's reps: never below the day's own amount, at most one step above it, and no more than an
    /// achy day allows when she feels dizzy or unsteady. A 2-week check up by two allows two steps above
    /// for two weeks; one down by two keeps the day's own amount (P9, `SelfCheckComparison.trend`).
    /// `bonusCap`: she chose Harder last time and did it in full (P5, D10): one more step allowed above the
    /// day's own amount. Steps are still earned two sessions at a time; only the ceiling moves.
    public static func today(_ exerciseID: String, progress: [String: RepProgress], intensity: Intensity,
                             limits: Set<BodyLimit>, trend: SelfCheckTrend = .flat, bonusCap: Int = 0) -> RepStep {
        let steps = steps(for: exerciseID)
        let base = defaultStep(exerciseID, intensity: intensity)
        let above = switch trend {
        case .up: 2
        case .flat: 1 + max(0, min(bonusCap, 1))
        case .down: 0
        }
        var cap = min(base + above, steps.count - 1)
        if !limits.isDisjoint(with: [.dizzy, .unsteady]) { cap = min(cap, defaultStep(exerciseID, intensity: .gentle) + 1) }
        let earned = progress[exerciseID]?.step ?? 0
        return steps[min(max(earned, base), cap)]
    }

    /// After a session: `done` is the step each move was done at; `steady` moves were done in full,
    /// `troubled` had This hurts or a Break. `holdRaises` (a hard week P6, a check down P9): full sessions
    /// still count but no step up yet.
    public static func update(_ progress: [String: RepProgress], done: [String: Int], steady: Set<String>,
                              troubled: Set<String>, holdRaises: Bool = false) -> [String: RepProgress] {
        var result = progress
        for id in exercises where steady.contains(id) || troubled.contains(id) {
            let top = steps(for: id).count - 1
            var entry = result[id] ?? RepProgress()
            let doneStep = min(max(done[id] ?? entry.step, 0), top)
            if troubled.contains(id) {
                entry.step = max(doneStep - 1, 0)
                entry.fullSessions = 0
                entry.pendingChange = entry.step < doneStep ? .down : nil
            } else {
                if doneStep > entry.step { entry.step = doneStep; entry.fullSessions = 0 }
                entry.fullSessions += 1
                entry.pendingChange = nil
                if !holdRaises, entry.fullSessions >= sessionsToRaise, entry.step < top {
                    entry.step += 1
                    entry.fullSessions = 0
                    entry.pendingChange = .up
                }
            }
            result[id] = entry
        }
        return result
    }

    /// Back after a long break ("Pick up at week N", P13; Otago restarts gently): every counted move one
    /// step down, never below the first step. Counts start again.
    public static func stepDownAll(_ progress: [String: RepProgress]) -> [String: RepProgress] {
        progress.mapValues { entry in
            RepProgress(step: max(entry.step - 1, 0), fullSessions: 0, pendingChange: entry.step > 0 ? .down : nil)
        }
    }
}
