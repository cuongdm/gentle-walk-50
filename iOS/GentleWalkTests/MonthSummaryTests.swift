import Foundation
import Testing
@testable import GentleWalk

/// The line under the month on Progress (review M14, 02/10/2026).
@MainActor @Suite struct MonthSummaryTests {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        return calendar
    }

    private func day(_ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day))!
    }

    @Test func countsOnlyThisMonth() {
        let dates: Set<Date> = [day(9, 29), day(10, 1), day(10, 2), day(10, 3)]
        #expect(MonthCalendar.summary(activeDates: dates, now: day(10, 3), calendar: calendar) == "3 active days so far this month")
    }

    @Test func emptyMonthSaysWhatFillsIt() {
        #expect(MonthCalendar.summary(activeDates: [day(9, 29)], now: day(10, 3), calendar: calendar)
                == "Your first active day this month will show here.")
    }
}
