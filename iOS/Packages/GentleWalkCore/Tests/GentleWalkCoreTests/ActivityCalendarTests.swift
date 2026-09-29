import Foundation
import Testing
@testable import GentleWalkCore

@Suite struct ActivityCalendarTests {
    // 11:00 and 22:00 on Sep 28 in New York; 22:00 Sep 28 and 09:00 Sep 29 in Ho Chi Minh City.
    let records = [TestSupport.date("2026-09-28T15:00:00Z"), TestSupport.date("2026-09-29T02:00:00Z")]

    @Test func activeDaysFollowTheUsersTimeZone() {
        #expect(ActivityCalendar(records: records, restDays: [], calendar: TestSupport.newYork).activeDays == 1)
        #expect(ActivityCalendar(records: records, restDays: [], calendar: TestSupport.hoChiMinh).activeDays == 2)
    }

    @Test func weekMarksActiveAndRestDays() {
        let cal = TestSupport.newYork  // weeks start on Sunday
        let active = [(2026, 9, 21), (2026, 9, 23), (2026, 9, 26)].map { TestSupport.local(cal, $0.0, $0.1, $0.2) }
        let calendar = ActivityCalendar(records: active, restDays: [.saturday, .sunday], calendar: cal)
        let week = calendar.week(containing: TestSupport.local(cal, 2026, 9, 24))
        // Sun 20 … Sat 26: Sunday rest, Monday active, Wednesday active, Saturday active (active wins over rest).
        #expect(week.days.map(\.mark) == [.rest, .active, .open, .active, .open, .open, .active])
        #expect(week.activeDays == 3)
        #expect(week.restDays == 1)
    }

    @Test func thisWeekIsComparedWithLastWeekOnly() {
        let cal = TestSupport.newYork
        let lastWeek = [(2026, 9, 21), (2026, 9, 23)].map { TestSupport.local(cal, $0.0, $0.1, $0.2) }
        let thisWeek = [(2026, 9, 28), (2026, 9, 29), (2026, 9, 30)].map { TestSupport.local(cal, $0.0, $0.1, $0.2) }
        let now = TestSupport.local(cal, 2026, 10, 1)
        #expect(ActivityCalendar(records: lastWeek + thisWeek, restDays: [], calendar: cal).weekComparison(at: now) == .more(1))
        #expect(ActivityCalendar(records: lastWeek + thisWeek.prefix(2), restDays: [], calendar: cal).weekComparison(at: now) == .same)
        #expect(ActivityCalendar(records: lastWeek + thisWeek.prefix(1), restDays: [], calendar: cal).weekComparison(at: now) == .fewer)
    }

    @Test func atMostTwoRestDaysAWeek() {
        #expect(RestDays.validated([.saturday, .sunday]) == [.saturday, .sunday])
        #expect(RestDays.validated([.wednesday]) == [.wednesday])
        #expect(RestDays.validated([.monday, .wednesday, .friday]) == nil)
    }

    @Test func freeTierRestDaysAreWeekend() {
        #expect(RestDays.effective(chosen: [.wednesday, .sunday], entitlement: .free) == [.saturday, .sunday])
        #expect(RestDays.effective(chosen: [.wednesday, .sunday], entitlement: .subscribed) == [.wednesday, .sunday])
    }
}
