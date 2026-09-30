import Foundation
import GentleWalkCore

/// How a catalog session plays in the app: a `WorkoutRequest` built like a planned day, its name
/// and its painting (milestone 10).
extension SessionPreset {
    func request(limits: Set<BodyLimit>, rotationIndex: Int) -> WorkoutRequest {
        // Seated stretch: the poses filter treats "standing is hard" as the seated set.
        let limits = main == .stretch && !standing ? limits.union([.standingIsHard]) : limits
        var request = WorkoutRequest(day: PlannedDay(main: main, chairMoves: 0, cooldown: false), level: level,
                                     intensity: intensity, place: .indoors, limits: limits,
                                     rotationIndex: fixedRotation ?? rotationIndex)
        request.presetID = id
        return request
    }

    /// Length as built today (limits can drop moves), rounded up to a whole minute.
    func minutes(content: ContentBundle, limits: Set<BodyLimit> = [], rotationIndex: Int = 0) -> Int {
        let seconds = (try? request(limits: limits, rotationIndex: rotationIndex).plan(content: content).totalSeconds) ?? 0
        return seconds > 0 ? max(1, Int((Double(seconds) / 60).rounded())) : 0
    }

    var title: LocalizedStringResource {
        switch id {
        case "walk.gentle": "Gentle walk"
        case "walk.steady": "Steady walk"
        case "walk.strong": "Strong walk"
        case "walk.long": "Longer walk"
        case "chair.gentle": "Gentle chair moves"
        case "chair.steady": "Chair moves"
        case "chair.strong": "Stronger chair moves"
        case "stretch.seated.gentle": "Gentle seated stretch"
        case "stretch.seated.steady": "Seated stretch"
        case "stretch.standing.gentle": "Gentle standing stretch"
        case "stretch.standing.steady": "Standing stretch"
        case "extra.commercial": "Commercial break walk"
        case "extra.morning": "Morning stretch"
        case "extra.balance": "Balance"
        default: "Session"
        }
    }

    var art: Art {
        switch id {
        case "walk.gentle": .walkerSeatedMarch
        case "chair.gentle": .walkerBehindChair
        case "walk.steady": .sceneLivingRoom
        case "walk.strong": .walkerMarch
        case "walk.long": .sceneWalkingPad
        case "chair.steady", "stretch.standing.steady": .walkerBehindChair
        case "chair.strong", "extra.balance": .walkerStand
        case "stretch.standing.gentle": .walkerCalfStretch
        case "extra.commercial": .sceneBreak
        default: .walkerRest
        }
    }
}

extension SessionPreset.Group {
    var title: LocalizedStringResource {
        switch self {
        case .walks: "Walks"
        case .chair: "Chair moves"
        case .stretch: "Stretches"
        case .extras: "Short extras"
        }
    }
}
