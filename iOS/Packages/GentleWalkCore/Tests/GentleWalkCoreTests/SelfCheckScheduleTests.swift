import Foundation
import Testing
@testable import GentleWalkCore

@Suite struct SelfCheckScheduleTests {
    let ny = TestSupport.newYork

    func day(_ month: Int, _ day: Int) -> Date { TestSupport.local(ny, 2026, month, day) }

    func status(first: Date?, results: [Date] = [], dismissed: Date? = nil, now: Date) -> SelfCheckStatus {
        SelfCheckSchedule.status(firstWorkout: first, results: results, dismissedAt: dismissed, now: now, calendar: ny)
    }

    /// Week 0 comes after the first session (owner 08/10/2026); "Later" asks again two days on.
    @Test func firstCheckAfterFirstWorkout() {
        #expect(status(first: nil, now: day(10, 8)) == .none)
        #expect(status(first: day(10, 8), now: day(10, 8)) == .invite)
        #expect(status(first: day(10, 8), dismissed: day(10, 8), now: day(10, 9)) == .none)
        #expect(status(first: day(10, 8), dismissed: day(10, 8), now: day(10, 10)) == .due)
    }

    /// Every two weeks: shown as coming up, then due from day 12 to day 17, then "whenever you're ready".
    @Test func everyTwoWeeksWithWindow() {
        let first = day(10, 1)
        let check = day(10, 8)
        #expect(status(first: first, results: [check], now: day(10, 8)) == .dueIn(days: 14))
        #expect(status(first: first, results: [check], now: day(10, 17)) == .dueIn(days: 5))
        #expect(status(first: first, results: [check], now: day(10, 20)) == .due)
        #expect(status(first: first, results: [check], now: day(10, 25)) == .due)
        #expect(status(first: first, results: [check], now: day(10, 26)) == .overdue)
        // The latest check counts, whatever order they come in.
        #expect(status(first: first, results: [day(10, 22), check], now: day(10, 24)) == .dueIn(days: 12))
    }

    /// The reminder goes out two weeks after the latest check; none before the first.
    @Test func dueDateIsTwoWeeksAfterLatest() {
        #expect(SelfCheckSchedule.dueDate(results: [], calendar: ny) == nil)
        let due = SelfCheckSchedule.dueDate(results: [day(10, 1), TestSupport.local(ny, 2026, 10, 8, 19, 30)], calendar: ny)
        #expect(due == ny.startOfDay(for: day(10, 22)))
        // Across the end of daylight saving (Nov 1 in New York) it is still a calendar day.
        #expect(SelfCheckSchedule.dueDate(results: [day(10, 25)], calendar: ny) == ny.startOfDay(for: day(11, 8)))
    }
}
