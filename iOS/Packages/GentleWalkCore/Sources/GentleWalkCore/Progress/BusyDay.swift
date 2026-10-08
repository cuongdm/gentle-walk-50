import Foundation

/// P11 (plan 4.12): she has already been on her feet a lot today, measured against her own usual (the
/// median of her last four weeks of Apple Health steps). Today then offers a gentle stretch; the plan and
/// the reminder stay as they are. Read only when Health access was already given; nothing is stored.
public enum BusyDay {
    public static let factor = 1.5
    public static let historyDays = 28
    /// Days with steps needed before "usual" means anything.
    public static let minimumDays = 7

    /// Median daily steps over the four weeks before today; days with no steps (phone left at home) do
    /// not count. Nil with fewer than `minimumDays`.
    public static func usualSteps(dailySteps: [Date: Double], now: Date, calendar: Calendar) -> Double? {
        let today = calendar.startOfDay(for: now)
        guard let start = calendar.date(byAdding: .day, value: -historyDays, to: today) else { return nil }
        let days = dailySteps.filter { $0.key >= start && $0.key < today && $0.value > 0 }.map(\.value).sorted()
        guard days.count >= minimumDays else { return nil }
        let middle = days.count / 2
        return days.count.isMultiple(of: 2) ? (days[middle - 1] + days[middle]) / 2 : days[middle]
    }

    /// Before her reminder time, today's steps are over 1.5 × her usual.
    public static func isBusy(stepsToday: Double, dailySteps: [Date: Double], now: Date, reminderMinutes: Int,
                              calendar: Calendar) -> Bool {
        let minutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
        guard minutes < reminderMinutes, let usual = usualSteps(dailySteps: dailySteps, now: now, calendar: calendar),
              usual > 0 else { return false }
        return stepsToday > factor * usual
    }
}
