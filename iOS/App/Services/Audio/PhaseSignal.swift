import UIKit

/// Phase change signal (task 3.6): the bell is already in the audio program; while the screen is
/// on, two light taps confirm the change for people who have the sound low.
@MainActor enum PhaseSignal {
    static let gapBetweenTaps: Duration = .milliseconds(180)

    static func play() {
        guard UIApplication.shared.applicationState == .active else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        Task { @MainActor in
            try? await Task.sleep(for: gapBetweenTaps)
            generator.impactOccurred()
        }
    }
}
