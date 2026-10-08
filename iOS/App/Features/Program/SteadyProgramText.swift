import Foundation
import GentleWalkCore

/// Words of the steady program (plan docs/plans/2026-10-08-steady-program.md). Claims follow
/// docs/design/steady-claims.md: general fitness, compared only with herself, no fall or bone words.
extension ProgramStage {
    var title: LocalizedStringResource {
        switch self {
        case .base: "Steady base"
        case .build: "Building strength"
        case .challenge: "Gentle challenge"
        case .routine: "Your routine"
        }
    }

    /// "Weeks 1–3".
    var weeks: ClosedRange<Int> {
        let first = (rawValue - 1) * 3 + 1
        return first...(first + 2)
    }

    var summary: LocalizedStringResource {
        switch self {
        case .base: "Learn the moves seated or with your chair. Short, easy sessions."
        case .build: "A few more reps when you're ready, and a little less hand on the chair."
        case .challenge: "Longer holds and more reps, only when the last ones felt easy."
        case .routine: "Keep what feels good, so it stays part of your week."
        }
    }
}

extension SupportLevel {
    /// The hands label on the player for a balance exercise (Pro support ladder).
    var label: LocalizedStringResource {
        switch self {
        case .twoHands: "Two hands on the chair"
        case .oneHand: "One hand on the chair"
        case .fingertips: "Fingertips on the chair"
        }
    }
}

enum RepText {
    /// "2 × 8", or "10 times" for one set.
    static func step(_ step: RepStep) -> String {
        step.sets > 1 ? String(localized: "\(step.sets) × \(step.reps)") : String(localized: "\(step.reps) times")
    }
}

/// "Next time: Sit-to-stand, 1 × 10." on Complete after a ladder step up (task 4.12). A hint, never a
/// task: she can always choose an easier version.
enum LevelUpText {
    static func line(supportBefore: [String: SupportProgress], supportAfter: [String: SupportProgress],
                     repsBefore: [String: RepProgress], repsAfter: [String: RepProgress], content: ContentBundle) -> String? {
        func name(_ id: String) -> String? { content.exercises.first { $0.id == id }?.name }
        for id in RepLadder.exercises {
            guard let after = repsAfter[id], after.pendingChange == .up, after.step > (repsBefore[id]?.step ?? 0),
                  let name = name(id) else { continue }
            let step = RepLadder.steps(for: id)[after.step]
            return String(localized: "You did these in full twice in a row. Next time: \(name), \(RepText.step(step)).")
        }
        for id in SupportLadder.exercises.sorted() {
            guard let after = supportAfter[id], after.pendingChange == .up,
                  after.level > (supportBefore[id]?.level ?? .twoHands), let name = name(id) else { continue }
            // One sentence per level: a label dropped mid-sentence read "…, One hand on the chair." (review 08/10).
            switch after.level {
            case .oneHand: return String(localized: "You held steady twice in a row. Next time: \(name) with one hand on the chair.")
            case .fingertips:
                return String(localized: "You held steady twice in a row. Next time: \(name) with just your fingertips on the chair.")
            case .twoHands: continue
            }
        }
        return nil
    }
}
