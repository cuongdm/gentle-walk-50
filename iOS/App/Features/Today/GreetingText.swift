import Foundation
import GentleWalkCore

/// Today's greeting in her language (plan 08/10/2026 task 3.11). The core picks it (`Greetings.pick`: six
/// for each part of the day and one for the season, turning with the calendar day); here each id has its
/// English literal, which is the String Catalog key (Vietnamese in docs/i18n/vi/ui-extra-11.json).
/// `TodayCopyTests` checks every id against the core's words.
enum GreetingText {
    static func text(_ greeting: Greeting, name: String?) -> String {
        switch greeting.id {
        case "greeting.morning.1": name.map { String(localized: "Good morning, \($0)") } ?? String(localized: "Good morning")
        case "greeting.morning.2": name.map { String(localized: "Morning, \($0)") } ?? String(localized: "Morning")
        case "greeting.morning.3": name.map { String(localized: "Hello \($0), and good morning") } ?? String(localized: "Hello, and good morning")
        case "greeting.morning.4": name.map { String(localized: "Good morning to you, \($0)") } ?? String(localized: "Good morning to you")
        case "greeting.morning.5": name.map { String(localized: "A new morning, \($0)") } ?? String(localized: "A new morning")
        case "greeting.morning.6": name.map { String(localized: "Hello this morning, \($0)") } ?? String(localized: "Hello this morning")
        case "greeting.morning.spring": name.map { String(localized: "A spring morning, \($0)") } ?? String(localized: "A spring morning")
        case "greeting.morning.summer": name.map { String(localized: "A summer morning, \($0)") } ?? String(localized: "A summer morning")
        case "greeting.morning.autumn": name.map { String(localized: "An autumn morning, \($0)") } ?? String(localized: "An autumn morning")
        case "greeting.morning.winter": name.map { String(localized: "A winter morning, \($0)") } ?? String(localized: "A winter morning")
        case "greeting.afternoon.1": name.map { String(localized: "Good afternoon, \($0)") } ?? String(localized: "Good afternoon")
        case "greeting.afternoon.2": name.map { String(localized: "Afternoon, \($0)") } ?? String(localized: "Afternoon")
        case "greeting.afternoon.3": name.map { String(localized: "Hello \($0), and good afternoon") } ?? String(localized: "Hello, and good afternoon")
        case "greeting.afternoon.4": name.map { String(localized: "Good afternoon to you, \($0)") } ?? String(localized: "Good afternoon to you")
        case "greeting.afternoon.5": name.map { String(localized: "Hello there, \($0)") } ?? String(localized: "Hello there")
        case "greeting.afternoon.6": name.map { String(localized: "Hello this afternoon, \($0)") } ?? String(localized: "Hello this afternoon")
        case "greeting.afternoon.spring": name.map { String(localized: "A spring afternoon, \($0)") } ?? String(localized: "A spring afternoon")
        case "greeting.afternoon.summer": name.map { String(localized: "A summer afternoon, \($0)") } ?? String(localized: "A summer afternoon")
        case "greeting.afternoon.autumn": name.map { String(localized: "An autumn afternoon, \($0)") } ?? String(localized: "An autumn afternoon")
        case "greeting.afternoon.winter": name.map { String(localized: "A winter afternoon, \($0)") } ?? String(localized: "A winter afternoon")
        case "greeting.evening.1": name.map { String(localized: "Good evening, \($0)") } ?? String(localized: "Good evening")
        case "greeting.evening.2": name.map { String(localized: "Evening, \($0)") } ?? String(localized: "Evening")
        case "greeting.evening.3": name.map { String(localized: "Hello \($0), and good evening") } ?? String(localized: "Hello, and good evening")
        case "greeting.evening.4": name.map { String(localized: "Good evening to you, \($0)") } ?? String(localized: "Good evening to you")
        case "greeting.evening.5": name.map { String(localized: "Hello this evening, \($0)") } ?? String(localized: "Hello this evening")
        case "greeting.evening.6": name.map { String(localized: "Nice to see you this evening, \($0)") } ?? String(localized: "Nice to see you this evening")
        case "greeting.evening.spring": name.map { String(localized: "A spring evening, \($0)") } ?? String(localized: "A spring evening")
        case "greeting.evening.summer": name.map { String(localized: "A summer evening, \($0)") } ?? String(localized: "A summer evening")
        case "greeting.evening.autumn": name.map { String(localized: "An autumn evening, \($0)") } ?? String(localized: "An autumn evening")
        case "greeting.evening.winter": name.map { String(localized: "A winter evening, \($0)") } ?? String(localized: "A winter evening")
        // A greeting the app does not know yet: the plain hello of that part of the day.
        default: name.map { String(localized: "Hello there, \($0)") } ?? String(localized: "Hello there")
        }
    }
}
