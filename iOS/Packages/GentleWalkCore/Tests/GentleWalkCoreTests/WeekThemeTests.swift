import Foundation
import Testing
@testable import GentleWalkCore

/// One theme a week for the 12 weeks (plan 3.10, anti-boredom #3): new in content, steady in layout.
@Suite struct WeekThemeTests {
    @Test func twelveThemesOnePerWeekInTheirStage() {
        #expect(WeekTheme.allCases.count == ProgramCalendar.weeks)
        for week in 1...ProgramCalendar.weeks {
            let theme = WeekTheme.forWeek(week)
            #expect(theme.week == week)
            #expect(theme.stage == ProgramStage.of(week: week))
        }
        #expect(Set(WeekTheme.allCases.map(\.title)).count == 12)
        #expect(WeekTheme.forWeek(0) == .firstSteps && WeekTheme.forWeek(13) == .lookingBack)
    }

    @Test func themeFollowsTheProgramPosition() {
        #expect(WeekTheme.of(.week(5, .build)) == .upFromTheChair)
        #expect(WeekTheme.of(.finished) == nil)
    }

    /// "New this week" only when something really is new: the start, a new stage, the last week.
    @Test func newThisWeekIsHonest() {
        let news = (1...12).map { WeekTheme.forWeek($0).newThisWeek }
        #expect(news[0] == .programStarts)
        #expect(news[3] == .stageStarts(.build) && news[6] == .stageStarts(.challenge) && news[9] == .stageStarts(.routine))
        #expect(news[11] == .lastWeek)
        #expect(news.compactMap { $0 }.count == 5)
    }

    /// Short and claim-free (docs/design/steady-claims.md): 2–4 words, no medical or fall words.
    @Test func titlesAreShortAndClaimFree() {
        for theme in WeekTheme.allCases {
            let words = theme.title.split(separator: " ").count
            #expect((2...4).contains(words), "\(theme.title)")
            for banned in ["fall", "risk", "pain", "bone", "cure", "heal", "senior"] {
                #expect(!theme.title.lowercased().contains(banned), "\(theme.title)")
            }
        }
    }

    /// Each week has one line, short, claim-free and translated (title and line).
    @Test func everyWeekHasALineInBothLanguages() throws {
        let vietnamese = try TestSupport.vietnameseUI()
        #expect(Set(WeekTheme.allCases.map(\.line)).count == 12)
        for theme in WeekTheme.allCases {
            #expect(theme.line.split(separator: " ").count <= 16, "\(theme)")
            #expect(vietnamese[theme.title]?.isEmpty == false, "VI \(theme.title)")
            #expect(vietnamese[theme.line]?.isEmpty == false, "VI \(theme.line)")
            for banned in ["fall", "risk", "pain", "bone", "new move", "new exercise", "guarantee"] {
                #expect(!theme.line.lowercased().contains(banned), "\(theme): \(banned)")
            }
        }
    }
}

