import Foundation

/// Counted phrases with automatic grammar agreement ("1 active day", "13 active days").
enum Plural {
    static func activeDays(_ count: Int) -> String {
        String(AttributedString(localized: "^[\(count) active day](inflect: true)").characters)
    }

    /// The label under a big number: "active day" / "active days".
    static func activeDaysLabel(_ count: Int) -> String {
        count == 1 ? String(localized: "active day") : String(localized: "active days")
    }

    static func minutes(_ count: Int) -> String {
        String(AttributedString(localized: "^[\(count) minute](inflect: true)").characters)
    }
}
