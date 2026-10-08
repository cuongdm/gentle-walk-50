import Foundation

/// Morning (before noon), afternoon (noon to 5 PM), evening.
public enum DayPart: String, CaseIterable, Sendable { case morning, afternoon, evening }

/// Calendar seasons by month (US first; the app does not ask where she lives). Only ever named, never
/// a weather claim.
public enum Season: String, CaseIterable, Sendable { case spring, summer, autumn, winter }

/// One greeting for Today, with and without her name. English source; the app shows it through the
/// String Catalog (Vietnamese in docs/i18n/vi/ui-extra-11.json). `withName` holds one "%@".
public struct Greeting: Equatable, Sendable {
    public var id: String
    public var text: String
    public var withName: String
}

/// Today's greeting (plan 3.11): six for each part of the day plus one for the season, turning with the
/// calendar day, so the same part of the day never repeats a greeting within a week.
public enum Greetings {
    public static func dayPart(_ date: Date, calendar: Calendar) -> DayPart {
        switch calendar.component(.hour, from: date) {
        case ..<12: .morning
        case 12..<17: .afternoon
        default: .evening
        }
    }

    public static func season(_ date: Date, calendar: Calendar) -> Season {
        switch calendar.component(.month, from: date) {
        case 3...5: .spring
        case 6...8: .summer
        case 9...11: .autumn
        default: .winter
        }
    }

    public static func pick(now: Date, calendar: Calendar) -> Greeting {
        let pool = pool(dayPart(now, calendar: calendar), season: season(now, calendar: calendar))
        let day = calendar.ordinality(of: .day, in: .era, for: now) ?? 0
        return pool[day % pool.count]
    }

    public static func pool(_ part: DayPart, season: Season) -> [Greeting] {
        let base: [(String, String)] = switch part {
        case .morning: [
            ("Good morning", "Good morning, %@"), ("Morning", "Morning, %@"),
            ("Hello, and good morning", "Hello %@, and good morning"), ("Good morning to you", "Good morning to you, %@"),
            ("A new morning", "A new morning, %@"), ("Hello this morning", "Hello this morning, %@"),
        ]
        case .afternoon: [
            ("Good afternoon", "Good afternoon, %@"), ("Afternoon", "Afternoon, %@"),
            ("Hello, and good afternoon", "Hello %@, and good afternoon"), ("Good afternoon to you", "Good afternoon to you, %@"),
            ("Hello there", "Hello there, %@"), ("Hello this afternoon", "Hello this afternoon, %@"),
        ]
        case .evening: [
            ("Good evening", "Good evening, %@"), ("Evening", "Evening, %@"),
            ("Hello, and good evening", "Hello %@, and good evening"), ("Good evening to you", "Good evening to you, %@"),
            ("Hello this evening", "Hello this evening, %@"), ("Nice to see you this evening", "Nice to see you this evening, %@"),
        ]
        }
        let seasonal = "\(season == .autumn ? "An" : "A") \(season.rawValue) \(part.rawValue)"
        let all = base + [(seasonal, "\(seasonal), %@")]
        return all.enumerated().map {
            Greeting(id: "greeting.\(part.rawValue).\($0.offset < base.count ? "\($0.offset + 1)" : season.rawValue)",
                     text: $0.element.0, withName: $0.element.1)
        }
    }
}
