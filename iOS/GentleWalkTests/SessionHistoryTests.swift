import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

/// Progress history (owner 01/10/2026): what one session says, a day's sessions, months.
@MainActor @Suite struct SessionHistoryTests {
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York")!
        calendar.locale = Locale(identifier: "en_US")
        return calendar
    }()

    func date(_ month: Int, _ day: Int, _ hour: Int = 9) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour))!
    }

    func record(_ date: Date, kind: String = "walk", place: String = "indoors", seconds: Int = 600,
                feeling: Feeling? = nil, outdoorMiles: Double? = nil) -> WorkoutRecord {
        WorkoutRecord(date: date, kind: kind, level: "seated", intensity: "steady", place: place, activeSeconds: seconds,
                      journeyMiles: 0.5, outdoorMiles: outdoorMiles, feeling: feeling?.rawValue)
    }

    @Test func aRecordReadsAsTheAppsSessionWords() {
        let outdoor = SessionHistoryItem(record: record(date(9, 28), place: "outdoors", seconds: 470, feeling: .tooEasy,
                                                        outdoorMiles: 0.9))
        #expect(outdoor.title == "Outdoor walk")
        #expect(outdoor.minutes == 8)
        #expect(outdoor.detail(showsDate: true).contains("8 min"))
        #expect(outdoor.detail(showsDate: true).contains("walked"))
        #expect(outdoor.detail(showsDate: true).hasSuffix("Too easy"))

        #expect(SessionHistoryItem(record: record(date(9, 28), kind: "chair")).title == "Chair moves")
        #expect(SessionHistoryItem(record: record(date(9, 28), kind: "firstWalk")).title == "First walk")
        // A session under half a minute still shows a minute, never "0 min".
        #expect(SessionHistoryItem(record: record(date(9, 28), seconds: 20)).minutes == 1)
    }

    @Test func noFeelingAndNoDistanceAreLeftOut() {
        let item = SessionHistoryItem(record: record(date(9, 28), kind: "stretch"))
        #expect(item.detail(showsDate: true).components(separatedBy: " · ").count == 2)
    }

    @Test func aDayListsItsSessionsInOrderAndTheListIsNewestFirst() {
        let items = SessionHistoryItem.list([
            record(date(9, 30, 16), kind: "balance"), record(date(9, 29)), record(date(9, 30, 8), kind: "chair"),
        ])
        #expect(items.map(\.kind) == [.balance, .chair, .walk])
        let day = SessionHistoryItem.on(date(9, 30), in: items, calendar: calendar)
        #expect(day.map(\.kind) == [.chair, .balance])
    }

    @Test func monthsGroupNewestFirst() {
        let items = SessionHistoryItem.list([record(date(8, 31)), record(date(9, 1)), record(date(9, 20))])
        let months = SessionHistoryItem.byMonth(items, calendar: calendar)
        #expect(months.count == 2)
        #expect(months[0].items.count == 2)
        #expect(calendar.component(.month, from: months[0].month) == 9)
        #expect(calendar.component(.month, from: months[1].month) == 8)
    }
}
