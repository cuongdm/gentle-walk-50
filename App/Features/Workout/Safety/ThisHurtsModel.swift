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
        case .back: "Back"
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

/// S13 This hurts (task 4.9): records where it hurts and adapts the session.
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
        if let exercise = player.currentPhase?.exerciseID {
            try? await player.apply(.easierVersion(exerciseID: exercise))
        } else if player.currentPhase?.kind == .brisk {
            try? await player.apply(.skip)
        }
        player.resume()
        return .continueSession
    }

    func skipMove() async -> HurtOutcome {
        record()
        try? await player.apply(.skip)
        player.resume()
        return .continueSession
    }

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
