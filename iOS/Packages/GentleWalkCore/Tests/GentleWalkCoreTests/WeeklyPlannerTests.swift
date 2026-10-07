import Foundation
import Testing
@testable import GentleWalkCore

@Suite struct WeeklyPlannerTests {
    typealias Day = PlannedDay
    let weekend: Set<Weekday> = [.saturday, .sunday]

    @Test func proWeekWithWeekendRest() {
        let week = WeeklyPlanner.week(restDays: weekend, entitlement: .subscribed)
        let steady = PlannedDay.SteadySet.matchingIntensity
        #expect(week[.monday] == Day(main: .walk, chairMoves: 1, cooldown: false, steadySet: steady))
        #expect(week[.tuesday] == Day(main: .stretch, chairMoves: 0, cooldown: false, steadySet: steady))
        #expect(week[.wednesday] == Day(main: .walk, chairMoves: 2, cooldown: false, steadySet: steady))
        #expect(week[.thursday] == Day(main: .chair, chairMoves: 0, cooldown: true, steadySet: steady))
        #expect(week[.friday] == Day(main: .longWalk, chairMoves: 0, cooldown: true, steadySet: steady))
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

    /// Balance on at least three days a week for everyone (World Falls Guidelines 2022, review 06/10/2026 Q2):
    /// the free plan gets the gentle two-hands set, Pro follows the day's intensity.
    @Test func everyTrainingDayEndsWithASteadySet() {
        let free = WeeklyPlanner.week(restDays: weekend, entitlement: .free)
        #expect(free.values.filter { !$0.isRest }.allSatisfy { $0.steadySet == .gentle })
        let pro = WeeklyPlanner.week(restDays: weekend, entitlement: .lifetime)
        #expect(pro.values.filter { !$0.isRest }.allSatisfy { $0.steadySet == .matchingIntensity })
        #expect(pro.values.filter(\.isRest).allSatisfy { $0.steadySet == nil })
    }

    @Test func anyChoiceOfRestDaysLeavesAtLeastThreeSteadyDays() {
        let days = WeeklyPlanner.order
        for entitlement in [Entitlement.free, .subscribed] {
            for first in days {
                for second in days {
                    let week = WeeklyPlanner.week(restDays: [first, second], entitlement: entitlement)
                    #expect(week.values.filter { $0.steadySet != nil }.count >= 3, "\(first) \(second)")
                }
            }
        }
    }

    @Test func dayForADateUsesTheCalendarWeekday() {
        let cal = TestSupport.newYork
        let tuesday = TestSupport.local(cal, 2026, 9, 29)
        #expect(WeeklyPlanner.day(for: tuesday, restDays: weekend, entitlement: .subscribed, calendar: cal).main == .stretch)
        let saturday = TestSupport.local(cal, 2026, 10, 3)
        #expect(WeeklyPlanner.day(for: saturday, restDays: weekend, entitlement: .subscribed, calendar: cal).isRest)
    }
}
