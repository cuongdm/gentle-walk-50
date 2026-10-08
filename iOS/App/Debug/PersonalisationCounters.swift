#if DEBUG
import SwiftUI
import SwiftData
import GentleWalkCore

/// DEBUG only (plan 08/10/2026 decision D15: no analytics, no backend): how the personalisation is
/// behaving on this device, for testing by hand in Me.
struct PersonalisationCounters: Equatable {
    /// Sessions answered "How did that feel?" out of all sessions.
    var answered: Int
    var sessions: Int
    var levelChanges: Int
    /// Body areas reported sore more than once in the last 14 days.
    var repeatedPainAreas: Int
}

extension AppModel {
    func personalisationCounters() -> PersonalisationCounters {
        let records = (try? container.mainContext.fetch(FetchDescriptor<WorkoutRecord>())) ?? []
        let pains = painRecorder.snapshots(since: now().addingTimeInterval(-14 * 86_400))
        let repeated = Dictionary(grouping: pains, by: \.area).values.filter { $0.count > 1 }.count
        return PersonalisationCounters(answered: records.filter { $0.feeling != nil }.count, sessions: records.count,
                                       levelChanges: walkLevels.changeCount, repeatedPainAreas: repeated)
    }
}

struct PersonalisationCountersCard: View {
    let counters: PersonalisationCounters

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: "Debug · personalisation").typeRole(.cardTitle)
            Text(verbatim: "Feeling answered: \(counters.answered) of \(counters.sessions)").typeRole(.body)
            Text(verbatim: "Level changes: \(counters.levelChanges)").typeRole(.body)
            Text(verbatim: "Repeated pain areas (14 days): \(counters.repeatedPainAreas)").typeRole(.body)
        }
        .foregroundStyle(Palette.text)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}
#endif
