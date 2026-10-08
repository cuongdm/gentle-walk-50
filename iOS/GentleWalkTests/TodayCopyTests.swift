import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

/// The app's words for the core's greetings and week themes (plan 08/10/2026 tasks 3.10, 3.11): every id
/// has its String Catalog literal, and the English is the core's source word for word.
@Suite struct TodayCopyTests {
    @Test(arguments: DayPart.allCases)
    func everyGreetingHasItsEnglishWords(_ part: DayPart) {
        for season in Season.allCases {
            for greeting in Greetings.pool(part, season: season) {
                #expect(GreetingText.text(greeting, name: nil) == greeting.text, "\(greeting.id)")
                #expect(GreetingText.text(greeting, name: "Ann") == greeting.withName.replacingOccurrences(of: "%@", with: "Ann"),
                        "\(greeting.id)")
            }
        }
    }

    @Test(arguments: WeekTheme.allCases)
    func everyWeekHasItsEnglishWords(_ theme: WeekTheme) {
        #expect(String(localized: theme.localizedTitle) == theme.title)
        #expect(String(localized: theme.localizedLine) == theme.line)
        #expect(theme.kicker == "Week \(theme.week) · \(theme.title)")
    }

    @Test func onlyWeeksWithSomethingNewHaveNews() {
        #expect(WeekTheme.firstSteps.newsLine == "Your 12 weeks start today.")
        #expect(WeekTheme.aLittleMore.newsLine == "Stage 2 starts this week: Building strength.")
        #expect(WeekTheme.tryingTheNextStep.newsLine == "Stage 3 starts this week: Gentle challenge.")
        #expect(WeekTheme.lookingBack.newsLine == "Your last week of the 12. Look how far you've come.")
        let quiet = WeekTheme.allCases.filter { $0.newThisWeek == nil }
        #expect(quiet.allSatisfy { $0.newsLine == nil })
        #expect(quiet.count == 7)
    }
}
