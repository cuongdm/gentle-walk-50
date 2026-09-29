import Foundation
import Testing
@testable import GentleWalkCore

@Suite struct JourneyAccessTests {
    static let pro: [Entitlement] = [.trial(ends: TestSupport.date("2026-10-11T14:00:00Z")), .subscribed, .lifetime]

    @Test func freeWalksAllOfNewYork() {
        #expect(JourneyAccess.limitMile(for: TestSupport.newYorkJourney, entitlement: .free) == nil)
    }

    @Test func freeStopsAtTheFirstPostcardOfAPaidRoute() {
        #expect(JourneyAccess.limitMile(for: TestSupport.paidJourney, entitlement: .free) == 0)
    }

    @Test(arguments: pro)
    func proWalksEveryRoute(_ entitlement: Entitlement) {
        #expect(JourneyAccess.limitMile(for: TestSupport.paidJourney, entitlement: entitlement) == nil)
        #expect(JourneyAccess.limitMile(for: TestSupport.newYorkJourney, entitlement: entitlement) == nil)
    }

    @Test func routeMilesStopAtTheLimitButTotalMilesKeepCounting() {
        let capped = JourneyAccess.routeMiles(total: 3.4, limit: 0)
        #expect(capped == 0)
        #expect(JourneyAccess.routeMiles(total: 3.4, limit: nil) == 3.4)
    }
}
