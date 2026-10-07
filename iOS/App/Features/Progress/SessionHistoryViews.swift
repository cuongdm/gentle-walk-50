import SwiftUI
import GentleWalkCore

/// "Recent sessions": the last three under the calendar. "See all" opens the full list with Gentle
/// Walk Pro (app-context: detailed history is Pro); on the free plan it carries the Pro badge and
/// opens the plans, like any locked content (owner 01/10/2026).
struct RecentSessionsCard: View {
    let sessions: [SessionHistoryItem]
    let isPro: Bool
    let onSeeAll: () -> Void

    static let shown = 3

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text("Recent sessions").typeRole(.cardTitle).foregroundStyle(Palette.text)
                Spacer(minLength: 8)
                if sessions.count > Self.shown {
                    // Not the link style: it would underline the Pro badge too.
                    Button(action: onSeeAll) {
                        HStack(spacing: 6) {
                            Text("See all").typeRole(.caption).fontWeight(.semibold).underline()
                                .foregroundStyle(Palette.text)
                            if !isPro { ProBadge() }
                        }
                        .fixedSize()
                        .frame(minHeight: Metrics.minTouchTarget)
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isPro ? Text("See all sessions") : Text("See all sessions, with \(AppBrand.name) Pro"))
                }
            }
            if sessions.isEmpty {
                Text("Finish a session to see it here.").typeRole(.body).foregroundStyle(Palette.textMuted)
            } else {
                ForEach(sessions.prefix(Self.shown)) { item in
                    SessionHistoryRow(item: item, showsDate: true)
                    if item.id != sessions.prefix(Self.shown).last?.id { Divider() }
                }
            }
        }
        .cardStyle()
    }
}

/// One session: its icon, the session word, then date (or time), minutes, distance and feeling.
struct SessionHistoryRow: View {
    let item: SessionHistoryItem
    let showsDate: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.symbol)
                .font(.title3)
                .foregroundStyle(Palette.secondary)
                .frame(width: 32)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: item.title).typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
                Text(verbatim: item.detail(showsDate: showsDate)).typeRole(.caption).foregroundStyle(Palette.textMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

/// A tapped day on the calendar: its sessions, in a half-height sheet.
struct DaySessionsSheet: View {
    let day: Date
    let sessions: [SessionHistoryItem]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ClosableHeader(title: day.formatted(.dateTime.weekday(.wide).month(.wide).day()).capitalizedFirstLetter,
                               onClose: { dismiss() })
                ForEach(sessions) { item in
                    SessionHistoryRow(item: item, showsDate: false)
                }
            }
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        .screenBackground()
        .presentationDetents([.medium, .large])
    }
}

/// All sessions, by month (Pro).
struct SessionHistoryScreen: View {
    let sessions: [SessionHistoryItem]
    let calendar: Calendar

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScreenHeader(title: "Your sessions")
                ForEach(SessionHistoryItem.byMonth(sessions, calendar: calendar), id: \.month) { group in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(verbatim: group.month.formatted(.dateTime.month(.wide).year()).capitalizedFirstLetter)
                            .typeRole(.cardTitle).foregroundStyle(Palette.text)
                            .accessibilityAddTraits(.isHeader)
                        Text(verbatim: Plural.sessions(group.items.count))
                            .typeRole(.caption).foregroundStyle(Palette.textMuted)
                        ForEach(group.items) { item in
                            SessionHistoryRow(item: item, showsDate: true)
                            if item.id != group.items.last?.id { Divider() }
                        }
                    }
                    .cardStyle()
                }
            }
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        .screenBackground()
    }
}

/// A day on the calendar that was tapped.
struct SelectedDay: Identifiable, Equatable {
    var date: Date
    var id: Date { date }
}
