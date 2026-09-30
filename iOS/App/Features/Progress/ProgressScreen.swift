import Charts
import SwiftUI
import GentleWalkCore

/// S19 Progress: tree level, month calendar (no red days), sit-to-stands by week, longest walk,
/// Everyday wins, all-day steps from Apple Health, Fitness Check teaser. No weight, no calories.
struct ProgressScreen: View {
    let snapshot: ProgressSnapshot
    let wins: [EverydayWinItem]
    let steps: StepsSummary?
    let healthConnected: Bool
    let calendar: Calendar
    let now: Date
    let onToggleWin: (String) -> Void
    let onConnectHealth: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScreenHeader(title: "Progress")
                TreeCard(level: snapshot.tree, activeDays: snapshot.activeDays, rings: snapshot.rings)
                MonthCalendar(activeDates: snapshot.activeDates, restDays: snapshot.restDays, calendar: calendar, now: now)
                SitToStandChart(bars: snapshot.sitToStand)
                if let minutes = snapshot.longestWalkMinutes {
                    LongestWalkCard(minutes: minutes)
                }
                EverydayWinsList(wins: wins, checked: snapshot.checkedWins, onToggle: onToggleWin)
                AllDayStepsCard(steps: steps, connected: healthConnected, onConnect: onConnectHealth)
                FitnessCheckTeaser()
            }
            .padding(Metrics.screenMargin)
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .screenBackground()
    }
}

struct EverydayWinItem: Identifiable, Equatable, Decodable {
    var id: String
    var text: String
    var hiddenFor: [BodyLimit]
}

struct StepsSummary: Equatable {
    var thisWeek: Double
    var lastWeek: Double
}

/// The tree and "6 of 14 active days to Sapling"; after Tree, the rings and the next one.
struct TreeCard: View {
    let level: TreeLevel
    let activeDays: Int
    let rings: Int

    var body: some View {
        HStack(spacing: 16) {
            ArtImage(name: Art.treeName(level: level), height: 140, fallbackSymbol: level.symbol)
                .frame(width: 120)
            VStack(alignment: .leading, spacing: 6) {
                Text(level.title).typeRole(.cardTitle)
                if rings > 0 {
                    Text("^[\(rings) year ring](inflect: true)").typeRole(.caption).foregroundStyle(Palette.textMuted)
                }
                TreeMilestoneLine(activeDays: activeDays)
            }
            .foregroundStyle(Palette.text)
        }
        .cardStyle()
    }
}

/// This month: active days filled with secondary, planned rest days marked, never a red day.
struct MonthCalendar: View {
    let activeDates: Set<Date>
    let restDays: Set<Weekday>
    let calendar: Calendar
    let now: Date

    var body: some View {
        let days = monthDays
        VStack(alignment: .leading, spacing: 10) {
            Text(verbatim: now.formatted(.dateTime.month(.wide).year())).typeRole(.cardTitle).foregroundStyle(Palette.text)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                // Grid positions are fixed for the month, so the position is a stable identity
                // (blank lead cells would otherwise share one).
                ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                    if let day {
                        let active = activeDates.contains(calendar.startOfDay(for: day))
                        let rest = restDays.contains(Weekday(of: day, in: calendar))
                        Text(verbatim: "\(calendar.component(.day, from: day))")
                            .typeRole(.caption)
                            // Seven columns: at the largest sizes the number shrinks a little
                            // rather than breaking over two lines (review I12).
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .foregroundStyle(active ? Palette.onStrongFill : Palette.text)
                            .frame(maxWidth: .infinity, minHeight: 36)
                            .background(active ? Palette.secondary : .clear, in: .circle)
                            .overlay(alignment: .bottom) {
                                if rest && !active { Image(systemName: "moon.fill").font(.system(size: 8)).foregroundStyle(Palette.textMuted) }
                            }
                            .accessibilityLabel(Text(verbatim: day.formatted(date: .complete, time: .omitted)))
                            .accessibilityValue(active ? Text("Active") : rest ? Text("Rest day") : Text(verbatim: ""))
                    } else {
                        Color.clear.frame(minHeight: 36)
                    }
                }
            }
        }
        .cardStyle()
    }

    /// Leading blanks for the first weekday, then each day of the month.
    private var monthDays: [Date?] {
        guard let month = calendar.dateInterval(of: .month, for: now),
              let count = calendar.range(of: .day, in: .month, for: now)?.count else { return [] }
        let lead = (calendar.component(.weekday, from: month.start) - calendar.firstWeekday + 7) % 7
        let days = (0..<count).compactMap { calendar.date(byAdding: .day, value: $0, to: month.start) }
        return Array(repeating: nil, count: lead) + days.map { Optional($0) }
    }
}

/// Best sit-to-stands in a session, by week.
struct SitToStandChart: View {
    let bars: [ProgressSnapshot.WeekBar]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sit-to-stands in a session").typeRole(.cardTitle).foregroundStyle(Palette.text)
            Chart(bars) { bar in
                BarMark(x: .value("Week", bar.weekStart, unit: .weekOfYear), y: .value("Sit-to-stands", bar.best))
                    .foregroundStyle(Palette.secondary)
                    .cornerRadius(6)
            }
            .frame(height: 160)
            .chartXAxis { AxisMarks(values: .stride(by: .weekOfYear)) { _ in AxisValueLabel(format: .dateTime.month(.abbreviated).day()) } }
        }
        .cardStyle()
    }
}

struct LongestWalkCard: View {
    let minutes: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Longest walk without a break").typeRole(.cardTitle)
            Text("\(minutes) min").typeRole(.stat)
        }
        .foregroundStyle(Palette.text)
        .cardStyle()
    }
}

/// Everyday wins, ticked by the user.
struct EverydayWinsList: View {
    let wins: [EverydayWinItem]
    let checked: Set<String>
    let onToggle: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Everyday wins").typeRole(.cardTitle).foregroundStyle(Palette.text)
            ForEach(wins) { win in
                Button { onToggle(win.id) } label: {
                    HStack(spacing: 12) {
                        Image(systemName: checked.contains(win.id) ? "checkmark.square.fill" : "square")
                            .typeRole(.cardTitle).foregroundStyle(Palette.secondary)
                        Text(verbatim: win.text).typeRole(.body).foregroundStyle(Palette.text).multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                    }
                    .frame(minHeight: Metrics.minTouchTarget)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(checked.contains(win.id) ? .isSelected : [])
            }
        }
        .cardStyle()
    }
}

/// Average daily steps this week vs last week, from Apple Health.
struct AllDayStepsCard: View {
    let steps: StepsSummary?
    let connected: Bool
    let onConnect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("All-day steps").typeRole(.cardTitle)
            if let steps, connected {
                Text("\(Int(steps.thisWeek).formatted()) a day this week").typeRole(.body).fontWeight(.semibold)
                Text("Last week: \(Int(steps.lastWeek).formatted()) a day").typeRole(.body)
            } else {
                Text("Connect Apple Health to see your everyday steps. Your journey moves with the minutes you spend here.")
                    .typeRole(.body)
                Button("Connect Apple Health", action: onConnect).buttonStyle(.secondaryAction)
            }
        }
        .foregroundStyle(Palette.text)
        .cardStyle()
    }
}

struct FitnessCheckTeaser: View {
    var body: some View {
        HStack {
            Text("Fitness Check").typeRole(.cardTitle)
            Spacer()
            Text("Coming soon").typeRole(.caption)
        }
        .foregroundStyle(Palette.text)
        .cardStyle()
        .opacity(0.7)
    }
}
