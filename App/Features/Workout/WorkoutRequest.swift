import Foundation
import GentleWalkCore

/// What to play: built on Today / Preview (or the first-walk flow) and handed to the workout cover.
struct WorkoutRequest: Identifiable, Equatable, Sendable {
    var id = UUID()
    var day: PlannedDay
    var level: WalkLevel
    var intensity: Intensity
    var place: WorkoutPlace
    var limits: Set<BodyLimit>
    var rotationIndex: Int
    /// First Walk from onboarding: its own scripted session (A1).
    var isFirstWalk = false
    /// Shortened by adaptation (two Breaks last time), in minutes.
    var minutesDelta = 0
    /// Chair moves swapped on the preview: original id → replacement id.
    var swaps: [String: String] = [:]

    static func firstWalk(limits: Set<BodyLimit>) -> WorkoutRequest {
        WorkoutRequest(day: PlannedDay(main: .walk, chairMoves: 0, cooldown: false), level: .seated, intensity: .gentle,
                       place: .indoors, limits: limits, rotationIndex: 0, isFirstWalk: true)
    }

    /// Kind saved on the workout record.
    var recordKind: SessionTemplate.Kind {
        if isFirstWalk { return .firstWalk }
        switch day.main {
        case .chair: return .chair
        case .stretch: return .stretch
        default: return .walk
        }
    }

    /// Session name for the lock screen and titles.
    var title: String {
        if isFirstWalk { return String(localized: "First walk") }
        switch day.main {
        case .chair: return String(localized: "Chair moves")
        case .stretch: return String(localized: "Gentle stretch")
        default:
            switch intensity {
            case .gentle: return String(localized: "Gentle walk")
            case .steady: return String(localized: "Steady walk")
            case .strong: return String(localized: "Strong walk")
            }
        }
    }

    /// The plan this request plays.
    func plan(content: ContentBundle) throws -> SessionPlan {
        if isFirstWalk, let template = content.sessions.first(where: { $0.id == "ses.firstWalk" }) {
            return SessionPlan(template: template)
        }
        var plan = try SessionBuilder.build(kind: day, level: place == .pad ? .pad : level, intensity: intensity,
                                            limits: limits, rotationIndex: rotationIndex, content: content)
        if !swaps.isEmpty, let library = content.sessions.first(where: { $0.id == "ses.moves" }) {
            for b in plan.blocks.indices where plan.blocks[b].kind == .chair {
                for s in plan.blocks[b].segments.indices {
                    guard let id = plan.blocks[b].segments[s].exerciseID, let replacement = swaps[id],
                          let segment = library.segments.first(where: { $0.exerciseID == replacement }) else { continue }
                    plan.blocks[b].segments[s] = segment
                }
            }
        }
        return minutesDelta < 0 ? plan.shortened(byMinutes: -minutesDelta) : plan
    }
}
