/// The coach recalls her own history in one line a session (P7, script docs/scripts/A13-coach-history.md):
/// whole recorded sentences with the number in them (D12), never a number spliced in. Out of range: no
/// line (silence beats a wrong sentence). Compared only with herself.
public enum CoachHistory {
    public static let checkCounts = 3...20
    public static let weeks = 1...ProgramCalendar.weeks
    public static let activeDays = 1...7
    public static let walkNumbers = 2...5

    /// "Last check, you stood up eight times. Let's see today." before the 2-week check, from the second
    /// one; `previousCount` is her last check done the same way.
    public static func checkLine(previousCount: Int) -> String? {
        checkCounts.contains(previousCount) ? "a13.check.n.\(previousCount)" : nil
    }

    /// "Week five of twelve. At your own pace." at the first session of a program week.
    public static func weekLine(week: Int) -> String? {
        weeks.contains(week) ? "a13.week.\(week)" : nil
    }

    /// "That's three active days this week." at the end of a session.
    public static func daysLine(activeDays days: Int) -> String? {
        activeDays.contains(days) ? "a13.days.\(days)" : nil
    }

    /// "Third walk this week. Nice and steady." at the end of a walk (2nd to 5th).
    public static func walkLine(walkNumber: Int) -> String? {
        walkNumbers.contains(walkNumber) ? "a13.walk.\(walkNumber)" : nil
    }

    /// Every line the coach may say from her history (content and release checks).
    public static var allLineIDs: [String] {
        checkCounts.compactMap(checkLine) + weeks.compactMap(weekLine) + activeDays.compactMap(daysLine)
            + walkNumbers.compactMap(walkLine)
    }
}
