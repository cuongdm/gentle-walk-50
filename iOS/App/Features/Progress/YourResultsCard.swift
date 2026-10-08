import SwiftUI
import GentleWalkCore

/// What "Your results" shows (P8, plan 4.10; design claude-design/Outcomes.dc.html), worked out once per
/// reload from her own sessions and checks. Compared only with herself: no score, no norm.
struct ResultsSummary: Equatable {
    /// The last four weeks, oldest first, ending with this week.
    var weeks: [WeekPoint]
    /// Median of the four weeks before this one; nil without any.
    var usualMinutes: Int?
    var longestWalk: Int?
    var firstWeekLongestWalk: Int?
    /// Latest and first 2-week check done the same way as the latest.
    var latestCheck: Int?
    var firstCheck: Int?
    /// Weeks in a row with 3+ active days.
    var steadyWeeks: Int

    static let empty = ResultsSummary(weeks: [], usualMinutes: nil, longestWalk: nil, firstWeekLongestWalk: nil,
                                      latestCheck: nil, firstCheck: nil, steadyWeeks: 0)

    init(weeks: [WeekPoint], usualMinutes: Int?, longestWalk: Int?, firstWeekLongestWalk: Int?, latestCheck: Int?,
         firstCheck: Int?, steadyWeeks: Int) {
        self.weeks = weeks; self.usualMinutes = usualMinutes; self.longestWalk = longestWalk
        self.firstWeekLongestWalk = firstWeekLongestWalk; self.latestCheck = latestCheck; self.firstCheck = firstCheck
        self.steadyWeeks = steadyWeeks
    }

    init(sessions: [MovedSession], checks: [SelfCheckPoint], longestWalk: Int?, now: Date, calendar: Calendar) {
        weeks = YourResults.weeklyMinutes(sessions, now: now, calendar: calendar)
        usualMinutes = YourResults.usualMinutes(sessions, now: now, calendar: calendar)
        self.longestWalk = longestWalk
        firstWeekLongestWalk = YourResults.firstWeekLongestWalk(sessions)
        latestCheck = checks.last?.count
        firstCheck = checks.last.flatMap { latest in checks.first { $0.usedHands == latest.usedHands && $0.id != latest.id }?.count }
        steadyWeeks = YourResults.steadyWeeksInARow(sessions, now: now, calendar: calendar)
    }

    var hasMinutes: Bool { weeks.contains { $0.minutes > 0 } }

    /// "From 38 to 55 minutes a week, at your own pace." when this week is above the first one shown;
    /// otherwise her usual week.
    var trendLine: String? {
        guard let first = weeks.first?.minutes, let last = weeks.last?.minutes else { return nil }
        if first > 0, last > first { return String(localized: "From \(first) to \(last) minutes a week, at your own pace.") }
        return usualMinutes.map { String(localized: "About \($0) minutes in a usual week.") }
    }
}

/// The tiles under the chart; the ones for her goal come first (P4).
enum ResultTile: Hashable { case longestWalk, sitToStands, hands, steadyWeeks

    static func order(for goal: Goal?) -> [ResultTile] {
        switch goal {
        case .chairs?: [.sitToStands, .hands, .longestWalk, .steadyWeeks]
        case .steadier?: [.hands, .sitToStands, .longestWalk, .steadyWeeks]
        case .lessPain?: [.longestWalk, .steadyWeeks, .sitToStands, .hands]
        case .moreEnergy?, .grandkids?, .loseWeight?: [.steadyWeeks, .longestWalk, .sitToStands, .hands]
        case .notSure?, nil: [.longestWalk, .sitToStands, .hands, .steadyWeeks]
        }
    }
}

/// "Your results" at the top of Progress: minutes each week for four weeks, then up to four tiles.
struct YourResultsCard: View {
    let summary: ResultsSummary
    /// Pro: her hands level in tandem stance; free shows two hands and a line about Pro.
    let tandem: SupportLevel?
    let isPro: Bool
    var goal: Goal?
    var onSeePlans: () -> Void = {}

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your results").typeRole(.cardTitle).foregroundStyle(Palette.text).accessibilityAddTraits(.isHeader)
                Text("The last 4 weeks, compared only with you.").typeRole(.caption).foregroundStyle(Palette.textMuted)
            }
            if summary.hasMinutes { minutesChart }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10, alignment: .top),
                                     count: typeSize.isAccessibilitySize ? 1 : 2), spacing: 10) {
                ForEach(tiles, id: \.self) { tile($0) }
            }
            Text("Counted on this phone from your own sessions and checks. \(AppBrand.name) is for general fitness, not medical advice.")
                .typeRole(.caption).foregroundStyle(Palette.textMuted)
        }
        .cardStyle()
    }

    private var tiles: [ResultTile] {
        ResultTile.order(for: goal).filter { tile in
            switch tile {
            case .longestWalk: summary.longestWalk != nil
            case .sitToStands: summary.latestCheck != nil
            case .hands: true
            case .steadyWeeks: summary.steadyWeeks > 0
            }
        }
    }

    // MARK: Chart

    private var minutesChart: some View {
        let top = max(1, summary.weeks.map(\.minutes).max() ?? 1)
        return VStack(alignment: .leading, spacing: 10) {
            Text("Minutes moving each week").typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(Array(summary.weeks.enumerated()), id: \.element.weekStart) { index, week in
                    let isThisWeek = index == summary.weeks.count - 1
                    VStack(spacing: 4) {
                        Text(verbatim: "\(week.minutes)").font(.system(.callout, design: .rounded).weight(.bold))
                            .foregroundStyle(Palette.text)
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Palette.secondary.opacity(isThisWeek ? 1 : 0.45 + 0.15 * Double(index)))
                            .frame(height: max(6, 92 * Double(week.minutes) / Double(top)))
                        Text(label(index)).typeRole(.caption).fontWeight(isThisWeek ? .semibold : .regular)
                            .foregroundStyle(isThisWeek ? Palette.text : Palette.textMuted)
                            .lineLimit(1).minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 150, alignment: .bottom)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: spokenWeeks))
            if let line = summary.trendLine {
                Text(verbatim: line).typeRole(.body).italic().foregroundStyle(Palette.text)
            }
        }
    }

    private func label(_ index: Int) -> LocalizedStringResource {
        index == summary.weeks.count - 1 ? "This wk" : "Wk \(index + 1)"
    }

    private var spokenWeeks: String {
        summary.weeks.enumerated().map { index, week in
            "\(String(localized: label(index))): \(String(localized: "\(week.minutes) min"))"
        }.joined(separator: ". ")
    }

    // MARK: Tiles

    @ViewBuilder private func tile(_ tile: ResultTile) -> some View {
        switch tile {
        case .longestWalk:
            ResultTileView(icon: .longWalk, value: String(localized: "\(summary.longestWalk ?? 0) min"),
                           label: "Longest walk without a break",
                           detail: summary.firstWeekLongestWalk.map { String(localized: "First week: \($0) min") })
        case .sitToStands:
            ResultTileView(icon: .chair, value: "\(summary.latestCheck ?? 0)", label: "Sit-to-stands in 30 seconds",
                           detail: summary.firstCheck.map { String(localized: "First check: \($0)") })
        case .hands:
            if isPro, let tandem {
                ResultTileView(icon: .balance, value: String(localized: tandem.shortLabel), label: "On the chair in tandem stance",
                               detail: tandem == .twoHands ? nil : String(localized: "Started with two"))
            } else {
                ResultTileView(icon: .balance, value: String(localized: SupportLevel.twoHands.shortLabel),
                               label: "On the chair in tandem stance",
                               detail: String(localized: "With Pro, less hand on the chair as you get steadier."))
            }
        case .steadyWeeks:
            ResultTileView(icon: .activeDay, value: Plural.weeks(summary.steadyWeeks),
                           label: "In a row with 3+ active days", detail: String(localized: "Rest days never break it"))
        }
    }
}

/// One result: an icon on a wash, the number, what it is, and where she started.
struct ResultTileView: View {
    let icon: AppIcon
    let value: String
    let label: LocalizedStringResource
    let detail: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            icon.image.resizable().scaledToFit().frame(width: 20, height: 20)
                .foregroundStyle(Palette.primary)
                .frame(width: 36, height: 36)
                .background(Palette.secondary.opacity(0.18), in: WashShape(variant: WashShape.variant(for: icon.rawValue)))
                .accessibilityHidden(true)
            Text(verbatim: value).font(.system(.title, design: .rounded).weight(.bold))
                .foregroundStyle(Palette.text).lineLimit(1).minimumScaleFactor(0.6)
            Text(label).typeRole(.body).foregroundStyle(Palette.text)
            if let detail { Text(verbatim: detail).typeRole(.caption).foregroundStyle(Palette.textMuted) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Palette.bg.opacity(0.6), in: .rect(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

/// "Your weekly notes" (P6): her answers in her own words, newest first.
struct WeeklyNotesCard: View {
    let notes: [WeeklyNote]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your weekly notes").typeRole(.cardTitle).foregroundStyle(Palette.text)
            ForEach(notes, id: \.weekStart) { note in
                VStack(alignment: .leading, spacing: 2) {
                    Text("Week of \(note.weekStart.formatted(.dateTime.month(.abbreviated).day()))")
                        .typeRole(.caption).foregroundStyle(Palette.textMuted)
                    Text(verbatim: line(note)).typeRole(.body).foregroundStyle(Palette.text)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .cardStyle()
    }

    private func line(_ note: WeeklyNote) -> String {
        var parts: [String] = []
        if let effort = note.effort { parts.append(String(localized: effort.title)) }
        if let better = note.better, better != .nothingYet { parts.append(String(localized: better.localizedTitle)) }
        return parts.joined(separator: " · ")
    }
}
