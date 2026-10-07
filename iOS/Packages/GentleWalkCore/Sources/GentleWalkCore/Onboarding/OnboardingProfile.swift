import Foundation

/// S02 "What would you like to feel?"
/// `notSure` is the way out for someone who just wants to start (review M7, 02/10/2026).
public enum Goal: String, CaseIterable, Codable, Sendable { case lessPain, steadier, loseWeight, moreEnergy, chairs, grandkids, notSure }

/// S03 "What's made it hard before?" — raw values are the D2/D3 keys in docs/scripts/D-min-texts.md.
public enum Barrier: String, CaseIterable, Codable, Sendable {
    case joints, tooFast = "too-fast", busy, bored, charged, notSure = "not-sure"
}

/// S05b "How active are you now?"
public enum ActivityAnswer: String, CaseIterable, Codable, Sendable { case mostlySit, shortWalks, walkMostDays, exerciseRegularly }
/// S05c screen 1: after one flight of stairs.
public enum StairsAnswer: String, CaseIterable, Codable, Sendable { case outOfBreath, littleTired, fine, severalFlights }
/// S05c screen 2: getting up from a chair without hands.
public enum ChairAnswer: String, CaseIterable, Codable, Sendable { case notPossible, hard, easy }

public struct OnboardingAnswers: Equatable, Sendable {
    public var goals: [Goal]
    /// In the order they were tapped: the first one picks the S04 screen.
    public var barriers: [Barrier]
    public var name: String?
    public var activity: ActivityAnswer?
    public var stairs: StairsAnswer?
    public var chair: ChairAnswer?
    public var limits: Set<BodyLimit>

    public init(goals: [Goal], barriers: [Barrier], name: String?, activity: ActivityAnswer?,
                stairs: StairsAnswer?, chair: ChairAnswer?, limits: Set<BodyLimit>) {
        self.goals = goals; self.barriers = barriers; self.name = name; self.activity = activity
        self.stairs = stairs; self.chair = chair; self.limits = limits
    }
}

/// One "Why this will work for you" line on S07: a D3 line per barrier, or the default line.
public enum WhyKey: Equatable, Sendable { case barrier(Barrier), pocket }

/// What onboarding decides (task 2.15).
public struct OnboardingProfile: Equatable, Sendable {
    public var startLevel: WalkLevel
    public var understandingKey: Barrier
    public var whyKeys: [WhyKey]
    /// Trimmed name, or nil: copy never shows an empty name.
    public var displayName: String?

    static let maxWhyLines = 3
    static let minWhyLines = 2

    public static func make(answers: OnboardingAnswers) -> OnboardingProfile {
        let active = answers.activity == .walkMostDays || answers.activity == .exerciseRegularly
        let canStand = answers.limits.isDisjoint(with: [.standingIsHard, .unsteady])
        let startLevel: WalkLevel = active && answers.chair == .easy && canStand ? .inPlace : .seated
        let barriers = answers.barriers.isEmpty ? [Barrier.notSure] : answers.barriers
        var why = barriers.prefix(maxWhyLines).map(WhyKey.barrier)
        if why.count < minWhyLines { why.append(.pocket) }
        let name = answers.name?.trimmingCharacters(in: .whitespacesAndNewlines)
        return OnboardingProfile(startLevel: startLevel, understandingKey: barriers[0], whyKeys: why,
                                 displayName: name?.isEmpty == false ? name : nil)
    }
}
