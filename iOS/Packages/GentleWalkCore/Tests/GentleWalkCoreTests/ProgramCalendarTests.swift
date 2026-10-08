import Foundation
import Testing
@testable import GentleWalkCore

@Suite struct ProgramCalendarTests {
    let ny = TestSupport.newYork

    func round(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12, minute: Int = 0) -> ProgramRound {
        ProgramRound(start: TestSupport.local(ny, year, month, day, hour, minute))
    }

    @Test func weekAndStageFromStartDate() {
        let program = round(2026, 10, 8)
        #expect(ProgramCalendar.position(program, on: TestSupport.local(ny, 2026, 10, 8), calendar: ny) == .week(1, .base))
        #expect(ProgramCalendar.position(program, on: TestSupport.local(ny, 2026, 10, 29), calendar: ny) == .week(4, .build))
        #expect(ProgramCalendar.position(program, on: TestSupport.local(ny, 2026, 12, 24), calendar: ny) == .week(12, .routine))
        #expect(ProgramCalendar.position(program, on: TestSupport.local(ny, 2026, 12, 31), calendar: ny) == .finished)
    }

    /// Weeks follow calendar days in her time zone: the hour gained when daylight saving ends (1 Nov
    /// 2026 in the US) must not push a late-evening session into the next week.
    @Test(arguments: ["America/New_York", "America/Los_Angeles"])
    func weeksCountCalendarDaysAcrossDaylightSaving(zone: String) {
        let calendar = TestSupport.calendar(zone)
        let program = ProgramRound(start: TestSupport.local(calendar, 2026, 10, 28, 0, 30))
        let lastEveningOfWeekOne = TestSupport.local(calendar, 2026, 11, 3, 23, 59)
        let firstMorningOfWeekTwo = TestSupport.local(calendar, 2026, 11, 4, 0, 10)
        #expect(ProgramCalendar.position(program, on: lastEveningOfWeekOne, calendar: calendar) == .week(1, .base))
        #expect(ProgramCalendar.position(program, on: firstMorningOfWeekTwo, calendar: calendar) == .week(2, .base))
    }

    /// Two weeks or more without a session: offer to pick up at the week she stopped (plan 2.3).
    @Test func longGapOffersPickUp() {
        let program = round(2026, 10, 8)
        let lastWorkout = TestSupport.local(ny, 2026, 10, 20)
        let afterSixteenDays = TestSupport.local(ny, 2026, 11, 5)
        let afterThirteenDays = TestSupport.local(ny, 2026, 11, 2)
        #expect(ProgramCalendar.resumeOffer(program, lastWorkout: lastWorkout, now: afterSixteenDays, calendar: ny)
            == .pickUp(atWeek: 2))
        #expect(ProgramCalendar.resumeOffer(program, lastWorkout: lastWorkout, now: afterThirteenDays, calendar: ny) == nil)
        #expect(ProgramCalendar.resumeOffer(program, lastWorkout: nil, now: afterSixteenDays, calendar: ny) == nil)

        let pickedUp = ProgramCalendar.pickUp(program, lastWorkout: lastWorkout, now: afterSixteenDays, calendar: ny)
        #expect(ProgramCalendar.position(pickedUp, on: afterSixteenDays, calendar: ny) == .week(2, .base))
        #expect(ProgramCalendar.position(pickedUp, on: TestSupport.local(ny, 2026, 11, 12), calendar: ny) == .week(3, .base))
    }

    /// A finished round starts again from week 1; the round number goes up (plan 2.4).
    @Test func restartKeepsCountingRounds() {
        let program = round(2026, 10, 8)
        let newYear = TestSupport.local(ny, 2027, 1, 2)
        #expect(ProgramCalendar.position(program, on: newYear, calendar: ny) == .finished)
        let again = ProgramCalendar.restart(program, on: newYear, calendar: ny)
        #expect(again.round == 2)
        #expect(again.pausedDays == 0)
        #expect(ProgramCalendar.position(again, on: newYear, calendar: ny) == .week(1, .base))
        // Stopping in week 8 and coming back after the twelve weeks would have ended is not "finished":
        // she is offered week 8 again.
        #expect(ProgramCalendar.resumeOffer(program, lastWorkout: TestSupport.local(ny, 2026, 12, 1), now: newYear,
                                            calendar: ny) == .pickUp(atWeek: 8))
    }

    @Test func aLateStartCountsItsOwnDay() {
        let program = round(2026, 10, 8, hour: 23, minute: 30)
        #expect(ProgramCalendar.position(program, on: TestSupport.local(ny, 2026, 10, 15, 8), calendar: ny) == .week(2, .base))
    }
}
