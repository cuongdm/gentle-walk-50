import Foundation

/// One finished session as the habit signals see it (the app maps `WorkoutRecord`: start = date −
/// active seconds; planned seconds from the request; `extraAfter`: an extra started within 30 minutes).
public struct SessionTiming: Equatable, Sendable {
    public var start: Date
    public var plannedSeconds: Int
    public var activeSeconds: Int
    public var stoppedForPain: Bool
    public var extraAfter: Bool

    public init(start: Date, plannedSeconds: Int, activeSeconds: Int, stoppedForPain: Bool, extraAfter: Bool) {
        self.start = start; self.plannedSeconds = plannedSeconds; self.activeSeconds = activeSeconds
        self.stoppedForPain = stoppedForPain; self.extraAfter = extraAfter
    }
}

public enum LengthSignal: Equatable, Sendable { case shorter, longer }

/// P10 (plan 4.11): the reminder and the session length follow what she actually does. Only offers:
/// Today asks "Move your reminder to 9:15?"; a shorter start uses the existing "shorter" card.
public enum HabitSignals {
    public static let sessionsForTime = 5
    /// Started this far from the reminder, most times: her time is not the reminder's.
    public static let driftMinutes = 45
    public static let roundingMinutes = 15
    public static let earlyRange = 0.60...0.85

    /// Her usual start, rounded to 15 minutes, when the latest five sessions began (at least four of them)
    /// more than 45 minutes on the same side of the reminder; nil otherwise.
    public static func suggestedReminderMinutes(starts: [Date], reminderMinutes: Int, calendar: Calendar) -> Int? {
        let recent = starts.sorted().suffix(sessionsForTime)
        guard recent.count == sessionsForTime else { return nil }
        let minutes = recent.map { calendar.component(.hour, from: $0) * 60 + calendar.component(.minute, from: $0) }
        let later = minutes.filter { $0 - reminderMinutes > driftMinutes }.count
        let earlier = minutes.filter { reminderMinutes - $0 > driftMinutes }.count
        guard max(later, earlier) >= sessionsForTime - 1 else { return nil }
        let median = minutes.sorted()[minutes.count / 2]
        let rounded = Int((Double(median) / Double(roundingMinutes)).rounded()) * roundingMinutes
        return rounded == reminderMinutes ? nil : rounded
    }

    /// From the last three sessions: two ended at 60–85 % of the plan (not for pain) → shorter; else two
    /// were followed by an extra → longer; else nil.
    public static func lengthSignal(_ sessions: [SessionTiming]) -> LengthSignal? {
        let recent = sessions.sorted { $0.start < $1.start }.suffix(3)
        guard recent.count == 3 else { return nil }
        let early = recent.filter { session in
            guard session.plannedSeconds > 0, !session.stoppedForPain else { return false }
            return earlyRange.contains(Double(session.activeSeconds) / Double(session.plannedSeconds))
        }
        if early.count >= 2 { return .shorter }
        if recent.filter(\.extraAfter).count >= 2 { return .longer }
        return nil
    }
}
