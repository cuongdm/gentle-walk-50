import Foundation
import Testing
@testable import GentleWalk

/// Units (owner 02/10/2026): the iPhone's region picks the first choice, Me changes it, and every
/// distance on screen follows (kept in miles inside).
@MainActor @Suite(.serialized) struct UnitPreferencesTests {
    @Test func regionPicksTheDefault() {
        let us = UnitPreferences.regionDefault(Locale(identifier: "en_US"))
        #expect(us == UnitPreferences(distance: .miles, weight: .pounds, height: .feetInches))
        let vn = UnitPreferences.regionDefault(Locale(identifier: "vi_VN"))
        #expect(vn == UnitPreferences(distance: .kilometers, weight: .kilograms, height: .centimeters))
        let uk = UnitPreferences.regionDefault(Locale(identifier: "en_GB"))
        #expect(uk.distance == .miles)
    }

    @Test func aChoiceIsKept() throws {
        let defaults = try #require(UserDefaults(suiteName: "UnitPreferencesTests"))
        defaults.removePersistentDomain(forName: "UnitPreferencesTests")
        var units = UnitPreferences(defaults: defaults, locale: Locale(identifier: "en_US"))
        #expect(units.distance == .miles)
        units.distance = .kilometers
        units.weight = .kilograms
        units.save(to: defaults)
        let read = UnitPreferences(defaults: defaults, locale: Locale(identifier: "en_US"))
        #expect(read.distance == .kilometers)
        #expect(read.weight == .kilograms)
        #expect(read.height == .feetInches)
    }

    @Test func distancesFollowTheUnit() {
        #expect(abs(DistanceText.value(miles: 5, unit: .kilometers) - 8.04672) < 0.0001)
        #expect(DistanceText.value(miles: 5, unit: .miles) == 5)
        #expect(DistanceText.number(miles: 5, unit: .kilometers).hasPrefix("8"))
        #expect(DistanceText.text(miles: 1, unit: .kilometers).contains("km"))
        // 16 minutes a mile is 9 minutes 57 seconds a kilometre.
        #expect(abs((DistanceText.pace(minutesPerMile: 16, unit: .kilometers) ?? 0) - 9.94) < 0.01)
    }
}
