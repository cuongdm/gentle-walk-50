import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

/// The support ladder kept on the device (review 06/10/2026): steps per balance exercise, cleared by
/// "Delete all my data".
@MainActor @Suite(.serialized) struct SupportLadderStoreTests {
    let defaults = UserDefaults(suiteName: "SupportLadderStoreTests")!

    init() { defaults.removePersistentDomain(forName: "SupportLadderStoreTests") }

    @Test func twoSteadySessionsRaiseAndTheAnnouncementIsSaidOnce() {
        let store = SupportLadderStore(defaults: defaults)
        store.record(steady: ["bl.tandem"], troubled: [], announced: [])
        store.record(steady: ["bl.tandem"], troubled: [], announced: [])
        #expect(store.progress["bl.tandem"]?.level == .oneHand)
        #expect(store.progress["bl.tandem"]?.pendingChange == .up)
        store.record(steady: [], troubled: [], announced: ["bl.tandem"])
        #expect(store.progress["bl.tandem"]?.pendingChange == nil)
    }

    @Test func deleteAllMyDataClearsTheLadder() {
        #expect(AppDefaultsKeys.all.contains(SupportLadderStore.defaultsKey))
    }
}
