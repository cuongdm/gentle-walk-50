import Foundation
import Observation
import GentleWalkCore

/// Read model for S12: the move being done (or up next during a rest), its counter or timer,
/// tips and version, from the shared `SessionPlayer`.
@Observable @MainActor final class ChairPlayerModel {
    let session: WorkoutSessionModel
    /// Sit-to-stand target shown as "6 of 10" (preview: "Sit-to-stand · 10 reps").
    static let repTarget = 10
    private(set) var showsHarder = false

    init(session: WorkoutSessionModel) {
        self.session = session
    }

    var player: SessionPlayer { session.player }
    private var phase: SessionTimeline.Phase? { player.currentPhase }

    var isRest: Bool { phase?.kind == .rest }

    /// The move on screen: the current one, or the next one while resting or during the intro.
    var exercise: Exercise? {
        if let id = phase?.exerciseID { return session.exercisesByID[id] }
        return nextExercise
    }

    var nextExercise: Exercise? {
        let phases = player.timeline.phases
        let upcoming = phases.dropFirst(player.phaseIndex + 1).first { $0.exerciseID != nil && $0.block == phase?.block }
        return upcoming?.exerciseID.flatMap { session.exercisesByID[$0] }
    }

    var usesEasier: Bool {
        guard let exercise else { return false }
        return phase?.isEasier == true || session.easierExerciseIDs.contains(exercise.id)
    }

    var countsReps: Bool { exercise?.counting == .reps && !isRest }

    /// "00:40" for timed moves and rests.
    var timerText: String { WalkPlayerModel.clock(player.remainingInPhase) }

    var repsText: String {
        String(localized: "\(min(session.totalSitToStands, 99)) of \(Self.repTarget)")
    }

    /// Easier / harder instruction under the tips when a version is chosen.
    var versionNote: String? {
        guard let exercise else { return nil }
        if usesEasier { return exercise.easier }
        if showsHarder { return exercise.harder }
        return nil
    }

    var blockPosition: String? {
        let moves = player.timeline.phases.filter { $0.block == phase?.block && $0.exerciseID != nil }
        guard let phase, let index = moves.firstIndex(where: { $0.start == phase.start }) else { return nil }
        return String(localized: "Move \(index + 1) of \(moves.count)")
    }

    func chooseEasier() async {
        showsHarder = false
        guard let id = phase?.exerciseID, !usesEasier else { return }
        try? await player.apply(.easierVersion(exerciseID: id))
    }

    func chooseHarder() {
        guard exercise?.harder != nil, !usesEasier else { return }
        showsHarder.toggle()
    }

    /// Back: to the start of this move, or the previous move if it just started.
    func back() {
        let phases = player.timeline.phases
        let moves = phases.filter { $0.exerciseID != nil }
        let current = moves.last { $0.start <= player.currentTime }
        if let current, player.currentTime - current.start > 3 {
            player.seek(to: current.start)
        } else if let current, let previous = moves.last(where: { $0.start < current.start }) {
            player.seek(to: previous.start)
        } else {
            player.seek(to: 0)
        }
        showsHarder = false
    }

    func skip() async {
        showsHarder = false
        try? await player.apply(.skip)
    }
}
