import Foundation
import Observation
import GentleWalkCore

/// Read model for S12: the move being done (or up next during a rest), its counter or timer,
/// tips and version, from the shared `SessionPlayer`.
@Observable @MainActor final class ChairPlayerModel {
    let session: WorkoutSessionModel
    /// Sit-to-stand target when the move does not say how many the coach counts.
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
        let upcoming = phases.dropFirst(player.phaseIndex + 1).first { $0.isExercise && $0.block == phase?.block }
        return upcoming?.exerciseID.flatMap { session.exercisesByID[$0] }
    }

    /// Level of the walking moves inside a chair block: the seated march of the warm-up, or the
    /// standing weight shift of Balance.
    private var walkLevel: WalkLevel { isBalance ? .inPlace : .seated }

    /// The clip on screen: the easier version's clip when it is on, else the move's own; nil keeps
    /// the still picture (clip not in the app yet).
    var videoFile: String? {
        guard let exercise else { return nil }
        return ExerciseVideo.firstBundled(exercise.videoCandidates(level: walkLevel, pace: .easy, easier: usesEasier,
                                                                   alternate: isBalance))
    }

    var nextVideoFile: String? {
        nextExercise.flatMap { ExerciseVideo.firstBundled($0.videoCandidates(level: walkLevel, pace: .easy, alternate: isBalance)) }
    }

    /// Balance and the steady set stand throughout: heel and toe raises use their standing clip.
    private var isBalance: Bool {
        session.request.variant == SessionBuilder.Variant.balance
            || (phase?.block == .steady && !session.request.limits.contains(.standingIsHard))
    }

    /// Painted still for a move without a clip of its own (walking backwards, walk and turn).
    var picture: String? { exercise?.picture }

    /// Where she is among this block's moves (segmented bar).
    var moveProgress: SessionTimeline.MoveProgress? { player.timeline.moveProgress(at: player.currentTime) }

    /// The move after the one on screen ("Next: Seated knee lift"); nil on the last.
    var followingName: String? {
        guard let progress = moveProgress else { return nil }
        let moves = player.timeline.phases.filter { $0.block == phase?.block && $0.isExercise }
        return FollowingMove.label(ids: moves.map(\.exerciseID), index: progress.index) { session.exercisesByID[$0]?.name }
    }

    var usesEasier: Bool {
        guard let exercise else { return false }
        return phase?.isEasier == true || session.easierExerciseIDs.contains(exercise.id)
    }

    /// Sit-to-stand is counted on screen (by the motion sensor or her taps); the coach counts the
    /// other moves aloud while a timer runs.
    var countsReps: Bool { exercise?.id == "mv.sit-to-stand" && phase?.kind == .move }

    /// How many the coach counts in this move.
    var repTarget: Int { phase?.reps ?? Self.repTarget }

    /// A balance exercise on the support ladder: how many hands on the chair today (free: both hands).
    var supportLabel: LocalizedStringResource? {
        guard let id = exercise?.id, SupportLadder.exercises.contains(id) else { return nil }
        return (session.request.supportLevels[id] ?? .twoHands).label
    }

    /// A counted move on the rep ladder (Pro): today's "2 × 8" (steady program task 4.11).
    var repsLabel: String? {
        guard let id = exercise?.id, let step = session.request.reps[id] else { return nil }
        return RepText.step(step)
    }

    /// "00:40" for timed moves and rests.
    var timerText: String { WalkPlayerModel.clock(player.remainingInPhase) }

    var repsText: String {
        String(localized: "\(min(session.totalSitToStands, 99)) of \(repTarget)")
    }

    /// Easier / harder instruction under the tips when a version is chosen; otherwise the note for
    /// one of her body limits ("Keep your knees well below your hips").
    var versionNote: String? {
        guard let exercise else { return nil }
        if usesEasier { return exercise.easier }
        if showsHarder { return exercise.harder }
        return exercise.note(for: session.request.limits)
    }

    var blockPosition: String? {
        let moves = player.timeline.phases.filter { $0.block == phase?.block && $0.isExercise }
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
        let moves = phases.filter(\.isExercise)
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

    func skip() {
        showsHarder = false
        player.skip()
    }
}
