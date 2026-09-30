#if DEBUG
import Foundation
import SwiftData

/// Screen states reachable with the single capture convention `-ScreenshotMode <state>` (CLAUDE.md).
/// The list mirrors "Trạng thái chụp" in docs/plans/2026-09-29-mvp.md, Localization plan.
enum CaptureState: String, CaseIterable, Sendable {
    case root = "root"
    case tokens = "tokens"
    case onboardingWelcome = "onboarding-welcome"
    case onboardingPart2 = "onboarding-part2"
    case onboardingGoal = "onboarding-goal"
    case onboardingBarriers = "onboarding-barriers"
    case onboardingUnderstandingJoints = "onboarding-understanding-joints"
    case onboardingUnderstandingCharged = "onboarding-understanding-charged"
    case onboardingName = "onboarding-name"
    case onboardingStrength = "onboarding-strength"
    case onboardingBody = "onboarding-body"
    case onboardingPlan = "onboarding-plan"
    case onboardingPlanMoment = "onboarding-plan-moment"
    case paywallEligible = "paywall-eligible"
    case paywallMonthly = "paywall-monthly"
    case paywallLifetime = "paywall-lifetime"
    case paywallNotEligible = "paywall-not-eligible"
    case paywallLifetimeWhileSubscribed = "paywall-lifetime-while-subscribed"
    case phonePlacement = "phone-placement"
    case previewIndoor = "preview-indoor"
    case previewOutdoor = "preview-outdoor"
    case previewStretch = "preview-stretch"
    case previewChair = "preview-chair"
    case previewWalkingPad = "preview-walking-pad"
    case countdown = "countdown"
    case walkPlayer = "walk-player"
    case walkTransition = "walk-transition"
    case walkPaused = "walk-paused"
    case walkEnd = "walk-end"
    case walkPlayerDark = "walk-player-dark"
    case walkPlayerIpad = "walk-player-ipad"
    case walkFullscreen = "walk-fullscreen"
    case chairPlayer = "chair-player"
    case chairTimed = "chair-timed"
    case chairStandBehind = "chair-stand-behind"
    case chairRest = "chair-rest"
    case chairPlayerDark = "chair-player-dark"
    case chairFullscreen = "chair-fullscreen"
    case chairPlayerReduceMotion = "chair-player-reduce-motion"
    case chairCounted = "chair-counted"
    case stretchPlayer = "stretch-player"
    case stretchSwitchSide = "stretch-switch-side"
    case stretchCooldown = "stretch-cooldown"
    case thisHurts = "this-hurts"
    case `break` = "break"
    case breakOutdoor = "break-outdoor"
    case complete = "complete"
    case completeFirstWalk = "complete-first-walk"
    case completeLevelUp = "complete-level-up"
    case completeStretch = "complete-stretch"
    case completeOutdoor = "complete-outdoor"
    case completeXxl = "complete-xxl"
    case permissions = "permissions"
    case permissionsGranted = "permissions-granted"
    case today = "today"
    case todayDone = "today-done"
    case todayFree = "today-free"
    case todayTrialEnding = "today-trial-ending"
    case todayTrialEnded = "today-trial-ended"
    case todayWelcomeBack = "today-welcome-back"
    case todayPainCard = "today-pain-card"
    case todayFewerReminders = "today-fewer-reminders"
    case todayDark = "today-dark"
    case todayXxl = "today-xxl"
    case todaySwap = "today-swap"
    case allSessions = "all-sessions"
    case allSessionsFree = "all-sessions-free"
    case journey = "journey"
    case journeys = "journeys"
    case journeysFree = "journeys-free"
    case whereNext = "where-next"
    case postcard = "postcard"
    case lockedStop = "locked-stop"
    case progress = "progress"
    case progressNoHealth = "progress-no-health"
    case me = "me"
    case meLifetime = "me-lifetime"
    case meLifetimeAndSubscription = "me-lifetime-and-subscription"
    case meNotifications = "me-notifications"
    case meDeleteConfirm = "me-delete-confirm"
    case cancelGuide = "cancel-guide"
    case soundSheet = "sound-sheet"
    case watchOnTV = "watch-on-tv"
    case outdoorPrep = "outdoor-prep"
    case outdoorLocationAsk = "outdoor-location-ask"
    case outdoorPlayer = "outdoor-player"
    case outdoorPlayerNoGps = "outdoor-player-no-gps"
}

enum CaptureHook {
    static let argument = "-ScreenshotMode"

    /// `["App", "-ScreenshotMode", "paywall-eligible"]` → `.paywallEligible`; unknown or missing value → nil.
    static func state(from arguments: [String]) -> CaptureState? {
        guard let index = arguments.firstIndex(of: argument), arguments.indices.contains(index + 1) else {
            return nil
        }
        return CaptureState(rawValue: arguments[index + 1])
    }

    /// Fills an (in-memory) store with the screenshot persona. Workouts land on the most recent
    /// non-rest days before `now`, so "today" is always not-yet-walked unless a state says otherwise.
    static func seed(_ fixture: CaptureFixture, into context: ModelContext, now: Date, calendar: Calendar) throws {
        let p = fixture.profile
        context.insert(UserProfile(
            name: p.name, goals: p.goals, barriers: p.barriers, activityLevel: p.activityLevel,
            stairsAnswer: p.stairsAnswer, chairAnswer: p.chairAnswer, bodyLimits: p.bodyLimits,
            startLevel: p.startLevel, reminderMoment: p.reminderMoment, reminderMinutes: p.reminderMinutes,
            restDays: p.restDays, createdAt: now, onboardingCompleted: true
        ))

        var day = calendar.startOfDay(for: now)
        var placed = 0
        while placed < fixture.activeDays {
            day = try require(calendar.date(byAdding: .day, value: -1, to: day))
            guard !p.restDays.contains(calendar.component(.weekday, from: day)) else { continue }
            let at = try require(calendar.date(byAdding: .minute, value: p.reminderMinutes, to: day))
            context.insert(WorkoutRecord(
                date: at, kind: "walk", level: p.startLevel, intensity: "steady", place: "indoors",
                activeSeconds: 8 * 60, journeyMiles: 0.4
            ))
            placed += 1
        }

        let started = try require(calendar.date(byAdding: .day, value: -21, to: calendar.startOfDay(for: now)))
        context.insert(JourneyState(journeyID: fixture.journey.journeyID, miles: fixture.journey.miles,
                                    isCurrent: true, startedAt: started))
        for stop in fixture.unlockedStops {
            context.insert(PostcardUnlock(journeyID: fixture.journey.journeyID, stopID: stop, unlockedAt: started, opened: true))
        }
        try context.save()
    }

    private static func require<T>(_ value: T?) throws -> T {
        guard let value else { throw CocoaError(.coderValueNotFound) }
        return value
    }
}

/// Screenshot persona (App/Debug/Fixtures/en-US.json): Margaret, 58, New York at 1.8 mi, 13 active days.
struct CaptureFixture: Decodable {
    struct Profile: Decodable {
        var name: String
        var goals: [String]
        var barriers: [String]
        var activityLevel: String
        var stairsAnswer: String
        var chairAnswer: String
        var bodyLimits: [String]
        var startLevel: String
        var reminderMoment: String
        var reminderMinutes: Int
        var restDays: [Int]
    }
    struct JourneyProgress: Decodable {
        var journeyID: String
        var miles: Double
    }

    var profile: Profile
    var journey: JourneyProgress
    var activeDays: Int
    var unlockedStops: [String]

    static func load(bundle: Bundle, locale: String = "en-US") throws -> CaptureFixture {
        guard let url = bundle.url(forResource: locale, withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try JSONDecoder().decode(CaptureFixture.self, from: Data(contentsOf: url))
    }
}
#endif
