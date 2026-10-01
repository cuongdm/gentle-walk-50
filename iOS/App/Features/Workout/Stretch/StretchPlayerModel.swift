import Foundation
import Observation
import GentleWalkCore

/// Read model for S12b: the pose, which side, the hold countdown and whether the clip should rest on
/// the hold frame. Hold windows come from the voice cues: a hold ends at "switch" (left side) or
/// at "release".
@Observable @MainActor final class StretchPlayerModel {
    enum Side: Equatable, Sendable { case left, right }

    let session: WorkoutSessionModel

    init(session: WorkoutSessionModel) {
        self.session = session
    }

    var player: SessionPlayer { session.player }
    private var phase: SessionTimeline.Phase? { player.currentPhase }

    var pose: Exercise? {
        if let id = phase?.exerciseID { return session.exercisesByID[id] }
        let upcoming = player.timeline.phases.dropFirst(player.phaseIndex + 1).first(where: \.isExercise)
        return upcoming?.exerciseID.flatMap { session.exercisesByID[$0] }
    }

    /// The closing breaths come after the last pose: the video keeps that pose's clip (its hold
    /// frame) instead of an empty frame; the name and tips stay hidden.
    private var lastPose: Exercise? {
        player.timeline.phases.prefix(player.phaseIndex).last(where: \.isExercise)?.exerciseID.flatMap { session.exercisesByID[$0] }
    }

    /// The pose's clip: while holding, its breathing loop if the app has one (else the clip rests on
    /// its hold frame); the easier clip when the easier version is on. Nil keeps the still picture.
    var videoFile: String? {
        guard let pose = pose ?? lastPose else { return nil }
        // A hold clip shows the first side of a two-sided pose: the second side rests on the clip's frame.
        return ExerciseVideo.firstBundled(pose.videoCandidates(level: session.request.level, pace: .easy,
                                                               easier: usesEasier, holding: isHolding && side != .right))
    }

    /// True while a breathing loop plays for the hold (the clip keeps moving instead of pausing).
    var playsHoldClip: Bool {
        guard isHolding, let hold = pose?.videoHold else { return false }
        return videoFile == hold
    }

    /// Easier version, or the note for one of her body limits.
    var note: String? { usesEasier ? pose?.easier : pose?.note(for: session.request.limits) }

    var isCooldown: Bool { phase?.block == .cooldown }

    var moveProgress: SessionTimeline.MoveProgress? { player.timeline.moveProgress(at: player.currentTime) }

    /// The pose after the one on screen; nil on the last.
    var followingName: String? {
        guard let progress = moveProgress else { return nil }
        let poses = player.timeline.phases.filter { $0.block == phase?.block && $0.isExercise }
        guard poses.indices.contains(progress.index + 1), let id = poses[progress.index + 1].exerciseID else { return nil }
        return session.exercisesByID[id]?.name
    }
    var usesEasier: Bool { phase?.isEasier == true || (pose.map { session.easierExerciseIDs.contains($0.id) } ?? false) }

    /// "Stretch 2 of 6", or "Cool-down · 2 of 3" after a walk (clarity review D34).
    var cooldownPosition: String? {
        let poses = player.timeline.phases.filter { $0.block == phase?.block && $0.isExercise }
        guard !poses.isEmpty else { return nil }
        let index = poses.lastIndex { $0.start <= player.currentTime } ?? 0
        return isCooldown ? String(localized: "Cool-down · \(index + 1) of \(poses.count)")
            : String(localized: "Stretch \(index + 1) of \(poses.count)")
    }

    /// Seconds of each hold in this pose; 0 for a slow repeated move (neck turns, ankles).
    private var holdLength: Int? {
        guard let phase, phase.isExercise else { return nil }
        return phase.hold ?? session.holdSeconds
    }

    private var holdWindows: [(side: Side?, start: Double, end: Double)] {
        guard let phase, let length = holdLength, length > 0 else { return [] }
        let hold = Double(length)
        let cues = player.timeline.voice.filter { $0.start >= phase.start && $0.start < phase.end }
        let switchAt = cues.first { $0.lineID.hasPrefix("a10.switch") }?.start
        let releaseAt = cues.first { $0.lineID.hasPrefix("a10.release") }?.start ?? phase.end
        if let switchAt {
            return [(.left, switchAt - hold, switchAt), (.right, releaseAt - hold, releaseAt)]
        }
        return [(nil, releaseAt - hold, releaseAt)]
    }

    private var currentWindow: (side: Side?, start: Double, end: Double)? {
        holdWindows.first { $0.start <= player.currentTime && player.currentTime < $0.end }
    }

    var isHolding: Bool { currentWindow != nil }

    /// "0:20" counting down during a hold; the full hold before it starts. A repeated move, the
    /// warm-up and the breathing show the time left in the part.
    var holdText: String {
        guard let length = holdLength, length > 0 else { return WalkPlayerModel.clock(player.remainingInPhase) }
        let seconds = currentWindow.map { Int(($0.end - player.currentTime).rounded(.up)) } ?? length
        // Same "00:20" as the chair timer and the walk clock (clarity review D34).
        return WalkPlayerModel.clock(max(0, seconds))
    }

    var side: Side? {
        if let window = currentWindow { return window.side }
        let upcoming = holdWindows.first { $0.start > player.currentTime }
        return upcoming?.side
    }

    var sideText: String? {
        switch side {
        case .left: String(localized: "Left side")
        case .right: String(localized: "Right side")
        case nil: nil
        }
    }

    func chooseEasier() async {
        guard let id = phase?.exerciseID, !usesEasier else { return }
        try? await player.apply(.easierVersion(exerciseID: id))
    }

    func back() {
        let poses = player.timeline.phases.filter(\.isExercise)
        let current = poses.last { $0.start <= player.currentTime }
        if let current, player.currentTime - current.start > 3 {
            player.seek(to: current.start)
        } else if let current, let previous = poses.last(where: { $0.start < current.start }) {
            player.seek(to: previous.start)
        }
    }

    func skip() async { try? await player.apply(.skip) }
}
