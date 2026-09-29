import CoreMotion
import Foundation
import Observation
import GentleWalkCore

/// Sit-to-stand counting from device motion at 50 Hz (task 8.9). Runs only while the user does
/// Sit-to-stand with the phone held to the chest; the +1 button always stays.
@Observable @MainActor final class MotionService {
    private(set) var count = 0
    private(set) var confident = false
    /// Changes on every counted rep: the "Counted for you" dot pulses on it.
    private(set) var pulse = 0
    private(set) var isRunning = false

    @ObservationIgnored private let manager = CMMotionManager()
    @ObservationIgnored private var detector = SitToStandDetector()
    @ObservationIgnored private var startTime: TimeInterval?

    var isAvailable: Bool { manager.isDeviceMotionAvailable }

    func start() {
        guard isAvailable, !isRunning else { return }
        detector = SitToStandDetector()
        count = 0
        confident = false
        startTime = nil
        isRunning = true
        manager.deviceMotionUpdateInterval = 1.0 / 50
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let motion else { return }
            let gravity = motion.gravity
            let user = motion.userAcceleration
            // Upward acceleration: the user acceleration projected on "up" (opposite to gravity).
            let length = max(0.0001, sqrt(gravity.x * gravity.x + gravity.y * gravity.y + gravity.z * gravity.z))
            let vertical = -(user.x * gravity.x + user.y * gravity.y + user.z * gravity.z) / length
            let pitch = motion.attitude.pitch * 180 / .pi
            let time = motion.timestamp
            MainActor.assumeIsolated { self?.receive(time: time, vertical: vertical, pitch: pitch) }
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
        isRunning = false
    }

    private func receive(time: TimeInterval, vertical: Double, pitch: Double) {
        let start = startTime ?? time
        startTime = start
        if detector.add(MotionSample(time: time - start, verticalAcceleration: vertical, pitchDegrees: pitch)) {
            count = detector.count
            pulse += 1
        }
        confident = detector.confident
    }
}
