import CoreMotion
import Foundation
import Observation

/// Step counting for outdoor walks without GPS, behind a protocol for tests.
@MainActor protocol PedometerProviding: AnyObject {
    func start(from date: Date, onUpdate: @escaping (Int, Double?) -> Void, onDenied: @escaping () -> Void)
    func stop()
}

/// Outdoor walk distance from steps when location is off (task 8.4). If Motion is not allowed the
/// walk still counts by minutes, with no error shown.
@Observable @MainActor final class PedometerService {
    private(set) var steps = 0
    private(set) var miles: Double?
    private(set) var isDenied = false

    @ObservationIgnored private let pedometer: PedometerProviding

    init(pedometer: PedometerProviding) {
        self.pedometer = pedometer
    }

    func start(at date: Date) {
        steps = 0
        miles = nil
        pedometer.start(from: date, onUpdate: { [weak self] steps, meters in
            self?.steps = steps
            self?.miles = meters.map { $0 / 1_609.344 }
        }, onDenied: { [weak self] in
            self?.isDenied = true
        })
    }

    func stop() { pedometer.stop() }
}

/// `CMPedometer` from the start of the walk.
@MainActor final class SystemPedometer: PedometerProviding {
    private let pedometer = CMPedometer()

    func start(from date: Date, onUpdate: @escaping (Int, Double?) -> Void, onDenied: @escaping () -> Void) {
        guard CMPedometer.isStepCountingAvailable(), CMPedometer.authorizationStatus() != .denied else {
            onDenied()
            return
        }
        pedometer.startUpdates(from: date) { data, error in
            let steps = data?.numberOfSteps.intValue
            let meters = data?.distance?.doubleValue
            let denied = (error as NSError?)?.code == Int(CMErrorMotionActivityNotAuthorized.rawValue)
            Task { @MainActor in
                if denied { onDenied() } else if let steps { onUpdate(steps, meters) }
            }
        }
    }

    func stop() { pedometer.stopUpdates() }
}
