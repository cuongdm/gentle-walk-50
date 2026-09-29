import Foundation
import Testing
@testable import GentleWalkCore

@Suite struct PaywallPolicyTests {
    let now = TestSupport.date("2026-10-05T15:00:00Z")
    func daysAgo(_ days: Double) -> Date { now.addingTimeInterval(-days * 86_400) }

    @Test(arguments: [PaywallTrigger.onboarding, .finishedNewYork, .lockedContent])
    func showsAtTheThreeInvitationPoints(_ trigger: PaywallTrigger) {
        #expect(PaywallPolicy.shouldShow(trigger: trigger, entitlement: .free, lastDismissed: nil, now: now))
    }

    @Test(arguments: [PaywallTrigger.appOpen, .duringWorkout])
    func neverOnOpenOrDuringAWorkout(_ trigger: PaywallTrigger) {
        #expect(!PaywallPolicy.shouldShow(trigger: trigger, entitlement: .free, lastDismissed: nil, now: now))
    }

    @Test func threeDayCoolDownAfterMaybeLater() {
        #expect(!PaywallPolicy.shouldShow(trigger: .finishedNewYork, entitlement: .free, lastDismissed: daysAgo(2), now: now))
        #expect(PaywallPolicy.shouldShow(trigger: .finishedNewYork, entitlement: .free, lastDismissed: daysAgo(3.1), now: now))
    }

    @Test func tappingLockedContentAlwaysOpensThePlans() {
        #expect(PaywallPolicy.shouldShow(trigger: .lockedContent, entitlement: .free, lastDismissed: daysAgo(0.1), now: now))
    }

    @Test func proUsersNeverSeeAnInvitation() {
        #expect(!PaywallPolicy.shouldShow(trigger: .finishedNewYork, entitlement: .subscribed, lastDismissed: nil, now: now))
        #expect(!PaywallPolicy.shouldShow(trigger: .onboarding, entitlement: .lifetime, lastDismissed: nil, now: now))
    }
}
