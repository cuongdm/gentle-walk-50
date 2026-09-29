import Foundation
import Testing
@testable import GentleWalkCore

@Suite struct WeeklyPlannerTests {
    typealias Day = PlannedDay
    let weekend: Set<Weekday> = [.saturday, .sunday]

    @Test func proWeekWithWeekendRest() {
        let week = WeeklyPlanner.week(restDays: weekend, entitlement: .subscribed)
        #expect(week[.monday] == Day(main: .walk, chairMoves: 1, cooldown: false))
        #expect(week[.tuesday] == Day(main: .stretch, chairMoves: 0, cooldown: false))
        #expect(week[.wednesday] == Day(main: .walk, chairMoves: 2, cooldown: false))
        #expect(week[.thursday] == Day(main: .chair, chairMoves: 0, cooldown: true))
        #expect(week[.friday] == Day(main: .longWalk, chairMoves: 0, cooldown: true))
        #expect(week[.saturday] == .rest)
        #expect(week[.sunday] == .rest)
    }

    @Test func movingRestDaysShiftsThePlanAndKeepsAllThreeKinds() {
        let week = WeeklyPlanner.week(restDays: [.wednesday, .sunday], entitlement: .lifetime)
        #expect(week[.wednesday] == .rest)
        #expect(week[.sunday] == .rest)
        #expect(week[.thursday]?.main == .walk)
        #expect(week[.saturday]?.main == .longWalk)
        let kinds = Set(week.values.compactMap(\.main))
        #expect(kinds.isSuperset(of: [.walk, .chair, .stretch]))
    }

    @Test func freeIsAWalkEveryDayWithAlternatingChairMovesAndAShortCooldown() {
        let week = WeeklyPlanner.week(restDays: weekend, entitlement: .free)
        let weekdays: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday]
        #expect(weekdays.allSatisfy { week[$0]?.main == .walk && week[$0]?.cooldown == true })
        #expect(weekdays.map { week[$0]?.chairMoves } == [1, 2, 1, 2, 1])
    }

    @Test func freeRestDaysAreAlwaysTheWeekend() {
        let week = WeeklyPlanner.week(restDays: [.monday, .tuesday], entitlement: .free)
        #expect(week[.saturday] == .rest)
        #expect(week[.sunday] == .rest)
        #expect(week[.monday]?.main == .walk)
    }

    @Test func dayForADateUsesTheCalendarWeekday() {
        let cal = TestSupport.newYork
        let tuesday = TestSupport.local(cal, 2026, 9, 29)
        #expect(WeeklyPlanner.day(for: tuesday, restDays: weekend, entitlement: .subscribed, calendar: cal).main == .stretch)
        let saturday = TestSupport.local(cal, 2026, 10, 3)
        #expect(WeeklyPlanner.day(for: saturday, restDays: weekend, entitlement: .subscribed, calendar: cal).isRest)
    }
}
