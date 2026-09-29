import Testing
@testable import GentleWalkCore

@Suite struct WelcomeBackTests {
    let cal = TestSupport.newYork
    let weekend: Set<Weekday> = [.saturday, .sunday]

    @Test func twoMissedPlanDaysOfferAGentleRestart() {
        // Last workout Monday Sep 28; today Thursday Oct 1: Tuesday and Wednesday missed.
        let state = WelcomeBack.state(lastWorkout: TestSupport.local(cal, 2026, 9, 28), restDays: weekend,
                                      now: TestSupport.local(cal, 2026, 10, 1, 9), calendar: cal)
        #expect(state == .gentleRestart(minutes: 5))
    }

    @Test func oneMissedDayIsNothing() {
        #expect(WelcomeBack.state(lastWorkout: TestSupport.local(cal, 2026, 9, 28), restDays: weekend,
                                  now: TestSupport.local(cal, 2026, 9, 30, 9), calendar: cal) == nil)
    }

    @Test func plannedRestDaysDoNotCount() {
        // Friday → Tuesday with Saturday and Sunday off: only Monday missed.
        #expect(WelcomeBack.state(lastWorkout: TestSupport.local(cal, 2026, 9, 25), restDays: weekend,
                                  now: TestSupport.local(cal, 2026, 9, 29, 9), calendar: cal) == nil)
        // Friday → Wednesday: Monday and Tuesday missed.
        #expect(WelcomeBack.state(lastWorkout: TestSupport.local(cal, 2026, 9, 25), restDays: weekend,
                                  now: TestSupport.local(cal, 2026, 9, 30, 9), calendar: cal) == .gentleRestart(minutes: 5))
    }

    @Test func noWorkoutYetIsNotAReturn() {
        #expect(WelcomeBack.state(lastWorkout: nil, restDays: weekend, now: TestSupport.local(cal, 2026, 9, 30), calendar: cal) == nil)
    }
}
