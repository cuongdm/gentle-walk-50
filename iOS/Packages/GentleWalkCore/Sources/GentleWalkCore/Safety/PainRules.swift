import Foundation

/// Where it hurts (This hurts sheet, S13).
public enum BodyArea: String, CaseIterable, Codable, Sendable { case knees, hips, lowerBack, shoulders, neck, ankles, other }

/// A pain report as the rules see it; the app maps its SwiftData `PainReport` to this.
public struct PainReportSnapshot: Equatable, Sendable {
    public var date: Date
    public var area: BodyArea
    public var exerciseID: String?

    public init(date: Date, area: BodyArea, exerciseID: String?) {
        self.date = date; self.area = area; self.exerciseID = exerciseID
    }
}

/// Today card: "You've mentioned knee pain 3 times this week. We've switched you to seated moves.
/// Consider checking with your doctor."
public struct PainAlert: Equatable, Sendable {
    public var area: BodyArea
    public var count: Int
    public var switchToSeated: Bool

    public init(area: BodyArea, count: Int, switchToSeated: Bool) {
        self.area = area; self.count = count; self.switchToSeated = switchToSeated
    }
}

/// What her pain reports change in the moves (P3, plan 4.5): moves that start with the easier version,
/// and moves set aside until a date. Easier and This hurts stay free; "Bring it back" in Me ends it.
public struct ExerciseRules: Equatable, Sendable {
    public var easier: Set<String>
    /// Move id → the day it comes back.
    public var setAside: [String: Date]

    public init(easier: Set<String> = [], setAside: [String: Date] = [:]) {
        self.easier = easier; self.setAside = setAside
    }

    public var setAsideIDs: Set<String> { Set(setAside.keys) }

    /// Both together (pain rules and remembered Easier taps, P5): set aside wins over easier.
    public func merging(_ other: ExerciseRules) -> ExerciseRules {
        let aside = setAside.merging(other.setAside) { max($0, $1) }
        return ExerciseRules(easier: easier.union(other.easier).subtracting(aside.keys), setAside: aside)
    }
}

/// The choices on the This hurts sheet.
public enum PainChoice: Sendable { case showEasier, skip }
public enum PainResponse: Equatable, Sendable { case easierVersion(String), skipExercise }

/// Pain rules (task 2.10). No diagnosis: the app only adapts and suggests a doctor.
public enum PainRules {
    public static let repeatCount = 3
    public static let windowDays = 7.0

    /// An alert when one area was reported `repeatCount` times in the last seven days.
    public static func evaluate(reports: [PainReportSnapshot], now: Date) -> PainAlert? {
        let start = now.addingTimeInterval(-windowDays * 86_400)
        let recent = reports.filter { $0.date > start && $0.date <= now }
        let counts = Dictionary(grouping: recent, by: \.area).mapValues(\.count)
        guard let (area, count) = counts.filter({ $0.value >= repeatCount })
            .max(by: { ($0.value, $1.key.rawValue) < ($1.value, $0.key.rawValue) }) else { return nil }
        return PainAlert(area: area, count: count, switchToSeated: true)
    }

    // MARK: Per move (P3, D9: one report in 14 days → easier; two in 28 days → set aside 4 weeks)

    public static let easierWindowDays = 14
    public static let setAsideReports = 2
    public static let setAsideWindowDays = 28
    public static let setAsideDays = 28

    /// - Parameter restored: "Bring it back" in Me, move id → when: reports until then no longer count.
    public static func exerciseRules(reports: [PainReportSnapshot], now: Date,
                                     restored: [String: Date] = [:]) -> ExerciseRules {
        let byMove = Dictionary(grouping: reports.filter { $0.exerciseID != nil && $0.date <= now }) { $0.exerciseID! }
        var rules = ExerciseRules()
        for (id, all) in byMove {
            let counted = all.filter { report in restored[id].map { report.date > $0 } ?? true }.map(\.date)
            let recent = counted.filter { now.timeIntervalSince($0) < Double(setAsideWindowDays) * 86_400 }
            if recent.count >= setAsideReports, let latest = recent.max() {
                let back = latest.addingTimeInterval(Double(setAsideDays) * 86_400)
                if back > now { rules.setAside[id] = back; continue }
            }
            if counted.contains(where: { now.timeIntervalSince($0) < Double(easierWindowDays) * 86_400 }) {
                rules.easier.insert(id)
            }
        }
        return rules
    }

    /// The body limit that matches the area she named, to offer "Add 'Easy on knees' to your plan?".
    public static func suggestedLimit(for area: BodyArea) -> BodyLimit? {
        switch area {
        case .knees: .knees
        case .hips: .hips
        case .lowerBack: .lowerBack
        case .shoulders: .shoulders
        case .neck, .ankles, .other: nil
        }
    }

    public static func response(for choice: PainChoice, exercise: Exercise) -> PainResponse {
        switch choice {
        case .showEasier:
            exercise.easier.isEmpty ? .skipExercise : .easierVersion(exercise.easier)
        case .skip:
            .skipExercise
        }
    }
}
