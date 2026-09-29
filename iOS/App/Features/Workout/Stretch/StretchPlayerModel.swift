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
        let upcoming = player.timeline.phases.dropFirst(player.phaseIndex + 1).first { $0.exerciseID != nil }
        return upcoming?.exerciseID.flatMap { session.exercisesByID[$0] }
    }

    var isCooldown: Bool { phase?.block == .cooldown }
    var usesEasier: Bool { phase?.isEasier == true || (pose.map { session.easierExerciseIDs.contains($0.id) } ?? false) }

    /// "Cool-down · 2 of 3" after a walk.
    var cooldownPosition: String? {
        guard isCooldown else { return nil }
        let poses = player.timeline.phases.filter { $0.block == .cooldown && $0.exerciseID != nil }
        let index = poses.lastIndex { $0.start <= player.currentTime } ?? 0
        return String(localized: "Cool-down · \(index + 1) of \(poses.count)")
    }

    private var holdWindows: [(side: Side?, start: Double, end: Double)] {
        guard let phase, phase.exerciseID != nil else { return [] }
        let hold = Double(session.holdSeconds)
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

    /// "0:20" counting down during a hold; the full hold before it starts.
    var holdText: String {
        let seconds = currentWindow.map { Int(($0.end - player.currentTime).rounded(.up)) } ?? session.holdSeconds
        return Duration.seconds(max(0, seconds)).formatted(.time(pattern: .minuteSecond))
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
        let poses = player.timeline.phases.filter { $0.exerciseID != nil }
        let current = poses.last { $0.start <= player.currentTime }
        if let current, player.currentTime - current.start > 3 {
            player.seek(to: current.start)
        } else if let current, let previous = poses.last(where: { $0.start < current.start }) {
            player.seek(to: previous.start)
        }
    }

    func skip() async { try? await player.apply(.skip) }
}
