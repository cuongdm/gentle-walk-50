import Foundation
import Observation
import GentleWalkCore

/// Colour tone of the walk player for the current phase (spec S11: sky for easy, sun for brisk).
enum PhaseTone: Equatable, Sendable { case ready, easy, brisk }

/// Read-only view of the `SessionPlayer` for the walk screen (task 4.3): labels, clock and lines.
@Observable @MainActor final class WalkPlayerModel {
    let player: SessionPlayer
    let level: WalkLevel
    @ObservationIgnored private let exercises: [String: Exercise]

    init(player: SessionPlayer, level: WalkLevel, exercises: [String: Exercise] = [:]) {
        self.player = player
        self.level = level
        self.exercises = exercises
    }

    var phaseKind: SessionTemplate.Segment.Kind { player.currentPhase?.kind ?? .intro }

    /// The move on screen: the part's own move (a walking move or a cool-down stretch), else the
    /// march (First Walk has no moves of its own).
    var move: Exercise? {
        if let id = player.currentPhase?.exerciseID { return exercises[id] }
        return [.warmup, .easy, .brisk, .cooldown].contains(phaseKind) ? exercises["wk.march"] : nil
    }

    /// The clip for this part, if the app has it: the move at her level and pace, or the cool-down
    /// stretch. Outdoors she walks with the phone in her pocket: the painting shows.
    func videoFile(isOutdoors: Bool) -> String? {
        guard !isOutdoors, let move else { return nil }
        if move.kind == .walk {
            return WalkVideo.fileName(for: level, move: move, pace: phaseKind == .brisk ? .quicker : .easy)
        }
        return ExerciseVideo.firstBundled(move.videoCandidates(level: level))
    }

    /// "Seated · Heel dig" under the part's name; the level alone when there is no move.
    var levelNote: String {
        guard let move else { return String(localized: level.title) }
        return String(localized: "\(String(localized: level.title)) · \(move.name)")
    }

    var phaseLabel: String {
        switch phaseKind {
        // Seated is never called brisk (content plan decision 3): the quicker part is "QUICKER".
        case .brisk: level == .seated ? String(localized: "QUICKER") : String(localized: "BRISK WALK")
        case .cooldown: String(localized: "COOL-DOWN")
        case .intro: String(localized: "GET READY")
        case .warmup: String(localized: "WARM-UP")
        default: String(localized: "EASY WALK")
        }
    }

    var tone: PhaseTone {
        switch phaseKind {
        case .brisk: .brisk
        case .intro: .ready
        default: .easy
        }
    }

    /// Time left in this phase, "02:14" (the biggest number on screen).
    var clock: String { Self.clock(player.remainingInPhase) }

    /// "Round 2 of 3 · 5:54 left", or "Warm-up · …" / "Cool-down · …" outside the rounds.
    var statusLine: String {
        let left = Self.minutes(max(0, Int((player.timeline.total - player.currentTime).rounded(.up))))
        switch phaseKind {
        case .intro, .warmup:
            return String(localized: "Warm-up · \(left) left in total")
        case .cooldown, .outro:
            return String(localized: "Cool-down · \(left) left in total")
        default:
            let (round, rounds) = roundPosition
            return String(localized: "Round \(round) of \(rounds) · \(left) left in total")
        }
    }

    /// "Next: easy walk · 1:00", nil in the last phase.
    var nextLine: String? {
        let phases = player.timeline.phases
        let next = player.phaseIndex + 1
        guard phases.indices.contains(next), phases[next].end.isFinite else { return nil }
        let length = Self.minutes(Int((phases[next].end - phases[next].start).rounded()))
        return String(localized: "Next: \(Self.name(of: phases[next].kind, level: level)) · \(length)")
    }

    var captionText: String? { player.caption?.text }

    /// 0…1 through the current phase.
    var phaseProgress: Double {
        guard let phase = player.currentPhase, phase.end.isFinite, phase.end > phase.start else { return 0 }
        return min(1, max(0, (player.currentTime - phase.start) / (phase.end - phase.start)))
    }

    /// Rounds are the move blocks (easy and quicker parts of one move); First Walk counts its brisk parts.
    private var roundPosition: (Int, Int) {
        let phases = player.timeline.phases
        var starts: [Int] = []
        for index in phases.indices where [.easy, .brisk].contains(phases[index].kind) && phases[index].block == .walk {
            let sameMove = index > 0 && [.easy, .brisk].contains(phases[index - 1].kind)
                && phases[index - 1].exerciseID == phases[index].exerciseID && phases[index].exerciseID != nil
            if !sameMove { starts.append(index) }
        }
        if phases.allSatisfy({ $0.exerciseID == nil }) {
            starts = phases.indices.filter { phases[$0].kind == .brisk }
        }
        let started = starts.filter { $0 <= player.phaseIndex }.count
        return (max(1, started), max(1, starts.count))
    }

    static func name(of kind: SessionTemplate.Segment.Kind, level: WalkLevel = .inPlace) -> String {
        switch kind {
        case .brisk: level == .seated ? String(localized: "quicker") : String(localized: "brisk walk")
        case .cooldown: String(localized: "cool-down")
        case .warmup: String(localized: "warm-up")
        default: String(localized: "easy walk")
        }
    }

    /// "02:14"
    static func clock(_ seconds: Int) -> String {
        Duration.seconds(seconds).formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2)))
    }

    /// "8:40"
    static func minutes(_ seconds: Int) -> String {
        Duration.seconds(seconds).formatted(.time(pattern: .minuteSecond))
    }
}
