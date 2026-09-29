import Foundation
import Testing
@testable import GentleWalk

@MainActor final class FakeDeepLinkTarget: DeepLinkTarget {
    private(set) var opened: [String] = []
    func openTodaySession() { opened.append("session") }
    func markRestToday() { opened.append("rest") }
    func openJourney() { opened.append("journey") }
    func openToday() { opened.append("today") }
}

@MainActor @Suite struct DeepLinkTests {
    @Test func startWalkOpensTodaysSession() {
        let link = DeepLink(category: NotificationCategory.reminder, action: NotificationAction.startWalk)
        #expect(link == .startTodaySession)
        #expect(link.opensApp)
        let target = FakeDeepLinkTarget()
        link.handle(with: target)
        #expect(target.opened == ["session"])
    }

    @Test func restTodayStaysInTheBackground() {
        let link = DeepLink(category: NotificationCategory.reminder, action: NotificationAction.restToday)
        #expect(link == .restToday)
        #expect(!link.opensApp)
        let target = FakeDeepLinkTarget()
        link.handle(with: target)
        #expect(target.opened == ["rest"])
    }

    @Test func tappingALandmarkNotificationOpensTheJourney() {
        #expect(DeepLink(category: NotificationCategory.landmark, action: NotificationAction.defaultTap) == .journey)
    }

    @Test func tappingAnyOtherNotificationOpensToday() {
        #expect(DeepLink(category: NotificationCategory.reminder, action: NotificationAction.defaultTap) == .today)
        #expect(DeepLink(category: "unknown", action: "x") == .today)
    }
}
