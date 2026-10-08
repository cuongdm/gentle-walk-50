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
    var allowed = true
    func isAllowed() async -> Bool { allowed }
}

@MainActor @Suite(.serialized) struct NotificationSchedulerTests {
    let container = try! ModelContainerFactory.make(inMemory: true)
    let calendar = { var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(identifier: "America/New_York")!; return c }()
    var now: Date { calendar.date(from: DateComponents(year: 2026, month: 9, day: 27, hour: 7))! }

    func scheduler(_ center: FakeNotificationCenter, workouts: [Date] = []) throws -> NotificationScheduler {
        let bank = try PhraseBank.load(bundle: .main)
        let calendar = calendar
        let input = PlannerInput(calendar: calendar, restDays: [.saturday, .sunday], reminderMinutes: 510, frequency: .daily,
                                 workouts: workouts, trialReminder: nil, landmark: nil, settings: NotificationSettings(), newJourneyName: nil)
        return NotificationScheduler(center: center, bank: bank, context: container.mainContext,
                                     input: { input }, now: { [now] in now })
    }

    /// "Remind me later" survives a reschedule, and goes once she has walked today (review 02/10/2026).
    @Test func remindLaterStaysUntilSheWalks() async throws {
        let monday = calendar.date(from: DateComponents(year: 2026, month: 9, day: 28, hour: 9))!
        let later = UNNotificationRequest(identifier: NotificationScheduler.laterIdentifier, content: UNMutableNotificationContent(),
                                          trigger: nil)
        let input = { (workouts: [Date]) in
            PlannerInput(calendar: calendar, restDays: [.saturday, .sunday], reminderMinutes: 510, frequency: .daily,
                         workouts: workouts, trialReminder: nil, landmark: nil, settings: NotificationSettings(), newJourneyName: nil)
        }
        let bank = try PhraseBank.load(bundle: .main)
        let center = FakeNotificationCenter()
        center.pending = [later]
        let kept = NotificationScheduler(center: center, bank: bank, context: container.mainContext,
                                         input: { input([]) }, now: { monday })
        await kept.reschedule()
        #expect(!center.removedIDs.contains(NotificationScheduler.laterIdentifier))
        let walked = NotificationScheduler(center: center, bank: bank, context: container.mainContext,
                                           input: { input([monday.addingTimeInterval(-1_800)]) }, now: { monday })
        await walked.reschedule()
        #expect(center.removedIDs.contains(NotificationScheduler.laterIdentifier))
    }

    @Test func replacesOldPendingWithSixteenDaysOfNotifications() async throws {
        let center = FakeNotificationCenter()
        center.pending = [UNNotificationRequest(identifier: "gw.old", content: UNMutableNotificationContent(), trigger: nil),
                          UNNotificationRequest(identifier: "other.app.thing", content: UNMutableNotificationContent(), trigger: nil)]
        let scheduler = try scheduler(center)
        await scheduler.reschedule()
        #expect(center.removedIDs == ["gw.old"])
        let ours = center.pending.filter { $0.identifier.hasPrefix("gw.") }
        #expect(ours.count == 11)  // weekdays in the next 16 days, rest days quiet
        #expect(ours.count <= 64)
        #expect(center.pending.contains { $0.identifier == "other.app.thing" })
        #expect(ours.allSatisfy { !$0.content.body.isEmpty && $0.content.categoryIdentifier == NotificationCategory.reminder })
    }

    /// "Remind me at 9:00 AM" only when a reminder can really come (clarity review D10).
    @Test func remindLaterSaysWhenOrHides() async throws {
        let center = FakeNotificationCenter()
        let scheduler = try scheduler(center)
        let fire = try #require(await scheduler.remindLaterTime())
        #expect(calendar.component(.hour, from: fire) == 9)
        center.allowed = false
        #expect(await scheduler.remindLaterTime() == nil)
        // Too late in the evening: no reminder, so no button.
        #expect(await scheduler.remindLaterTime(after: 14 * 3_600) == nil)
    }

    @Test func reschedulingTwiceDoesNotDuplicate() async throws {
        let center = FakeNotificationCenter()
        let scheduler = try scheduler(center)
        await scheduler.reschedule()
        await scheduler.reschedule()
        #expect(center.pending.filter { $0.identifier.hasPrefix("gw.") }.count == 11)
        let history = try container.mainContext.fetch(FetchDescriptor<NotificationHistory>())
        #expect(history.count == 11)
    }

    /// The 2-week check day: one reminder, the self-check words (no health words), and none when the
    /// switch is off (steady program task 4.15).
    @Test func selfCheckReminderOnItsDay() async throws {
        let bank = try PhraseBank.load(bundle: .main)
        let due = calendar.date(from: DateComponents(year: 2026, month: 9, day: 29))!
        let lastWalk = calendar.date(from: DateComponents(year: 2026, month: 9, day: 25, hour: 9))!
        for enabled in [true, false] {
            var settings = NotificationSettings()
            settings.selfCheckReminders = enabled
            let input = PlannerInput(calendar: calendar, restDays: [.saturday, .sunday], reminderMinutes: 510, frequency: .daily,
                                     workouts: [lastWalk], trialReminder: nil, landmark: nil, settings: settings, newJourneyName: nil,
                                     selfCheckDue: due)
            let center = FakeNotificationCenter()
            let scheduler = NotificationScheduler(center: center, bank: bank, context: container.mainContext,
                                                  input: { input }, now: { [now] in now })
            await scheduler.reschedule()
            let checks = center.pending.filter { $0.identifier.hasPrefix("gw.selfCheck.") }
            #expect(checks.count == (enabled ? 1 : 0))
            if let check = checks.first {
                #expect(bank.ids(for: .selfCheck).contains { bank.text(for: $0) == check.content.body })
                #expect((check.trigger as? UNCalendarNotificationTrigger)?.dateComponents.day == 29)
            }
        }
    }

    /// Review I9: after a last walk on Friday 25/09 the second comeback (10 planned days later,
    /// Friday 09/10) is already booked; she will not open the app to book it.
    @Test func theSecondComebackIsBookedAheadOfTime() async throws {
        let center = FakeNotificationCenter()
        let lastWalk = calendar.date(from: DateComponents(year: 2026, month: 9, day: 25, hour: 9))!
        let scheduler = try scheduler(center, workouts: [lastWalk])
        await scheduler.reschedule()
        let comebackDays = center.pending.filter { $0.identifier.hasPrefix("gw.comeback.") }.compactMap {
            ($0.trigger as? UNCalendarNotificationTrigger)?.dateComponents.day
        }
        #expect(comebackDays == [30, 9])
    }

    @Test func consecutiveRemindersUseDifferentWords() async throws {
        let center = FakeNotificationCenter()
        try await scheduler(center).reschedule()
        // The same words come back only after 14 days (PhraseRotation), even over 16 days booked.
        let fireTimes = Dictionary(grouping: center.pending, by: \.content.body).mapValues { requests in
            requests.compactMap { Double($0.identifier.split(separator: ".").last ?? "") }.sorted()
        }
        for times in fireTimes.values where times.count > 1 {
            #expect(zip(times, times.dropFirst()).allSatisfy { $1 - $0 >= 14 * 86_400 })
        }
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
