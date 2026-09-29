import Foundation
import GentleWalkCore

/// Filmed walking loops, by level (indoors only; outdoors she walks with the phone in her pocket).
/// A level shows its clip once the file is in the bundle; until then the walk keeps its painting.
enum WalkVideo {
    /// W1-1: seated march on the chair (Commercial break walk trial, 30/09/2026).
    private static let files: [WalkLevel: String] = [.seated: "W1-1.mp4"]

    static func fileName(for level: WalkLevel, isOutdoors: Bool = false) -> String? {
        guard !isOutdoors, let file = files[level], ExerciseVideo.url(for: file) != nil else { return nil }
        return file
    }
}
