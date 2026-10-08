import Foundation
import Testing
@testable import GentleWalkCore

/// Today's greeting by time of day and season (plan 3.11).
@Suite struct GreetingsTests {
    let ny = TestSupport.newYork

    @Test func partOfDayAndSeason() {
        #expect(Greetings.dayPart(TestSupport.local(ny, 2026, 10, 8, 11, 59), calendar: ny) == .morning)
        #expect(Greetings.dayPart(TestSupport.local(ny, 2026, 10, 8, 12), calendar: ny) == .afternoon)
        #expect(Greetings.dayPart(TestSupport.local(ny, 2026, 10, 8, 17), calendar: ny) == .evening)
        #expect(Greetings.season(TestSupport.local(ny, 2026, 3, 1), calendar: ny) == .spring)
        #expect(Greetings.season(TestSupport.local(ny, 2026, 8, 31), calendar: ny) == .summer)
        #expect(Greetings.season(TestSupport.local(ny, 2026, 10, 8), calendar: ny) == .autumn)
        #expect(Greetings.season(TestSupport.local(ny, 2026, 12, 1), calendar: ny) == .winter)
    }

    /// Seven mornings in a row, seven different greetings; the next day moves on, never the same as yesterday.
    @Test func neverRepeatsWithinAWeek() {
        for hour in [8, 14, 19] {
            let week = (1...7).map { Greetings.pick(now: TestSupport.local(ny, 2026, 10, $0, hour), calendar: ny).id }
            #expect(Set(week).count == 7, "hour \(hour): \(week)")
        }
        // Across a season change (Nov 30 → Dec 1) consecutive days still differ.
        let a = Greetings.pick(now: TestSupport.local(ny, 2026, 11, 30, 8), calendar: ny)
        let b = Greetings.pick(now: TestSupport.local(ny, 2026, 12, 1, 8), calendar: ny)
        #expect(a.id != b.id)
    }

    @Test func seasonalGreetingReadsRight() {
        #expect(Greetings.pool(.morning, season: .autumn).last?.text == "An autumn morning")
        #expect(Greetings.pool(.evening, season: .winter).last?.withName == "A winter evening, %@")
    }

    /// Every greeting has its named form with one "%@", a Vietnamese translation for both, and no weather.
    @Test func everyGreetingIsTranslatedAndClaimFree() throws {
        let vietnamese = try TestSupport.vietnameseUI()
        for part in DayPart.allCases {
            for season in Season.allCases {
                for greeting in Greetings.pool(part, season: season) {
                    #expect(greeting.withName.components(separatedBy: "%@").count == 2, "\(greeting.id)")
                    #expect(vietnamese[greeting.text]?.isEmpty == false, "VI \(greeting.text)")
                    #expect(vietnamese[greeting.withName]?.contains("%@") == true, "VI \(greeting.withName)")
                    for weather in ["sun", "rain", "cold", "warm", "hot", "snow", "chill", "bright", "cloud", "fall"] {
                        #expect(!greeting.text.lowercased().contains(weather), "\(greeting.text): \(weather)")
                    }
                }
            }
        }
    }

    /// The Vietnamese files never give one English key two different translations (the catalog keeps one).
    @Test func noConflictingTranslations() throws {
        let folder = TestSupport.repositoryRoot.appendingPathComponent("docs/i18n/vi")
        var seen: [String: (String, String)] = [:]
        for file in try FileManager.default.contentsOfDirectory(atPath: folder.path) where file.hasPrefix("ui") && file.hasSuffix(".json") {
            let pairs = try JSONDecoder().decode([String: String].self, from: Data(contentsOf: folder.appendingPathComponent(file)))
            for (key, value) in pairs {
                if let earlier = seen[key] { #expect(earlier.0 == value, "\(key): \(earlier.1) vs \(file)") }
                seen[key] = (value, file)
            }
        }
    }
}
