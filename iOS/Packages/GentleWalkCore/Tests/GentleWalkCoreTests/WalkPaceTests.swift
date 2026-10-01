import Testing
@testable import GentleWalkCore

/// Live outdoor stats (30/09/2026): pace in minutes per mile, shown once there is a real distance.
@Suite struct WalkPaceTests {
    @Test func paceIsMinutesPerMile() {
        // 0.5 mi in 10 minutes: 20 min/mi.
        #expect(WalkPace.minutesPerMile(seconds: 600, miles: 0.5) == 20)
    }

    @Test func noPaceBeforeARealDistance() {
        #expect(WalkPace.minutesPerMile(seconds: 60, miles: 0.01) == nil)
        #expect(WalkPace.minutesPerMile(seconds: 0, miles: 0.2) == nil)
    }

    @Test func paceReadsAsMinutesAndSeconds() {
        #expect(WalkPace.text(minutesPerMile: 18.5) == "18:30")
        #expect(WalkPace.text(minutesPerMile: nil) == "–:––")
        // A walker standing still: no absurd pace.
        #expect(WalkPace.text(minutesPerMile: 120) == "–:––")
    }
}
