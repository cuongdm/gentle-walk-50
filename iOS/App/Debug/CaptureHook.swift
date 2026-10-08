#if DEBUG
import Foundation
import SwiftData

/// Screen states reachable with the single capture convention `-ScreenshotMode <state>` (CLAUDE.md).
/// The list mirrors "Trạng thái chụp" in docs/plans/2026-09-29-mvp.md, Localization plan.
enum CaptureState: String, CaseIterable, Sendable {
    case root = "root"
    case tokens = "tokens"
    case onboardingWelcome = "onboarding-welcome"
    case onboardingGoal = "onboarding-goal"
    case onboardingBarriers = "onboarding-barriers"
    case onboardingName = "onboarding-name"
    // New onboarding (plan 08/10/2026 task 2.14): "You're not alone" went (understanding-joints,
    // understanding-charged) and the body step became Sore spots and Anything else (onboarding-body).
    case onboardingActivity = "onboarding-activity"
    case onboardingStrength = "onboarding-strength"
    case onboardingSoreSpots = "onboarding-sore-spots"
    case onboardingAnythingElse = "onboarding-anything-else"
    case onboardingPlan = "onboarding-plan"
    /// Your plan with "Hear your coach" playing (the button reads "Stop").
    case onboardingPlanCoach = "onboarding-plan-coach"
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
    case readyFirstWalk = "ready-first-walk"
    case notSaved = "not-saved"
    case walkPlayer = "walk-player"
    case walkTransition = "walk-transition"
    case walkPaused = "walk-paused"
    case walkEnd = "walk-end"
    case walkHome = "walk-home"
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
    /// The two-minute steady set closing a planned day (06/10/2026).
    case steadySet = "steady-set"
    case previewSteady = "preview-steady"
    /// Balance Strong on walking backwards: a painted still, no clip.
    case balanceBackWalk = "balance-back-walk"
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
    case completeStopped = "complete-stopped"
    case completeXxl = "complete-xxl"
    // One permission per screen (plan 08/10/2026 task 1.6; replaced permissions, permissions-granted).
    case permissionsReminder = "permissions-reminder"
    case permissionsHealth = "permissions-health"
    case permissionsHealthGranted = "permissions-health-granted"
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
    case todayNew = "today-new"
    case todayRest = "today-rest"
    case reminderOffer = "reminder-offer"
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
    case progressFree = "progress-free"
    case progressDay = "progress-day"
    case progressSessions = "progress-sessions"
    case me = "me"
    case meLifetime = "me-lifetime"
    case meLifetimeAndSubscription = "me-lifetime-and-subscription"
    case meNotifications = "me-notifications"
    case meDeleteConfirm = "me-delete-confirm"
    case cancelGuide = "cancel-guide"
    case soundSheet = "sound-sheet"
    case watchOnTV = "watch-on-tv"
    case outdoorPrep = "outdoor-prep"
    /// Measure first, then a one-button prompt (plan 08/10/2026 task 1.17; replaced outdoor-location-ask).
    case outdoorMeasureChoice = "outdoor-measure-choice"
    case outdoorLocationPrompt = "outdoor-location-prompt"
    case outdoorPlayer = "outdoor-player"
    case outdoorPlayerNoGps = "outdoor-player-no-gps"
    case outdoorPlayerFinding = "outdoor-player-finding"
    // Steady program (docs/plans/2026-10-08-steady-program.md, task 4.1).
    case todayProgram = "today-program"
    case todayCheckDue = "today-check-due"
    case program = "program"
    case selfcheckIntro = "selfcheck-intro"
    case selfcheckTimer = "selfcheck-timer"
    case selfcheckCount = "selfcheck-count"
    case progressChecks = "progress-checks"
    case completeCheckInvite = "complete-check-invite"
    /// The rep ladder's "Next time: …" line (the tree's level-up already owns complete-level-up).
    case completeRepsUp = "complete-reps-up"
    case programFinished = "program-finished"
    // UI, onboarding and personalisation (docs/plans/2026-10-08-ui-onboarding-personalization.md).
    /// "You're ready for a little more" after three "Too easy" at Seated (task 0.5).
    case todayMovedUp = "today-moved-up"
    // Personalisation P1–P13 (milestone 4, task 4.16).
    /// "For steadier feet" under today's session (P4).
    case todayGoalLine = "today-goal-line"
    /// "We've set Mini-squat aside for now. Bring it back in Me." (P3).
    case todaySetAside = "today-set-aside"
    /// "Move your reminder to 10:00 AM?" (P10).
    case todayMoveReminder = "today-move-reminder"
    /// Monday: "Last week you said stairs felt a bit better…" (P6).
    case todayLastWeek = "today-last-week"
    /// "This week felt…" (P6).
    case weeklyCheckin = "weekly-checkin"
    /// "Your results" with five weeks of sessions and three checks (P8).
    case progressResults = "progress-results"
    /// Me → "Moves set aside" with "Bring it back" (P3).
    case meSetAside = "me-set-aside"
    // Icons and anti-boredom (milestone 3, task 3.4).
    /// Me → Help → Acknowledgements: the Phosphor icon licence.
    case meAcknowledgements = "me-acknowledgements"
    // Progress lower half (task 3.7), opened further down; and a new user.
    /// The hands ladder with three moves on one hand (Pro).
    case progressLower = "progress-lower"
    /// Free, opened at the bottom: the wins grid with two chosen, steps not connected.
    case progressLowerFree = "progress-lower-free"
    /// No session yet: the empty Recent sessions and 2-week checks cards (opened in the middle).
    case progressEmpty = "progress-empty"
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
        let today = calendar.startOfDay(for: now)
        if let daysAgo = fixture.programStartDaysAgo {
            context.insert(ProgramState(start: try require(calendar.date(byAdding: .day, value: -daysAgo, to: today))))
        }
        for check in fixture.selfChecks ?? [] {
            let day = try require(calendar.date(byAdding: .day, value: -check.daysAgo, to: today))
            let at = try require(calendar.date(byAdding: .minute, value: p.reminderMinutes + 20, to: day))
            context.insert(SelfCheckRecord(date: at, count: check.count, usedHands: check.usedHands, week: check.week))
        }
        try context.save()
    }

    private static func require<T>(_ value: T?) throws -> T {
        guard let value else { throw CocoaError(.coderValueNotFound) }
        return value
    }
}

/// Screenshot persona (App/Debug/Fixtures/en-US.json): Margaret, 58, New York at 1.8 mi, 13 active days,
/// week 3 of the steady program with two self-checks (7, then 8, with her hands).
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

    /// A 2-week self-check, `daysAgo` before the capture day.
    struct SelfCheck: Decodable {
        var daysAgo: Int
        var count: Int
        var usedHands: Bool
        var week: Int
    }

    var profile: Profile
    var journey: JourneyProgress
    var activeDays: Int
    var unlockedStops: [String]
    /// Steady program: week 1 began this many days ago (week 3 on the capture day).
    var programStartDaysAgo: Int?
    var selfChecks: [SelfCheck]?

    static func load(bundle: Bundle, locale: String = "en-US") throws -> CaptureFixture {
        guard let url = bundle.url(forResource: locale, withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try JSONDecoder().decode(CaptureFixture.self, from: Data(contentsOf: url))
    }
}
#endif
