import Foundation
import Testing
@testable import GentleWalkCore

/// P11 (plan 4.12): a day she has already been on her feet a lot, from her own Apple Health steps.
@Suite struct BusyDayTests {
    let ny = TestSupport.newYork
    func day(_ d: Int, _ hour: Int = 0) -> Date { TestSupport.local(ny, 2026, 10, d, hour) }

    /// 28 days before Oct 29 at about 4,000 steps a day (a zero day: phone left at home, not counted).
    var history: [Date: Double] {
        var steps: [Date: Double] = [:]
        for d in 1...28 { steps[ny.startOfDay(for: day(d))] = d == 10 ? 0 : 3_800 + Double(d % 5) * 100 }
        return steps
    }

    @Test func busyDayNeedsOneAndAHalfTimesTheMedian() {
        let morning = TestSupport.local(ny, 2026, 10, 29, 8)
        #expect(BusyDay.isBusy(stepsToday: 6_400, dailySteps: history, now: morning, reminderMinutes: 9 * 60, calendar: ny))
        #expect(!BusyDay.isBusy(stepsToday: 5_500, dailySteps: history, now: morning, reminderMinutes: 9 * 60, calendar: ny))
    }

    /// Only before her reminder time: after it, the day's session is simply waiting.
    @Test func onlyBeforeTheReminder() {
        let afternoon = TestSupport.local(ny, 2026, 10, 29, 14)
        #expect(!BusyDay.isBusy(stepsToday: 9_000, dailySteps: history, now: afternoon, reminderMinutes: 9 * 60, calendar: ny))
    }

    /// Too little history (under seven days with steps) or nothing at all: never busy.
    @Test func needsAWeekOfHerOwnSteps() {
        let morning = TestSupport.local(ny, 2026, 10, 29, 8)
        let few = history.filter { $0.key >= ny.startOfDay(for: day(23)) }
        #expect(few.count == 6)
        #expect(!BusyDay.isBusy(stepsToday: 9_000, dailySteps: few, now: morning, reminderMinutes: 9 * 60, calendar: ny))
        #expect(!BusyDay.isBusy(stepsToday: 9_000, dailySteps: [:], now: morning, reminderMinutes: 9 * 60, calendar: ny))
        // Today's own entry and days older than four weeks are not part of her usual.
        var withToday = history
        withToday[ny.startOfDay(for: morning)] = 50_000
        #expect(BusyDay.usualSteps(dailySteps: withToday, now: morning, calendar: ny) == BusyDay.usualSteps(dailySteps: history, now: morning, calendar: ny))
    }
}
