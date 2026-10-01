import Foundation
import GentleWalkCore

/// The filmed loop for the walk part on screen (content plan 30/09/2026 §3): the move's clip for her
/// level, slowed for easy parts and quickened for quicker ones (`-easy` / `-quick`), else the move's
/// level clip. A move without a clip, the walking pad and outdoors keep the painting.
enum WalkVideo {
    static func fileName(for level: WalkLevel, move: Exercise?, pace: Exercise.Pace, isOutdoors: Bool = false) -> String? {
        guard !isOutdoors, let move else { return nil }
        return ExerciseVideo.firstBundled(move.videoCandidates(level: level, pace: pace))
    }

    /// Any clip for this walk's moves at her level (the "Video" badge in All sessions).
    static func hasClip(for level: WalkLevel, moves: [Exercise], isOutdoors: Bool = false) -> Bool {
        moves.contains { fileName(for: level, move: $0, pace: .easy, isOutdoors: isOutdoors) != nil }
    }
}
