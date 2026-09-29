import Testing
@testable import GentleWalkCore

@Suite struct ActivityDistanceTests {
    @Test func twelveMinutesIsPointSixMiles() {
        #expect(abs(ActivityDistance.miles(activeMinutes: 12) - 0.6) < 0.000_1)
    }

    @Test func outdoorUsesMeasuredDistance() {
        #expect(ActivityDistance.miles(activeMinutes: 12, outdoorMiles: 0.83) == 0.83)
    }

    @Test func noMinutesNoMiles() {
        #expect(ActivityDistance.miles(activeMinutes: 0) == 0)
        #expect(ActivityDistance.miles(activeMinutes: -3) == 0)
    }
}
