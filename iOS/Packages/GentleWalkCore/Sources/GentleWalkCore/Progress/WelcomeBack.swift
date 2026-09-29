import Foundation

/// Today after a gap (spec: "Welcome back, Margaret. Your journey is right where you left it."
/// with "Gentle restart · 5 min"). Progress is never reset.
public enum WelcomeBackState: Equatable, Sendable { case gentleRestart(minutes: Int) }

public enum WelcomeBack {
    /// Missed plan days (not counting planned rest days) that trigger the gentle restart.
    public static let missedDays = 2
    public static let restartMinutes = 5

    public static func state(lastWorkout: Date?, restDays: Set<Weekday>, now: Date, calendar: Calendar) -> WelcomeBackState? {
        guard let lastWorkout else { return nil }
        let today = calendar.startOfDay(for: now)
        guard var day = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: lastWorkout)) else { return nil }
        var missed = 0
        while day < today {
            if !restDays.contains(Weekday(of: day, in: calendar)) { missed += 1 }
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return missed >= missedDays ? .gentleRestart(minutes: restartMinutes) : nil
    }
}
