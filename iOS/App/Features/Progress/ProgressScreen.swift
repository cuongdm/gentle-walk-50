import Charts
import SwiftUI
import GentleWalkCore

/// S19 Progress: tree level, month calendar (no red days), 2-week self-checks (steady program task
/// 4.10), balance support levels, longest walk, Everyday wins, all-day steps from Apple Health. No
/// weight, no calories, no norms.
struct ProgressScreen: View {
    let snapshot: ProgressSnapshot
    let wins: [EverydayWinItem]
    let steps: StepsSummary?
    let healthConnected: Bool
    let calendar: Calendar
    let now: Date
    var isPro = false
    let onToggleWin: (String) -> Void
    var onSeeAllSessions: () -> Void = {}
    let onConnectHealth: () -> Void
    /// Exercise names for the support levels card.
    var content: ContentBundle? = nil
    var onSeePlans: () -> Void = {}
    /// Her main goal: the results that speak to it come first (P4).
    var goal: Goal? = nil

    @State private var selectedDay: SelectedDay?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScreenHeader(title: "Progress")
                YourResultsCard(summary: snapshot.results, tandem: snapshot.supportLevels["bl.tandem"], isPro: isPro, goal: goal,
                                onSeePlans: onSeePlans)
                TreeCard(level: snapshot.tree, activeDays: snapshot.activeDays, rings: snapshot.rings)
                MonthCalendar(activeDates: snapshot.activeDates, restDays: snapshot.restDays, calendar: calendar, now: now,
                              onSelect: { selectedDay = SelectedDay(date: $0) })
                RecentSessionsCard(sessions: snapshot.sessions, isPro: isPro, onSeeAll: onSeeAllSessions)
                SelfCheckChart(checks: snapshot.selfChecks, delta: snapshot.selfCheckDelta)
                SupportLevelsCard(levels: snapshot.supportLevels, isPro: isPro, content: content, onSeePlans: onSeePlans)
                if let minutes = snapshot.longestWalkMinutes {
                    LongestWalkCard(minutes: minutes)
                }
                let notes = snapshot.weeklyNotes.filter { $0.effort != nil }
                if !notes.isEmpty { WeeklyNotesCard(notes: Array(notes.prefix(4))) }
                EverydayWinsList(wins: wins, checked: snapshot.checkedWins, onToggle: onToggleWin)
                AllDayStepsCard(steps: steps, connected: healthConnected, onConnect: onConnectHealth)
            }
            .padding(Metrics.screenMargin)
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .screenBackground()
        .sheet(item: $selectedDay) { day in
            DaySessionsSheet(day: day.date, sessions: SessionHistoryItem.on(day.date, in: snapshot.sessions, calendar: calendar))
        }
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

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        // At accessibility sizes the tree goes above the text: beside it the line "6 of 14 active days to…"
        // was cut short.
        let layout = typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
                                                  : AnyLayout(HStackLayout(spacing: 16))
        layout {
            ArtImage(name: Art.treeName(level: level), height: 140, fallbackSymbol: level.symbol)
                .frame(width: 120)
            VStack(alignment: .leading, spacing: 6) {
                Text(level.title).typeRole(.cardTitle)
                if rings > 0 {
                    Text("^[\(rings) year ring](inflect: true)").typeRole(.caption).foregroundStyle(Palette.textMuted)
                }
                TreeMilestoneLine(activeDays: activeDays)
                // What an active day is (clarity review D18).
                Text("An active day is any day you finish a session.").typeRole(.caption).foregroundStyle(Palette.textMuted)
            }
            .foregroundStyle(Palette.text)
        }
        .cardStyle()
    }
}

/// This month: active days filled with secondary, planned rest days marked, never a red day. An
/// active day opens its sessions (owner 01/10/2026).
struct MonthCalendar: View {
    let activeDates: Set<Date>
    let restDays: Set<Weekday>
    let calendar: Calendar
    let now: Date
    var onSelect: (Date) -> Void = { _ in }

    var body: some View {
        let days = monthDays
        VStack(alignment: .leading, spacing: 10) {
            Text(verbatim: now.formatted(.dateTime.month(.wide).year()).capitalizedFirstLetter).typeRole(.cardTitle).foregroundStyle(Palette.text)
            // The grid in words, so nobody has to count dots (review M14, 02/10/2026).
            Text(verbatim: Self.summary(activeDates: activeDates, now: now, calendar: calendar))
                .typeRole(.body).foregroundStyle(Palette.text)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                // Grid positions are fixed for the month, so the position is a stable identity
                // (blank lead cells would otherwise share one).
                ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                    if let day {
                        let active = activeDates.contains(calendar.startOfDay(for: day))
                        let rest = restDays.contains(Weekday(of: day, in: calendar))
                        if active {
                            Button { onSelect(day) } label: { dayCell(day, active: true, rest: rest) }
                                .buttonStyle(.plain)
                                .accessibilityHint(Text("Shows the sessions of that day"))
                        } else {
                            dayCell(day, active: false, rest: rest)
                        }
                    } else {
                        Color.clear.frame(minHeight: 44)
                    }
                }
            }
            legend
        }
        .cardStyle()
    }

    /// "3 active days so far this month", or what fills the grid when there are none yet.
    static func summary(activeDates: Set<Date>, now: Date, calendar: Calendar) -> String {
        let count = activeDates.filter { calendar.isDate($0, equalTo: now, toGranularity: .month) }.count
        return count > 0 ? String(localized: "\(Plural.activeDays(count)) so far this month")
            : String(localized: "Your first active day this month will show here.")
    }

    /// Day numbers at body size in 44 pt cells, the rest-day moon 16 pt under the number (plan 08/10/2026
    /// task 1.15: 16 pt numbers, 36 pt cells and an 8 pt moon were too small).
    private func dayCell(_ day: Date, active: Bool, rest: Bool) -> some View {
        VStack(spacing: 0) {
            Text(verbatim: "\(calendar.component(.day, from: day))")
                .typeRole(.body)
                // Seven columns: at the largest sizes the number shrinks a little
                // rather than breaking over two lines (review I12).
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            if rest && !active {
                Image(systemName: "moon.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Palette.textMuted)
                    .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            }
        }
            .foregroundStyle(active ? Palette.onStrongFill : Palette.text)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(active ? Palette.secondary : .clear, in: .circle)
            // The whole cell answers the tap, not just the circle (seven columns leave ~46 pt).
            .contentShape(.rect)
            .accessibilityLabel(Text(verbatim: day.formatted(date: .complete, time: .omitted)))
            .accessibilityValue(active ? Text("Active") : rest ? Text("Rest day") : Text(verbatim: ""))
    }

    /// What the marks mean (clarity review D41).
    private var legend: some View {
        HStack(spacing: 16) {
            Label { Text("Active day") } icon: { Circle().fill(Palette.secondary).frame(width: 12, height: 12) }
            Label { Text("Rest day") } icon: { Image(systemName: "moon.fill").foregroundStyle(Palette.textMuted) }
        }
        .typeRole(.caption).foregroundStyle(Palette.text)
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

/// The 2-week self-checks: one bar per check ("Week 0", "Week 2" …), "+2 since your first check" only
/// against a check done the same way, and the counts read out for VoiceOver (task 4.10).
struct SelfCheckChart: View {
    let checks: [SelfCheckPoint]
    let delta: SelfCheckDelta?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your 2-week checks").typeRole(.cardTitle).foregroundStyle(Palette.text)
            if checks.isEmpty {
                Text("Your first check comes after your first session.").typeRole(.body).foregroundStyle(Palette.textMuted)
            } else {
                if let line = deltaLine {
                    Text(verbatim: line).typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
                }
                Chart(checks) { check in
                    BarMark(x: .value("Check", label(check)), y: .value("Sit-to-stands", check.count))
                        .foregroundStyle(Palette.secondary)
                        .cornerRadius(6)
                        .annotation(position: .top) {
                            Text(verbatim: "\(check.count)").typeRole(.caption).foregroundStyle(Palette.text)
                        }
                }
                .chartYAxis(.hidden)
                .frame(height: 170)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: spoken))
                Text("Sit-to-stands in 30 seconds, counted by you. You compare only with yourself.")
                    .typeRole(.caption).foregroundStyle(Palette.textMuted)
            }
        }
        .cardStyle()
    }

    private var deltaLine: String? {
        guard let sinceFirst = delta?.sinceFirst, sinceFirst > 0 else { return nil }
        return String(localized: "+\(sinceFirst) since your first check")
    }

    /// "Week 2", or "Week 2 · Oct 6" when two checks fell in the same week (bars must not stack).
    private func label(_ check: SelfCheckPoint) -> String {
        let week = String(localized: "Week \(check.week)")
        guard checks.filter({ $0.week == check.week }).count > 1 else { return week }
        return "\(week) · \(check.date.formatted(.dateTime.month(.abbreviated).day()))"
    }

    /// "Week 0: 7. Week 2: 8. Week 4: 9."
    private var spoken: String {
        checks.map { "\(label($0)): \($0.count)" }.joined(separator: ". ")
    }
}

/// How much hand on the chair each balance exercise takes now (Pro support ladder); free shows
/// "Two hands" with one line about Pro (task 4.10).
struct SupportLevelsCard: View {
    let levels: [String: SupportLevel]
    let isPro: Bool
    let content: ContentBundle?
    let onSeePlans: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hands on the chair").typeRole(.cardTitle).foregroundStyle(Palette.text)
            if isPro, !rows.isEmpty {
                ForEach(rows, id: \.id) { row in
                    HStack(alignment: .firstTextBaseline) {
                        Text(verbatim: row.name).typeRole(.body).foregroundStyle(Palette.text)
                        Spacer(minLength: 8)
                        Text(row.level.shortLabel).typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
                            .multilineTextAlignment(.trailing)
                    }
                    .accessibilityElement(children: .combine)
                }
                Text("Less hand on the chair once you've held steady twice in a row.")
                    .typeRole(.caption).foregroundStyle(Palette.textMuted)
            } else {
                Text(SupportLevel.twoHands.label).typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
                HStack {
                    Text("With Pro, less hand on the chair as you get steadier.").typeRole(.caption)
                        .foregroundStyle(Palette.textMuted)
                    Spacer(minLength: 8)
                    Button("See Pro plans", action: onSeePlans).buttonStyle(.smallTextLink)
                }
            }
        }
        .cardStyle()
    }

    private struct Row { let id: String; let name: String; let level: SupportLevel }

    private var rows: [Row] {
        levels.keys.sorted().compactMap { id in
            guard let level = levels[id], let name = content?.exercises.first(where: { $0.id == id })?.name else { return nil }
            return Row(id: id, name: name, level: level)
        }
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
            VStack(alignment: .leading, spacing: 2) {
                Text("Everyday wins").typeRole(.cardTitle).foregroundStyle(Palette.text)
                Text("Tick the ones you can do now.").typeRole(.caption).foregroundStyle(Palette.textMuted)
            }
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
                Text("Connect Apple Health to see your everyday steps. Your journey doesn't need Health: it moves with your minutes here.")
                    .typeRole(.body)
                Button("Connect Apple Health", action: onConnect).buttonStyle(.secondaryAction)
            }
        }
        .foregroundStyle(Palette.text)
        .cardStyle()
    }
}
