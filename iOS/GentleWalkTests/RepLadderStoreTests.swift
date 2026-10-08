import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

/// The rep ladder kept on the device (steady program task 3.3), cleared by "Delete all my data".
@MainActor @Suite(.serialized) struct RepLadderStoreTests {
    let defaults = UserDefaults(suiteName: "RepLadderStoreTests")!

    init() { defaults.removePersistentDomain(forName: "RepLadderStoreTests") }

    @Test func roundTripsProgress() {
        let store = RepLadderStore(defaults: defaults)
        store.record(done: ["mv.sit-to-stand": 1], steady: ["mv.sit-to-stand"], troubled: [], shown: [])
        store.record(done: ["mv.sit-to-stand": 1], steady: ["mv.sit-to-stand"], troubled: [], shown: [])
        #expect(store.progress["mv.sit-to-stand"] == RepProgress(step: 2, fullSessions: 0, pendingChange: .up))
        store.record(done: [:], steady: [], troubled: [], shown: ["mv.sit-to-stand"])
        #expect(store.progress["mv.sit-to-stand"]?.pendingChange == nil)
        #expect(store.today(intensity: .steady, limits: [], isPro: true)["mv.sit-to-stand"] == RepStep(sets: 1, reps: 10))
        #expect(store.today(intensity: .steady, limits: [], isPro: false).isEmpty)
    }

    @Test func eraseClearsRepLadder() {
        #expect(AppDefaultsKeys.all.contains(RepLadderStore.defaultsKey))
    }
}
