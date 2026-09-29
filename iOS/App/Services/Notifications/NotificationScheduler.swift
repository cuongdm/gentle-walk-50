import Foundation
import SwiftData
import UserNotifications
import GentleWalkCore

/// The parts of `UNUserNotificationCenter` the scheduler uses, so tests can use a fake.
@MainActor protocol NotificationCenterProtocol: AnyObject {
    func pendingRequests() async -> [UNNotificationRequest]
    func removePending(ids: [String])
    func add(_ request: UNNotificationRequest) async throws
    func setCategories(_ categories: Set<UNNotificationCategory>)
}

@MainActor final class SystemNotificationCenter: NotificationCenterProtocol {
    private var center: UNUserNotificationCenter { .current() }
    func pendingRequests() async -> [UNNotificationRequest] { await center.pendingNotificationRequests() }
    func removePending(ids: [String]) { center.removePendingNotificationRequests(withIdentifiers: ids) }
    func add(_ request: UNNotificationRequest) async throws { try await center.add(request) }
    func setCategories(_ categories: Set<UNNotificationCategory>) { center.setNotificationCategories(categories) }
}

/// One line from `notifications.json` (D8), with `{stop}`, `{n}`, `{date}`, `{price}`, `{journey}` slots.
struct NotificationPhrase: Codable, Equatable, Identifiable, Sendable {
    var id: String
    /// `NotificationKind` raw value, or "card" for the Today card.
    var kind: String
    var text: String
}

struct PhraseBank: Equatable, Sendable {
    var phrases: [NotificationPhrase]

    private struct File: Decodable { var schemaVersion: Int; var phrases: [NotificationPhrase] }

    static func load(bundle: Bundle) throws -> PhraseBank {
        guard let url = bundle.url(forResource: "notifications", withExtension: "json") else { throw CocoaError(.fileNoSuchFile) }
        return PhraseBank(phrases: try JSONDecoder().decode(File.self, from: Data(contentsOf: url)).phrases)
    }

    func ids(for kind: NotificationKind) -> [String] { phrases.filter { $0.kind == kind.rawValue }.map(\.id) }
    func text(for id: String) -> String? { phrases.first { $0.id == id }?.text }
}

/// Turns the core plan into scheduled local notifications (task 7.9): clears this app's pending
/// ones, adds the next 16 days (at most one a day, far under the 64 limit), picks words that have
/// not been used in 14 days, and keeps a history for that rule. Runs on launch, after a session
/// and on settings changes. 16 days reach the second comeback (10 planned days after the last
/// walk) and the day-12 trial reminder, for someone who does not open the app (review I9).
@MainActor final class NotificationScheduler: NotificationRescheduling, TrialReminderScheduling, PendingNotificationClearing {
    static let identifierPrefix = "gw."
    static let horizonDays = 16

    private let center: NotificationCenterProtocol
    private let bank: PhraseBank
    private let context: ModelContext
    private let input: () -> PlannerInput?
    private let now: () -> Date
    /// Trial reminder set by `StoreService` (always sent while a trial renews).
    private var trial: (at: Date, billing: Date, price: String)?

    init(center: NotificationCenterProtocol, bank: PhraseBank, context: ModelContext, input: @escaping () -> PlannerInput?,
         now: @escaping () -> Date = Date.init) {
        self.center = center
        self.bank = bank
        self.context = context
        self.input = input
        self.now = now
    }

    static var categories: Set<UNNotificationCategory> {
        let start = UNNotificationAction(identifier: NotificationAction.startWalk, title: String(localized: "Start walk"),
                                         options: [.foreground])
        let rest = UNNotificationAction(identifier: NotificationAction.restToday, title: String(localized: "Rest today"), options: [])
        return [
            UNNotificationCategory(identifier: NotificationCategory.reminder, actions: [start, rest], intentIdentifiers: []),
            UNNotificationCategory(identifier: NotificationCategory.landmark, actions: [], intentIdentifiers: []),
            UNNotificationCategory(identifier: NotificationCategory.general, actions: [], intentIdentifiers: []),
        ]
    }

    func reschedule() async {
        center.setCategories(Self.categories)
        let old = await center.pendingRequests().map(\.identifier).filter { $0.hasPrefix(Self.identifierPrefix) }
        if !old.isEmpty { center.removePending(ids: old) }
        let now = now()
        forgetFutureHistory(after: now)
        guard var plannerInput = input() else { return }
        plannerInput.trialReminder = trial?.at
        var history = pastHistory()
        for planned in NotificationPlanner.plan(input: plannerInput, now: now, days: Self.horizonDays) {
            guard let (phraseID, body) = words(for: planned, history: history, at: planned.fireDate) else { continue }
            let content = UNMutableNotificationContent()
            content.body = body
            content.sound = .default
            content.categoryIdentifier = Self.category(for: planned.kind)
            let components = plannerInput.calendar.dateComponents([.year, .month, .day, .hour, .minute], from: planned.fireDate)
            let identifier = "\(Self.identifierPrefix)\(planned.kind.rawValue).\(Int(planned.fireDate.timeIntervalSince1970))"
            let request = UNNotificationRequest(identifier: identifier, content: content,
                                                trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false))
            do {
                try await center.add(request)
                context.insert(NotificationHistory(kind: planned.kind.rawValue, phraseID: phraseID, date: planned.fireDate))
                history.append(PhraseUse(phraseID: phraseID, date: planned.fireDate))
            } catch {
                continue
            }
        }
        try? context.save()
    }

    /// "Remind me later" on the preview: one reminder in two hours (inside 8 AM–8 PM), not repeated.
    func remindLater(after interval: TimeInterval = 2 * 3_600) async {
        let fire = now().addingTimeInterval(interval)
        let calendar = input()?.calendar ?? .current
        let hour = calendar.component(.hour, from: fire)
        guard hour >= 8, hour < 20, let id = PhraseRotation.next(bank: bank.ids(for: .reminder), history: pastHistory(), now: fire),
              let text = bank.text(for: id) else { return }
        let content = UNMutableNotificationContent()
        content.body = text
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.reminder
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        try? await center.add(UNNotificationRequest(identifier: "\(Self.identifierPrefix)later", content: content, trigger: trigger))
    }

    // MARK: TrialReminderScheduling

    func scheduleTrialReminder(at date: Date, billingDate: Date, price: String) {
        trial = (date, billingDate, price)
        Task { await reschedule() }
    }

    func cancelTrialReminder() {
        guard trial != nil else { return }
        trial = nil
        Task { await reschedule() }
    }

    // MARK: PendingNotificationClearing

    func removeAllPending() {
        Task {
            let ours = await center.pendingRequests().map(\.identifier).filter { $0.hasPrefix(Self.identifierPrefix) }
            center.removePending(ids: ours)
        }
    }

    // MARK: Words

    private func words(for planned: PlannedNotification, history: [PhraseUse], at date: Date) -> (String, String)? {
        var candidates = bank.ids(for: planned.kind)
        if planned.kind == .weeklyRecap, let this = Int(planned.values["thisWeek"] ?? ""), let last = Int(planned.values["lastWeek"] ?? "") {
            let variant = this > last ? "nt.week.up" : this == last ? "nt.week.same" : "nt.week.less"
            candidates = candidates.filter { $0 == variant }
        }
        if planned.kind == .comeback {
            let dayTen = history.contains { $0.phraseID.hasPrefix("nt.back") && date.timeIntervalSince($0.date) < 12 * 86_400 }
            candidates = candidates.filter { $0 == (dayTen ? "nt.back.10" : "nt.back.3") }
        }
        guard let id = PhraseRotation.next(bank: candidates, history: history, now: date), var text = bank.text(for: id) else { return nil }
        var values = planned.values
        values["n"] = planned.values["thisWeek"]
        if let trial {
            values["date"] = trial.billing.formatted(.dateTime.month(.abbreviated).day())
            values["price"] = trial.price
        }
        for (key, value) in values { text = text.replacingOccurrences(of: "{\(key)}", with: value) }
        guard !text.contains("{") else { return nil }
        return (id, text)
    }

    static func category(for kind: NotificationKind) -> String {
        switch kind {
        case .reminder, .dayTwo, .comeback: NotificationCategory.reminder
        case .landmark: NotificationCategory.landmark
        default: NotificationCategory.general
        }
    }

    private func pastHistory() -> [PhraseUse] {
        let rows = (try? context.fetch(FetchDescriptor<NotificationHistory>())) ?? []
        return rows.map { PhraseUse(phraseID: $0.phraseID, date: $0.date) }
    }

    /// Scheduled-but-not-delivered rows are replaced on every reschedule.
    private func forgetFutureHistory(after date: Date) {
        let future = FetchDescriptor<NotificationHistory>(predicate: #Predicate { $0.date > date })
        for row in (try? context.fetch(future)) ?? [] { context.delete(row) }
    }
}
