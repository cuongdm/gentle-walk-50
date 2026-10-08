import Foundation
import Testing
@testable import GentleWalkCore

@Suite struct NotificationPlannerTests {
    let cal = TestSupport.newYork

    func at(_ day: Int, _ month: Int = 9, _ hour: Int = 7, _ minute: Int = 0) -> Date {
        TestSupport.local(cal, 2026, month, day, hour, minute)
    }

    func input(now: Date, workouts: [Date] = [], minutes: Int = 8 * 60 + 30, frequency: ReminderFrequency = .daily,
               trialReminder: Date? = nil, landmark: LandmarkSoon? = nil, settings: NotificationSettings = .init(),
               newJourney: String? = nil) -> PlannerInput {
        PlannerInput(calendar: cal, restDays: [.saturday, .sunday], reminderMinutes: minutes, frequency: frequency,
                     workouts: workouts, trialReminder: trialReminder, landmark: landmark, settings: settings,
                     newJourneyName: newJourney)
    }

    func plan(_ input: PlannerInput, now: Date) -> [PlannedNotification] {
        NotificationPlanner.plan(input: input, now: now, days: 7)
    }

    // Steady program 2.11: the 2-week self-check reminder.
    @Test func selfCheckReminderOnDueDay() {
        var due = input(now: at(5, 10), workouts: [at(5, 10, 6)])
        due.selfCheckDue = at(7, 10)
        let checks = plan(due, now: at(5, 10)).filter { $0.kind == .selfCheck }
        #expect(checks.count == 1)
        #expect(checks.first.map { cal.isDate($0.fireDate, inSameDayAs: at(7, 10)) } == true)
        #expect(checks.first.map { cal.component(.hour, from: $0.fireDate) } == 8)
    }

    @Test func selfCheckNeverDoublesUp() {
        // Wednesday Oct 7 also gets a walk reminder: one notification that day, the self-check.
        var due = input(now: at(5, 10), workouts: [at(5, 10, 6)])
        due.selfCheckDue = at(7, 10)
        let onDueDay = plan(due, now: at(5, 10)).filter { cal.isDate($0.fireDate, inSameDayAs: at(7, 10)) }
        #expect(onDueDay.map(\.kind) == [.selfCheck])
    }

    @Test func selfCheckRespectsSetting() {
        var settings = NotificationSettings()
        settings.selfCheckReminders = false
        var due = input(now: at(5, 10), workouts: [at(5, 10, 6)], settings: settings)
        due.selfCheckDue = at(7, 10)
        #expect(!plan(due, now: at(5, 10)).contains { $0.kind == .selfCheck })
    }

    /// Settings saved before the self-check switch existed still decode, with the switch on.
    @Test func oldSettingsWithoutSelfCheckStillDecode() throws {
        let old = #"{"walkReminders":false,"journeyMilestones":true,"weeklyRecap":true,"newJourneys":false}"#
        let settings = try JSONDecoder().decode(NotificationSettings.self, from: Data(old.utf8))
        #expect(settings.walkReminders == false)
        #expect(settings.selfCheckReminders == true)
    }

    // 7.1
    @Test func remindsAtChosenMomentOnPlannedDays() {
        // Sunday Sep 27, 7 AM, before the first walk: a reminder every planned day.
        let result = plan(input(now: at(27)), now: at(27))
        let reminders = result.filter { $0.kind == .reminder }
        #expect(reminders.count == 5)
        #expect(reminders.map { cal.component(.weekday, from: $0.fireDate) } == [2, 3, 4, 5, 6])
        #expect(reminders.allSatisfy { cal.component(.hour, from: $0.fireDate) == 8 && cal.component(.minute, from: $0.fireDate) == 30 })
    }

    /// Sunday Nov 1 2026, the day clocks go back in New York: the reminder still comes at 8:30
    /// (minutes added to midnight landed at 7:30; review 02/10/2026).
    @Test func reminderKeepsItsClockTimeOnADaylightSavingDay() {
        let now = at(31, 10, 7)
        let input = PlannerInput(calendar: cal, restDays: [], reminderMinutes: 8 * 60 + 30, frequency: .daily,
                                 workouts: [], trialReminder: nil, landmark: nil, settings: .init(), newJourneyName: nil)
        let sunday = NotificationPlanner.plan(input: input, now: now, days: 3).filter { $0.kind == .reminder }
            .first { cal.component(.day, from: $0.fireDate) == 1 }
        #expect(sunday.map { cal.component(.hour, from: $0.fireDate) } == 8)
        #expect(sunday.map { cal.component(.minute, from: $0.fireDate) } == 30)
    }

    // 7.2
    @Test func noReminderOnADayAlreadyWalkedOrOutsideTheWindow() {
        let monday = at(28, 9, 7)
        let walkedToday = plan(input(now: monday, workouts: [at(28, 9, 6, 30)]), now: monday)
        #expect(!walkedToday.contains { cal.isDate($0.fireDate, inSameDayAs: monday) })
        let early = plan(input(now: monday, workouts: [at(25, 9, 9)], minutes: 7 * 60), now: at(28, 9, 6))
        #expect(early.filter { $0.kind == .reminder }.allSatisfy { cal.component(.hour, from: $0.fireDate) == 8 })
        let late = plan(input(now: monday, workouts: [at(25, 9, 9)], minutes: 21 * 60), now: monday)
        #expect(late.filter { $0.kind == .reminder }.allSatisfy { cal.component(.hour, from: $0.fireDate) == 20 })
    }

    @Test func reminderTimeAlreadyPassedTodaySkipsToday() {
        let result = plan(input(now: at(28, 9, 12), workouts: [at(25, 9, 9)]), now: at(28, 9, 12))
        #expect(!result.contains { cal.isDate($0.fireDate, inSameDayAs: at(28)) })
    }

    // 7.3
    @Test func atMostOnePerDayAndTheMoreImportantWins() {
        let now = at(28, 9, 7)
        let trial = at(29, 9, 10)
        let landmark = LandmarkSoon(stopName: "Times Square")
        let result = plan(input(now: now, workouts: [at(25, 9, 9)], trialReminder: trial, landmark: landmark), now: now)
        let days = Dictionary(grouping: result) { cal.startOfDay(for: $0.fireDate) }
        #expect(days.values.allSatisfy { $0.count == 1 })
        #expect(result.first { cal.isDate($0.fireDate, inSameDayAs: trial) }?.kind == .trialEnd)
        // The landmark takes the first free planned day, instead of that day's reminder.
        #expect(result.first { cal.isDate($0.fireDate, inSameDayAs: at(28)) }?.kind == .landmark)
        #expect(result.filter { $0.kind == .landmark }.count == 1)
    }

    @Test func trialReminderIsSentEvenWithRemindersOff() {
        var settings = NotificationSettings()
        settings.walkReminders = false
        let now = at(28, 9, 7)
        let result = plan(input(now: now, workouts: [at(25, 9, 9)], trialReminder: at(30, 9, 10), settings: settings), now: now)
        #expect(result.contains { $0.kind == .trialEnd })
        #expect(!result.contains { [.reminder, .comeback, .landmark, .dayTwo].contains($0.kind) })
    }

    // 7.5
    /// Days count planned days since the last walk (rest days are skipped: "never on rest days").
    /// Last walk Thu Oct 1 → planned days Fri 2 (1), Mon 5 (2), Tue 6 (3) … Thu 15 (10).
    @Test func comebackOnDayThreeAndDayTenThenQuiet() throws {
        let last = at(1, 10, 9)
        let early = plan(input(now: at(3, 10, 7), workouts: [last]), now: at(3, 10, 7))
        #expect(early.first { cal.isDate($0.fireDate, inSameDayAs: at(5, 10)) }?.kind == .reminder)
        #expect(early.first { cal.isDate($0.fireDate, inSameDayAs: at(6, 10)) }?.kind == .comeback)
        #expect(!early.contains { $0.fireDate > at(6, 10, 23) })
        let later = plan(input(now: at(12, 10, 7), workouts: [last]), now: at(12, 10, 7))
        #expect(later.map(\.kind) == [.comeback])
        let comeback = try #require(later.first)
        #expect(cal.isDate(comeback.fireDate, inSameDayAs: at(15, 10)))
        #expect(plan(input(now: at(16, 10, 7), workouts: [last]), now: at(16, 10, 7)).isEmpty)
        #expect(!(early + later).contains { $0.values.values.contains { $0.localizedCaseInsensitiveContains("streak") } })
    }

    // 7.6
    @Test func fiveDaysStartedBeforeTheReminderOffersFewerReminders() {
        let early = [21, 22, 23, 24, 25].map { at($0, 9, 7, 45) }
        #expect(NotificationPlanner.offersFewerReminders(workouts: early, reminderMinutes: 8 * 60 + 30, calendar: cal))
        let mixed = [21, 22, 23, 24].map { at($0, 9, 7, 45) } + [at(25, 9, 11)]
        #expect(!NotificationPlanner.offersFewerReminders(workouts: mixed, reminderMinutes: 8 * 60 + 30, calendar: cal))
    }

    @Test func quietDaysModeWaitsForTwoDaysWithoutAWalk() {
        let now = at(29, 9, 7)  // Tuesday; walked Monday
        let result = plan(input(now: now, workouts: [at(28, 9, 9)], frequency: .quietDays), now: now)
        let reminders = result.filter { $0.kind == .reminder }
        // Tue (1 day since) and Wed (2 days: Mon walked, Tue unknown) are quiet; Thu is the first reminder.
        #expect(reminders.first.map { cal.component(.day, from: $0.fireDate) } == 1)
    }

    // 7.7
    @Test func dayTwoFollowsTheFirstWalkOnce() throws {
        let first = at(28, 9, 9)
        let result = plan(input(now: at(28, 9, 18), workouts: [first]), now: at(28, 9, 18))
        let dayTwo = try #require(result.first)
        #expect(dayTwo.kind == .dayTwo)
        #expect(cal.isDate(dayTwo.fireDate, inSameDayAs: at(29)))
        #expect(result.filter { $0.kind == .dayTwo }.count == 1)
    }

    @Test func weeklyRecapOnSundayAfternoonFromWeekTwo() {
        let workouts = [14, 15, 16, 21, 22, 23, 24].map { at($0, 9, 9) }
        let result = plan(input(now: at(25, 9, 20), workouts: workouts), now: at(25, 9, 20))
        let recap = result.first { $0.kind == .weeklyRecap }
        #expect(recap.map { cal.component(.weekday, from: $0.fireDate) } == 1)
        #expect(recap.map { cal.component(.hour, from: $0.fireDate) } == 17)
        #expect(recap?.values["thisWeek"] == "4")
        #expect(recap?.values["lastWeek"] == "3")
        // First week: no recap.
        let firstWeek = plan(input(now: at(25, 9, 20), workouts: [at(22, 9, 9)]), now: at(25, 9, 20))
        #expect(!firstWeek.contains { $0.kind == .weeklyRecap })
    }

    // 7.8
    @Test func newJourneyNewsIsOffByDefault() {
        let now = at(28, 9, 7)
        #expect(!plan(input(now: now, workouts: [at(25, 9, 9)], newJourney: "New England lighthouses"), now: now)
            .contains { $0.kind == .newJourney })
        var settings = NotificationSettings()
        settings.newJourneys = true
        let on = plan(input(now: now, workouts: [at(25, 9, 9)], settings: settings, newJourney: "New England lighthouses"), now: now)
        #expect(on.filter { $0.kind == .newJourney }.count == 1)
        #expect(on.first { $0.kind == .newJourney }?.values["journey"] == "New England lighthouses")
    }
}

@Suite struct PhraseRotationTests {
    let now = TestSupport.date("2026-10-01T12:00:00Z")
    let bank = (1...14).map { "p\($0)" }
    func daysAgo(_ d: Double) -> Date { now.addingTimeInterval(-d * 86_400) }

    @Test func picksAPhraseNotUsedInTheLastFourteenDays() {
        let history = (1...13).map { PhraseUse(phraseID: "p\($0)", date: daysAgo(Double($0))) }
        #expect(PhraseRotation.next(bank: bank, history: history, now: now) == "p14")
    }

    @Test func whenAllWereUsedTheOldestComesBack() {
        let history = (1...14).map { PhraseUse(phraseID: "p\($0)", date: daysAgo(Double($0))) }
        #expect(PhraseRotation.next(bank: bank, history: history, now: now) == "p14")
        let recent = (1...14).map { PhraseUse(phraseID: "p\($0)", date: daysAgo(Double(15 - $0) * 0.5)) }
        #expect(PhraseRotation.next(bank: bank, history: recent, now: now) == "p1")
    }

    @Test func emptyBankGivesNothing() {
        #expect(PhraseRotation.next(bank: [], history: [], now: now) == nil)
    }
}
