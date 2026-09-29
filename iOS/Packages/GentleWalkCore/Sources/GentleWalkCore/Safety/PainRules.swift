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

    public static func response(for choice: PainChoice, exercise: Exercise) -> PainResponse {
        switch choice {
        case .showEasier:
            exercise.easier.isEmpty ? .skipExercise : .easierVersion(exercise.easier)
        case .skip:
            .skipExercise
        }
    }
}
