import Foundation
import GentleWalkCore

/// One finished session as Progress lists it (owner 01/10/2026: the records were kept but no screen
/// showed them). Four things per session: when, what, how long, how it felt; outdoor walks add the
/// distance. No calories, no heart rate, no comparison with anyone.
struct SessionHistoryItem: Equatable, Identifiable {
    var id: UUID
    var date: Date
    var kind: SessionTemplate.Kind
    var isOutdoors: Bool
    var minutes: Int
    var feeling: Feeling?
    var outdoorMiles: Double?

    init(id: UUID, date: Date, kind: SessionTemplate.Kind, isOutdoors: Bool, minutes: Int, feeling: Feeling?,
         outdoorMiles: Double?) {
        self.id = id; self.date = date; self.kind = kind; self.isOutdoors = isOutdoors; self.minutes = minutes
        self.feeling = feeling; self.outdoorMiles = outdoorMiles
    }

    init(record: WorkoutRecord) {
        id = record.id
        date = record.date
        kind = SessionTemplate.Kind(rawValue: record.kind) ?? .walk
        isOutdoors = record.place == "outdoors"
        minutes = max(1, Int((Double(record.activeSeconds) / 60).rounded()))
        feeling = record.feeling.flatMap(Feeling.init(rawValue:))
        outdoorMiles = record.outdoorMiles
    }

    /// Newest first.
    static func list(_ records: [WorkoutRecord]) -> [SessionHistoryItem] {
        records.map(SessionHistoryItem.init(record:)).sorted { $0.date > $1.date }
    }

    /// The sessions of one day, earliest first (a day reads in order).
    static func on(_ day: Date, in items: [SessionHistoryItem], calendar: Calendar) -> [SessionHistoryItem] {
        items.filter { calendar.isDate($0.date, inSameDayAs: day) }.sorted { $0.date < $1.date }
    }

    /// Months, newest first, each with its sessions newest first.
    static func byMonth(_ items: [SessionHistoryItem], calendar: Calendar) -> [(month: Date, items: [SessionHistoryItem])] {
        let groups = Dictionary(grouping: items) { calendar.dateInterval(of: .month, for: $0.date)?.start ?? $0.date }
        return groups.keys.sorted(by: >).map { month in
            (month, groups[month, default: []].sorted { $0.date > $1.date })
        }
    }

    /// The fixed session words of the app (app-context vocabulary).
    var title: String {
        switch kind {
        case .firstWalk: String(localized: "First walk")
        case .walk: isOutdoors ? String(localized: "Outdoor walk") : String(localized: "Walk")
        case .chair: String(localized: "Chair moves")
        case .stretch: String(localized: "Stretch")
        case .cooldown: String(localized: "Cool-down")
        case .balance: String(localized: "Balance")
        }
    }

    var symbol: String {
        switch kind {
        case .chair: "chair.fill"
        case .stretch, .cooldown: "figure.flexibility"
        case .balance: "figure.stand"
        case .firstWalk, .walk: "figure.walk"
        }
    }

    /// "Wed, Oct 1 · 9 min · Just right" in the list; "8:42 AM · 9 min · Just right" inside one day.
    func detail(showsDate: Bool) -> String {
        var parts = [showsDate ? date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
                               : date.formatted(date: .omitted, time: .shortened),
                     String(localized: "\(minutes) min")]
        if let outdoorMiles, outdoorMiles > 0 {
            parts.append(String(localized: "\(CompleteContent.miles(outdoorMiles)) walked"))
        }
        if let feeling { parts.append(String(localized: feeling.title)) }
        return parts.joined(separator: " · ")
    }
}

extension Feeling {
    /// The answer as she gave it on Complete.
    var title: LocalizedStringResource {
        switch self {
        case .tooEasy: "Too easy"
        case .justRight: "Just right"
        case .tooHard: "Too hard"
        }
    }
}
