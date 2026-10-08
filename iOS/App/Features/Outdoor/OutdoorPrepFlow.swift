import Foundation
import Observation

/// How outdoor walks are measured, kept on this phone: "location" (map and distance) or "steps".
/// Asked once, in Outdoor prep; changed in Me → Outdoor walks.
enum OutdoorLocationChoice {
    static let defaultsKey = "outdoorLocationChoice"

    /// Not answered yet: Outdoor prep asks how to measure.
    static func asks(in defaults: UserDefaults) -> Bool { defaults.string(forKey: defaultsKey) == nil }
    static func usesLocation(in defaults: UserDefaults) -> Bool { defaults.string(forKey: defaultsKey) == "location" }
    static func save(_ useLocation: Bool, in defaults: UserDefaults) {
        defaults.set(useLocation ? "location" : "steps", forKey: defaultsKey)
    }
}

/// S10b Outdoor prep (plan 08/10/2026 task 1.17, decision D6): the checklist; then, the first time
/// only, how to measure the walk ("Map and distance" or "Steps only"); only Map leads to the
/// one-button prompt before Apple's location dialog, and "Don't Allow" there simply means steps.
@Observable @MainActor final class OutdoorPrepFlow {
    enum Step: Equatable { case ready, measure, locationPrompt }
    enum Measure: Equatable { case map, steps }
    /// What happens after a step: the next screen, or the walk starts (`useLocation` nil = not asked).
    enum Outcome: Equatable { case continues, finished(useLocation: Bool?) }

    private(set) var step = Step.ready
    var measure = Measure.map
    private(set) var isAsking = false

    @ObservationIgnored private let asksLocation: Bool

    init(asksLocation: Bool) {
        self.asksLocation = asksLocation
    }

    /// "Continue" under the checklist.
    @discardableResult func readyDone() -> Outcome {
        guard asksLocation else { return .finished(useLocation: nil) }
        step = .measure
        return .continues
    }

    /// "Continue" under the two measuring choices.
    @discardableResult func measureDone() -> Outcome {
        switch measure {
        case .steps: return .finished(useLocation: false)
        case .map:
            step = .locationPrompt
            return .continues
        }
    }

    /// "Continue" on the prompt: Apple's dialog; the map only if she allowed it.
    func requestLocation(_ request: () async -> Bool) async -> Bool {
        isAsking = true
        defer { isAsking = false }
        return await request()
    }
}
