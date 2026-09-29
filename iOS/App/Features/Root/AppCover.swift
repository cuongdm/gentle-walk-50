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
    case permissions
    case cancelGuide(afterLifetime: Bool)

    var id: String {
        switch self {
        case .paywall(let trigger): "paywall-\(trigger.rawValue)"
        case .phonePlacement(let request): "placement-\(request.id)"
        case .preview: "preview"
        case .outdoorPrep(let request): "outdoor-\(request.id)"
        case .preparing(let request): "preparing-\(request.id)"
        case .workout(let session): "workout-\(session.request.id)"
        case .permissions: "permissions"
        case .cancelGuide: "cancel"
        }
    }
}

enum AppTab: Hashable { case today, journey, progress, me }

/// Navigation routes inside the tabs (one `navigationDestination(for:)` per type).
enum TodayRoute: Hashable {
    case allSessions
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
    }
}
