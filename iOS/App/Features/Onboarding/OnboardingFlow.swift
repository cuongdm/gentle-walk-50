import Foundation
import Observation
import SwiftData
import GentleWalkCore

/// Onboarding screens in order (plan 08/10/2026 task 2.2): Welcome, seven questions, Your plan, then the
/// paywall. "You're not alone" went (its line is now the coach's reply on the barriers step) and the
/// body question became two screens: sore spots, then everything else.
enum OnboardingStep: Int, CaseIterable, Sendable {
    case welcome, goal, barriers, name, activity, chair, soreSpots, anythingElse, plan, paywall

    /// The seven questions, in order.
    static let questions: [OnboardingStep] = [.goal, .barriers, .name, .activity, .chair, .soreSpots, .anythingElse]

    /// 1...7 for the questions ("Step 3 of 7"), nil for Welcome, the plan and the paywall.
    var questionNumber: Int? { Self.questions.firstIndex(of: self).map { $0 + 1 } }
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

/// Onboarding state (task 5.1; plan 08/10/2026 tasks 2.1–2.2): step order, answers, the coach's hint and
/// reply on each step, and saving the profile.
@Observable @MainActor final class OnboardingFlow {
    private(set) var step: OnboardingStep = .welcome
    var answers = OnboardingAnswers(goals: [], barriers: [], name: nil, activity: nil, stairs: nil, chair: nil, limits: [])
    var nameText = ""
    /// The reminder starts "after my morning coffee"; she picks the moment on S16, where the
    /// reminder is asked for (owner 01/10/2026: Your plan was a screen and a half long).
    let moment: DailyMoment = .coffee
    let reminderMinutes = DailyMoment.coffee.suggestedMinutes
    /// "None of these" on Sore spots and on Anything else, each on its own screen.
    private(set) var noSoreSpots = false
    private(set) var noOtherLimits = false
    /// The last body limit tapped on: the coach answers that one.
    private(set) var lastLimit: BodyLimit?

    /// One main goal (owner 08/10/2026).
    static let maxGoals = 1

    /// "Step 3 of 7" on the questions; nil on Welcome and Your plan.
    var stepLabel: String? {
        step.questionNumber.map { String(localized: "Step \($0) of \(OnboardingStep.questions.count)") }
    }

    /// Plants grown in the header's garden: the question number, all seven on Your plan.
    var gardenStep: Int {
        step.questionNumber ?? (step.rawValue >= OnboardingStep.plan.rawValue ? OnboardingStep.questions.count : 0)
    }

    /// The garden as a share: never 0 on the first question (goal gradient, review M6, 02/10/2026),
    /// full on the plan.
    var progress: Double { Double(gardenStep) / Double(OnboardingStep.questions.count) }

    var profile: OnboardingProfile {
        var answers = answers
        answers.name = nameText
        return OnboardingProfile.make(answers: answers)
    }

    /// Why Continue can't go on yet ("Pick one to continue"): the button says it instead of fading
    /// (control states, owner 08/10/2026). Nil when Continue works.
    var continueBlockedReason: String? {
        switch step {
        case .goal where answers.goals.isEmpty,
             .activity where answers.activity == nil,
             .chair where answers.chair == nil: String(localized: "Pick one to continue")
        default: nil
        }
    }

    /// Continue: moves on once this screen has the answer it needs.
    func next() {
        guard continueBlockedReason == nil else { return }
        movedForward = true
        if let next = OnboardingStep(rawValue: step.rawValue + 1) { step = next }
    }

    func back() {
        movedForward = false
        if let previous = OnboardingStep(rawValue: step.rawValue - 1) { step = previous }
    }

    /// Which way the last step went: the next screen slides in from the right, Back from the left.
    private(set) var movedForward = true

    /// Screenshots and tests.
    func jump(to step: OnboardingStep) {
        self.step = step
    }

    /// One goal: the new pick replaces the old one; tapping the chosen goal keeps it.
    func chooseGoal(_ goal: Goal) {
        answers.goals = [goal]
    }

    /// Keeps tap order: the first barrier picks the coach's reply and the "why" lines.
    func toggleBarrier(_ barrier: Barrier) {
        if let index = answers.barriers.firstIndex(of: barrier) {
            answers.barriers.remove(at: index)
        } else {
            answers.barriers.append(barrier)
        }
    }

    func toggleLimit(_ limit: BodyLimit) {
        if BodyLimitChips.soreSpots.contains(limit) { noSoreSpots = false } else { noOtherLimits = false }
        if answers.limits.contains(limit) {
            answers.limits.remove(limit)
            if lastLimit == limit { lastLimit = nil }
        } else {
            answers.limits.insert(limit)
            lastLimit = limit
        }
    }

    /// "None of these" on Sore spots: clears the sore spots only.
    func chooseNoSoreSpots() {
        answers.limits.subtract(BodyLimitChips.soreSpots)
        noSoreSpots = true
        if let last = lastLimit, BodyLimitChips.soreSpots.contains(last) { lastLimit = nil }
    }

    /// "None of these" on Anything else: clears the everyday limits only.
    func chooseNoOtherLimits() {
        answers.limits.subtract(BodyLimitChips.everyday)
        noOtherLimits = true
        if let last = lastLimit, BodyLimitChips.everyday.contains(last) { lastLimit = nil }
    }

    /// What the coach says in the fixed slot on this step: a hint before she answers, then a short
    /// reply to her answer (the old "You're not alone" screen became the barriers reply).
    var coachLine: CoachLine? {
        switch step {
        case .goal:
            answers.goals.first.map { .reply(OnboardingCopy.reply($0)) } ?? .hint(OnboardingCopy.hint(.goal))
        case .barriers:
            answers.barriers.first.map { .reply(OnboardingCopy.reply($0)) } ?? .hint(OnboardingCopy.hint(.barriers))
        case .name:
            trimmedName.map { .reply("Nice to meet you, \($0).") } ?? .hint(OnboardingCopy.hint(.name))
        case .activity:
            answers.activity.map { .reply(OnboardingCopy.reply($0)) } ?? .hint(OnboardingCopy.hint(.activity))
        case .chair:
            answers.chair == nil ? .hint(OnboardingCopy.hint(.chair)) : .reply(OnboardingCopy.chairReply)
        case .soreSpots:
            if let last = lastLimit, BodyLimitChips.soreSpots.contains(last) { .reply(OnboardingCopy.reply(last)) }
            else if noSoreSpots { .reply(OnboardingCopy.noSoreSpotsReply) }
            else { .hint(OnboardingCopy.hint(.soreSpots)) }
        case .anythingElse:
            if let last = lastLimit, BodyLimitChips.everyday.contains(last) { .reply(OnboardingCopy.reply(last)) }
            else if noOtherLimits { .reply(OnboardingCopy.noOtherLimitsReply) }
            else { .hint(OnboardingCopy.hint(.anythingElse)) }
        case .welcome, .plan, .paywall: nil
        }
    }

    private var trimmedName: String? {
        let name = nameText.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? nil : name
    }

    /// Saves the answers as the one `UserProfile` (free tier rest days: Saturday and Sunday).
    @discardableResult
    func finish(into context: ModelContext, now: Date = .now) throws -> UserProfile {
        let profile = self.profile
        let existing = try context.fetch(FetchDescriptor<UserProfile>())
        existing.forEach(context.delete)
        let saved = UserProfile(
            name: profile.displayName, goals: answers.goals.prefix(Self.maxGoals).map(\.rawValue),
            barriers: answers.barriers.map(\.rawValue),
            activityLevel: answers.activity?.rawValue ?? "", stairsAnswer: answers.stairs?.rawValue ?? "",
            chairAnswer: answers.chair?.rawValue ?? "",
            bodyLimits: OnboardingCopy.limitOrder.filter(answers.limits.contains).map(\.rawValue),
            startLevel: profile.startLevel.rawValue, reminderMoment: moment.rawValue, reminderMinutes: reminderMinutes,
            restDays: RestDays.freeTier.map(\.rawValue).sorted(by: >), createdAt: now, onboardingCompleted: true)
        context.insert(saved)
        try context.save()
        return saved
    }
}

/// The coach's slot on a question: a quiet hint before she answers, her face and a reply after.
enum CoachLine: Equatable {
    case hint(LocalizedStringResource)
    case reply(LocalizedStringResource)

    var text: LocalizedStringResource {
        switch self {
        case .hint(let text), .reply(let text): text
        }
    }

    var isReply: Bool { if case .reply = self { true } else { false } }

    static func == (lhs: CoachLine, rhs: CoachLine) -> Bool {
        lhs.isReply == rhs.isReply && String(localized: lhs.text) == String(localized: rhs.text)
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
