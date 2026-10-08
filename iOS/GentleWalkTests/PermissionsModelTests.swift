import Testing
@testable import GentleWalk

/// App Review I-2 (owner 08/10/2026): the reminder and Apple Health screens have one button, which always
/// opens Apple's dialog; "Don't Allow" there moves the flow on with the feature left off.
@MainActor @Suite struct PermissionsModelTests {
    final class FakeNotifications: NotificationAuthorizing {
        let answer: Bool
        var asked = 0
        init(_ answer: Bool) { self.answer = answer }
        func requestAuthorization() async -> Bool { asked += 1; return answer }
    }

    final class FakeHealth: HealthAuthorizing {
        let answer: Bool
        var hasAskedForAuthorization = false
        init(_ answer: Bool) { self.answer = answer }
        func requestAuthorization() async -> Bool { hasAskedForAuthorization = true; return answer }
    }

    @Test func dontAllowLeavesRemindersOffAndGoesOn() async {
        let notifications = FakeNotifications(false)
        let model = PermissionsModel(health: nil, notifications: notifications)
        let granted = await model.ask(.reminders)
        #expect(notifications.asked == 1)
        #expect(!granted)
        #expect(!model.remindersAllowed)
    }

    @Test func allowTurnsRemindersOn() async {
        let model = PermissionsModel(health: nil, notifications: FakeNotifications(true))
        #expect(await model.ask(.reminders))
        #expect(model.remindersAllowed)
    }

    @Test func healthAsksAppleEachTime() async {
        let health = FakeHealth(false)
        let model = PermissionsModel(health: health, notifications: nil)
        #expect(await model.ask(.health) == false)
        #expect(health.hasAskedForAuthorization)
        #expect(!model.healthConnected)
    }
}
