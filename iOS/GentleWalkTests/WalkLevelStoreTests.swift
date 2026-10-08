import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

/// Her current walking level, kept on the device (plan 08/10/2026 task 0.2): the start level from
/// onboarding stays in `UserProfile.startLevel`; the level she is on now lives here.
@MainActor @Suite(.serialized) struct WalkLevelStoreTests {
    let defaults = UserDefaults(suiteName: "WalkLevelStoreTests")!

    init() { defaults.removePersistentDomain(forName: "WalkLevelStoreTests") }

    @Test func roundTripsLevelAndCard() {
        let store = WalkLevelStore(defaults: defaults)
        let changed = Date(timeIntervalSince1970: 1_790_000_000)
        store.set(level: .inPlace, changedAt: changed, card: .movedUp(to: .inPlace))

        let again = WalkLevelStore(defaults: defaults)
        #expect(again.state(startLevel: .seated) == LevelState(level: .inPlace, changedAt: changed))
        #expect(again.pendingCard == .movedUp(to: .inPlace))
        #expect(again.changedAt == changed)

        again.clearCard()
        #expect(again.pendingCard == nil)
        #expect(again.state(startLevel: .seated).level == .inPlace)
    }

    @Test func fallsBackToStartLevelWhenEmpty() {
        let store = WalkLevelStore(defaults: defaults)
        #expect(store.state(startLevel: .seated) == LevelState(level: .seated, changedAt: nil))
        #expect(store.state(startLevel: .inPlace) == LevelState(level: .inPlace, changedAt: nil))
        #expect(store.pendingCard == nil)
    }
}
