/// Moments when asking for a rating is fair (task 2.17, App Review 5.6.1: only through
/// `SKStoreReviewController`/`requestReview`, never from a button, never gated on satisfaction).
public enum ReviewMilestone: String, CaseIterable, Codable, Sendable { case finishedNewYork, sevenActiveDays }

public struct ReviewPromptHistory: Equatable, Sendable {
    public var askedMilestones: Set<ReviewMilestone>
    public var completedSessions: Int

    public init(askedMilestones: Set<ReviewMilestone>, completedSessions: Int) {
        self.askedMilestones = askedMilestones; self.completedSessions = completedSessions
    }
}

/// What happened today that makes a prompt unkind.
public struct ReviewPromptDay: Equatable, Sendable {
    public var reportedPain: Bool
    public var saidTooHard: Bool

    public init(reportedPain: Bool, saidTooHard: Bool) {
        self.reportedPain = reportedPain; self.saidTooHard = saidTooHard
    }
}

public enum ReviewPromptPolicy {
    /// No input about whether the user is happy: the policy only looks at milestones and hard days.
    public static func shouldAsk(milestone: ReviewMilestone, history: ReviewPromptHistory, today: ReviewPromptDay) -> Bool {
        !history.askedMilestones.contains(milestone)
            && history.completedSessions > 1
            && !today.reportedPain
            && !today.saidTooHard
    }
}
