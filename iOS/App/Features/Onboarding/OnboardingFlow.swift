import Foundation
import Observation
import SwiftData
import GentleWalkCore

/// Onboarding screens in order: S01, S02, S03, S04, S05a, S05b, S05c, S06, S07, then the paywall S08.
/// Owner 01/10/2026: the three part intros (P1–P3) are gone (a picture and a part name, one more
/// tap each), S04 leads into part 2 itself, and the stairs question went (nothing used the answer).
enum OnboardingStep: Int, CaseIterable, Sendable {
    case welcome, goal, barriers, understanding, name, activity, chair, body, plan, paywall
}

/// S07 "What's a good moment for your daily walk?" with its suggested time.
enum DailyMoment: String, CaseIterable, Identifiable, Sendable {
    case coffee, lunch, tv, custom
    var id: String { rawValue }

    /// Minutes after midnight: 8:30 AM, 1:00 PM, 7:00 PM; "Pick a time" starts at 10:00 AM.
    var suggestedMinutes: Int {
        switch self {
        case .coffee: 8 * 60 + 30
        case .lunch: 13 * 60
        case .tv: 19 * 60
        case .custom: 10 * 60
        }
    }
}

/// Onboarding state (task 5.1): step order, answers, validation hints and saving the profile.
@Observable @MainActor final class OnboardingFlow {
    private(set) var step: OnboardingStep = .welcome
    var answers = OnboardingAnswers(goals: [], barriers: [], name: nil, activity: nil, stairs: nil, chair: nil, limits: []) {
        didSet { hint = nil }
    }
    var nameText = ""
    /// The reminder starts "after my morning coffee"; she picks the moment on S16, where the
    /// reminder is asked for (owner 01/10/2026: Your plan was a screen and a half long).
    let moment: DailyMoment = .coffee
    let reminderMinutes = DailyMoment.coffee.suggestedMinutes
    private(set) var hint: String?
    private(set) var noLimitsChosen = false

    static let maxGoals = 2

    /// "Part 2 of 3 · About you"; nil outside the three parts.
    var progressLabel: String? {
        switch step {
        case .goal, .barriers, .understanding: String(localized: "Part 1 of 3 · Your goal")
        case .name, .activity, .chair: String(localized: "Part 2 of 3 · About you")
        case .body: String(localized: "Part 3 of 3 · Your body")
        case .welcome, .plan, .paywall: nil
        }
    }

    /// The thin bar under the header: never 0 on the first question (goal gradient, review M6,
    /// 02/10/2026), full on the plan.
    var progress: Double {
        min(1, Double(step.rawValue) / Double(OnboardingStep.plan.rawValue))
    }

    var profile: OnboardingProfile {
        var answers = answers
        answers.name = nameText
        return OnboardingProfile.make(answers: answers)
    }

    /// Continue: checks the one required answer on this screen, then moves on.
    func next() {
        if let missing = missingAnswerHint {
            hint = missing
            return
        }
        hint = nil
        movedForward = true
        if let next = OnboardingStep(rawValue: step.rawValue + 1) { step = next }
    }

    func back() {
        hint = nil
        movedForward = false
        if let previous = OnboardingStep(rawValue: step.rawValue - 1) { step = previous }
    }

    /// Which way the last step went: the next screen slides in from the right, Back from the left.
    private(set) var movedForward = true

    /// Screenshots and tests.
    func jump(to step: OnboardingStep) {
        hint = nil
        self.step = step
    }

    /// A third goal was tapped: "You can pick 2. Tap one to change it."
    private(set) var showsGoalLimit = false

    func toggleGoal(_ goal: Goal) {
        showsGoalLimit = false
        if let index = answers.goals.firstIndex(of: goal) {
            answers.goals.remove(at: index)
        } else if goal == .notSure {
            // "Not sure yet" stands alone, like "None of these" on the body screen.
            answers.goals = [.notSure]
        } else if answers.goals.contains(.notSure) {
            answers.goals = [goal]
        } else if answers.goals.count < Self.maxGoals {
            answers.goals.append(goal)
        } else {
            showsGoalLimit = true
        }
    }

    /// Keeps tap order: the first barrier picks the S04 screen.
    func toggleBarrier(_ barrier: Barrier) {
        if let index = answers.barriers.firstIndex(of: barrier) {
            answers.barriers.remove(at: index)
        } else {
            answers.barriers.append(barrier)
        }
    }

    func toggleLimit(_ limit: BodyLimit) {
        noLimitsChosen = false
        if answers.limits.contains(limit) { answers.limits.remove(limit) } else { answers.limits.insert(limit) }
    }

    /// "None of these".
    func chooseNoLimits() {
        answers.limits = []
        noLimitsChosen = true
    }

    /// Saves the answers as the one `UserProfile` (free tier rest days: Saturday and Sunday).
    @discardableResult
    func finish(into context: ModelContext, now: Date = .now) throws -> UserProfile {
        let profile = self.profile
        let existing = try context.fetch(FetchDescriptor<UserProfile>())
        existing.forEach(context.delete)
        let saved = UserProfile(
            name: profile.displayName, goals: answers.goals.map(\.rawValue), barriers: answers.barriers.map(\.rawValue),
            activityLevel: answers.activity?.rawValue ?? "", stairsAnswer: answers.stairs?.rawValue ?? "",
            chairAnswer: answers.chair?.rawValue ?? "",
            bodyLimits: OnboardingCopy.limitOrder.filter(answers.limits.contains).map(\.rawValue),
            startLevel: profile.startLevel.rawValue, reminderMoment: moment.rawValue, reminderMinutes: reminderMinutes,
            restDays: RestDays.freeTier.map(\.rawValue).sorted(by: >), createdAt: now, onboardingCompleted: true)
        context.insert(saved)
        try context.save()
        return saved
    }

    private var missingAnswerHint: String? {
        switch step {
        case .goal where answers.goals.isEmpty: String(localized: "Pick at least one.")
        case .activity where answers.activity == nil,
             .chair where answers.chair == nil: String(localized: "Pick one to continue.")
        default: nil
        }
    }
}

/// Reminder time steps (owner 30/09/2026): typed times keep their minutes, while + and − move to
/// the next :00, :15, :30 or :45, within the day.
enum ReminderTime {
    static let lastMinute = 23 * 60 + 59

    static func step(_ minutes: Int, by direction: Int) -> Int {
        if direction > 0 {
            let next = (minutes / 15 + 1) * 15
            return next > lastMinute ? minutes : next
        }
        let previous = minutes % 15 == 0 ? minutes - 15 : (minutes / 15) * 15
        return max(0, previous)
    }
}
