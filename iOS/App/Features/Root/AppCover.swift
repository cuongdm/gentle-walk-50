import Foundation
import GentleWalkCore

/// Full-screen flows over the tabs (plan "Điều hướng": onboarding, players and paywall use
/// `fullScreenCover(item:)`).
enum AppCover: Identifiable {
    case paywall(PaywallTrigger)
    case phonePlacement(WorkoutRequest)
    case preview(WorkoutPreviewModel)
    case outdoorPrep(WorkoutRequest)
    case preparing(WorkoutRequest)
    case workout(WorkoutSessionModel)
    /// After the first session: reminders, then Apple Health, one per screen (plan 08/10/2026 task 1.6).
    case permissions(PermissionAsk)
    /// "Not yet" on the First Walk: offer a daily reminder.
    case reminderOffer
    case cancelGuide(afterLifetime: Bool)
    /// The 2-week self-check: safety, 30 seconds, her count (steady program task 4.6).
    case selfCheck(SelfCheckFlowModel)
    /// The 12 weeks are done: compare with week 0, start again or keep the routine (task 4.14).
    case programFinished

    var id: String {
        switch self {
        case .paywall(let trigger): "paywall-\(trigger.rawValue)"
        case .phonePlacement(let request): "placement-\(request.id)"
        case .preview: "preview"
        case .outdoorPrep(let request): "outdoor-\(request.id)"
        case .preparing(let request): "preparing-\(request.id)"
        case .workout(let session): "workout-\(session.request.id)"
        // One id for both steps: the second replaces the first in place, not as a new cover.
        case .permissions: "permissions"
        case .reminderOffer: "reminder-offer"
        case .cancelGuide: "cancel"
        case .selfCheck(let model): "selfcheck-\(model.id)"
        case .programFinished: "program-finished"
        }
    }
}

enum AppTab: Hashable { case today, journey, progress, me }

/// Navigation routes inside the tabs (one `navigationDestination(for:)` per type).
enum TodayRoute: Hashable {
    case allSessions
    /// "Your 12-week plan", from the program strip (option A: pushed from Today, tabs unchanged).
    case program
}

enum ProgressRoute: Hashable {
    case sessions
}

enum JourneyRoute: Hashable {
    case allJourneys
    case postcard(journeyID: String, stopID: String)
}

/// Profile values the screens need, read once from `UserProfile`.
struct ProfileSnapshot: Equatable {
    var name: String?
    var limits: Set<BodyLimit>
    var level: WalkLevel
    var restDays: Set<Weekday>
    var reminderMoment: DailyMoment
    var reminderMinutes: Int
    var frequency: ReminderFrequency
    /// Her one main goal (plan 08/10/2026 task 2.12: the paywall, Your plan and Me echo it).
    var goal: Goal = .notSure
    /// What got in the way before, in the order she picked them.
    var barriers: [Barrier] = []

    static let empty = ProfileSnapshot(name: nil, limits: [], level: .seated, restDays: RestDays.freeTier,
                                       reminderMoment: .coffee, reminderMinutes: 510, frequency: .daily)

    init(name: String?, limits: Set<BodyLimit>, level: WalkLevel, restDays: Set<Weekday>, reminderMoment: DailyMoment,
         reminderMinutes: Int, frequency: ReminderFrequency) {
        self.name = name; self.limits = limits; self.level = level; self.restDays = restDays
        self.reminderMoment = reminderMoment; self.reminderMinutes = reminderMinutes; self.frequency = frequency
    }

    init(_ profile: UserProfile) {
        name = profile.name
        limits = Set(profile.bodyLimits.compactMap(BodyLimit.init))
        level = WalkLevel(rawValue: profile.startLevel) ?? .seated
        restDays = Set(profile.restDays.compactMap(Weekday.init))
        reminderMoment = DailyMoment(rawValue: profile.reminderMoment) ?? .coffee
        reminderMinutes = profile.reminderMinutes
        frequency = ReminderFrequency(rawValue: profile.reminderFrequency) ?? .daily
        // Profiles saved before 08/10/2026 may hold two goals: the first picked is the main one.
        goal = profile.goals.lazy.compactMap(Goal.init).first ?? .notSure
        barriers = profile.barriers.compactMap(Barrier.init)
    }
}
