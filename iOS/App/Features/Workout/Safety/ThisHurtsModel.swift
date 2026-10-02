import Foundation
import Observation
import GentleWalkCore

/// Saves "This hurts" taps; the app stores them as SwiftData `PainReport`s.
@MainActor protocol PainReportRecording: AnyObject {
    func record(_ report: PainReportSnapshot)
}

/// "Where does it hurt?" chips (S13).
enum HurtArea: String, CaseIterable, Identifiable, Sendable {
    case knee, hip, back, shoulder, elsewhere
    var id: String { rawValue }

    var bodyArea: BodyArea {
        switch self {
        case .knee: .knees
        case .hip: .hips
        case .back: .lowerBack
        case .shoulder: .shoulders
        case .elsewhere: .other
        }
    }

    var title: LocalizedStringResource {
        switch self {
        case .knee: "Knee"
        case .hip: "Hip"
        // Its own key: "Back" is also the Back button (another word in other languages).
        case .back: LocalizedStringResource("body.back", defaultValue: "Back", comment: "Body area chip on This hurts: the back.")
        case .shoulder: "Shoulder"
        case .elsewhere: "Somewhere else"
        }
    }
}

enum HurtOutcome: Equatable, Sendable {
    case continueSession
    /// The session ends; `counts` is always true ("Today still counts").
    case endSession(counts: Bool)
}

/// S13 This hurts (task 4.9): records where it hurts and adapts the session. It leaves the player
/// paused; the session resumes it, or keeps it for "Stand behind your chair" (review 02/10/2026).
@Observable @MainActor final class ThisHurtsModel {
    var area: HurtArea?

    @ObservationIgnored private let player: SessionPlayer
    @ObservationIgnored private let recorder: PainReportRecording
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private var recorded = false

    init(player: SessionPlayer, recorder: PainReportRecording, now: @escaping () -> Date = Date.init) {
        self.player = player
        self.recorder = recorder
        self.now = now
    }

    /// Easier version of the current move; on a walk, the brisk part eases off to an easy walk.
    func showEasier() async -> HurtOutcome {
        record()
        if isWalk {
            if player.currentPhase?.kind == .brisk { try? await player.apply(.skip()) }
        } else if let exercise = player.currentPhase?.exerciseID {
            try? await player.apply(.easierVersion(exerciseID: exercise))
        }
        return .continueSession
    }

    /// Skip records pain only when she said where it hurts: a skip alone is often tiredness, and three
    /// reports in a week move her to seated moves (review 02/10/2026).
    func skipMove() async -> HurtOutcome {
        if area != nil { record() }
        try? await player.apply(.skip())
        return .continueSession
    }

    /// "I'm okay, go back": a mistaken tap, nothing is recorded.
    func goBack() -> HurtOutcome {
        return .continueSession
    }

    /// Walking home there is no part to skip (Skip would have nowhere to go).
    var canSkip: Bool { player.currentPhase?.end.isFinite ?? true }

    /// A walk (its moves included): the choices speak about the walk ("Slow down to an easy walk").
    var isWalk: Bool { player.currentPhase?.block == .walk }

    func stopForToday() -> HurtOutcome {
        record()
        player.end()
        return .endSession(counts: true)
    }

    private func record() {
        guard !recorded else { return }
        recorded = true
        recorder.record(PainReportSnapshot(date: now(), area: (area ?? .elsewhere).bodyArea,
                                           exerciseID: player.currentPhase?.exerciseID))
    }
}
