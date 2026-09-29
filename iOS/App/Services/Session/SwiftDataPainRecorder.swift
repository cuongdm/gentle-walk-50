import Foundation
import SwiftData
import GentleWalkCore

/// Stores "This hurts" taps as `PainReport`s on this phone (read by `PainRules`).
@MainActor final class SwiftDataPainRecorder: PainReportRecording {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func record(_ report: PainReportSnapshot) {
        context.insert(PainReport(date: report.date, area: report.area.rawValue, exerciseID: report.exerciseID))
        try? context.save()
    }

    /// Recent reports for the pain rules.
    func snapshots(since date: Date) -> [PainReportSnapshot] {
        let descriptor = FetchDescriptor<PainReport>(predicate: #Predicate { $0.date >= date })
        return ((try? context.fetch(descriptor)) ?? []).compactMap { report in
            BodyArea(rawValue: report.area).map { PainReportSnapshot(date: report.date, area: $0, exerciseID: report.exerciseID) }
        }
    }
}
