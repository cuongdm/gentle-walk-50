import Foundation
import SwiftData
import Testing
import UserNotifications
import GentleWalkCore
@testable import GentleWalk

@MainActor final class FakeNotificationCenter: NotificationCenterProtocol {
    var pending: [UNNotificationRequest] = []
    private(set) var categories: Set<UNNotificationCategory> = []
    private(set) var removedIDs: [String] = []

    func pendingRequests() async -> [UNNotificationRequest] { pending }
    func removePending(ids: [String]) {
        removedIDs += ids
        pending.removeAll { ids.contains($0.identifier) }
    }
    func add(_ request: UNNotificationRequest) async throws { pending.append(request) }
    func setCategories(_ categories: Set<UNNotificationCategory>) { self.categories = categories }
}

@MainActor @Suite(.serialized) struct NotificationSchedulerTests {
    let container = try! ModelContainerFactory.make(inMemory: true)
    let calendar = { var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(identifier: "America/New_York")!; return c }()
    var now: Date { calendar.date(from: DateComponents(year: 2026, month: 9, day: 27, hour: 7))! }

    func scheduler(_ center: FakeNotificationCenter) throws -> NotificationScheduler {
        let bank = try PhraseBank.load(bundle: .main)
        let calendar = calendar
        let input = PlannerInput(calendar: calendar, restDays: [.saturday, .sunday], reminderMinutes: 510, frequency: .daily,
                                 workouts: [], trialReminder: nil, landmark: nil, settings: NotificationSettings(), newJourneyName: nil)
        return NotificationScheduler(center: center, bank: bank, context: container.mainContext,
                                     input: { input }, now: { [now] in now })
    }

    @Test func replacesOldPendingWithAWeekOfNotifications() async throws {
        let center = FakeNotificationCenter()
        center.pending = [UNNotificationRequest(identifier: "gw.old", content: UNMutableNotificationContent(), trigger: nil),
                          UNNotificationRequest(identifier: "other.app.thing", content: UNMutableNotificationContent(), trigger: nil)]
        let scheduler = try scheduler(center)
        await scheduler.reschedule()
        #expect(center.removedIDs == ["gw.old"])
        let ours = center.pending.filter { $0.identifier.hasPrefix("gw.") }
        #expect(ours.count == 5)
        #expect(ours.count <= 64)
        #expect(center.pending.contains { $0.identifier == "other.app.thing" })
        #expect(ours.allSatisfy { !$0.content.body.isEmpty && $0.content.categoryIdentifier == NotificationCategory.reminder })
    }

    @Test func reschedulingTwiceDoesNotDuplicate() async throws {
        let center = FakeNotificationCenter()
        let scheduler = try scheduler(center)
        await scheduler.reschedule()
        await scheduler.reschedule()
        #expect(center.pending.filter { $0.identifier.hasPrefix("gw.") }.count == 5)
        let history = try container.mainContext.fetch(FetchDescriptor<NotificationHistory>())
        #expect(history.count == 5)
    }

    @Test func consecutiveRemindersUseDifferentWords() async throws {
        let center = FakeNotificationCenter()
        try await scheduler(center).reschedule()
        let bodies = center.pending.map(\.content.body)
        #expect(Set(bodies).count == bodies.count)
    }

    @Test func reminderCategoryHasStartWalkAndRestToday() async throws {
        let center = FakeNotificationCenter()
        try await scheduler(center).reschedule()
        let reminder = try #require(center.categories.first { $0.identifier == NotificationCategory.reminder })
        #expect(reminder.actions.map(\.identifier) == [NotificationAction.startWalk, NotificationAction.restToday])
        #expect(reminder.actions[0].options.contains(.foreground))
        #expect(!reminder.actions[1].options.contains(.foreground))
    }

    @Test func phraseBankIsSafeForTheLockScreen() throws {
        let bank = try PhraseBank.load(bundle: .main)
        let banned = ["knee", "pain", "weight", "joint", "streak", "lost"]
        for phrase in bank.phrases {
            #expect(!banned.contains { phrase.text.lowercased().contains($0) }, "\(phrase.id): \(phrase.text)")
        }
        #expect(bank.ids(for: .reminder).count >= 14)
    }
}
