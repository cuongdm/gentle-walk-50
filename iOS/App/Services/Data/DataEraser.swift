import Foundation
import SwiftData
import UserNotifications

/// Clears the app's scheduled notifications.
@MainActor protocol PendingNotificationClearing: AnyObject {
    func removeAllPending()
}

@MainActor final class SystemPendingNotifications: PendingNotificationClearing {
    func removeAllPending() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}

/// Every UserDefaults key the app writes. Add new keys here so "Delete all my data" removes them.
@MainActor enum AppDefaultsKeys {
    static let all: [String] = [
        PhonePlacement.defaultsKey, PhonePlacement.seenKey, WorkoutPreviewModel.placeKey, TextSizeOverride.defaultsKey,
        HealthService.askedKey, "paywallDismissedAt", "restTodayDate", "permissionsShownAt", "reminderOfferShown", UnitPreferences.distanceKey, UnitPreferences.weightKey,
        UnitPreferences.heightKey, "notificationSettings", OutdoorLocationChoice.defaultsKey,
        "outdoorPrepSeen", "healthCardDismissed", "musicOff", "voiceLouder", "captionsOn", "reviewPromptMilestones", "lastSchedule",
        FavouriteSessions.defaultsKey, SupportLadderStore.defaultsKey, RepLadderStore.defaultsKey, WalkLevelStore.defaultsKey, AppModel.selfCheckDismissedKey,
        "permissionsShown", "fewerRemindersAnswered", "lastTrialEnds",
        AudioLevels.voiceKey, AudioLevels.musicKey, AudioLevels.introsKey,
        // Personalisation (plan 08/10/2026 milestone 4).
        ExerciseMemoryStore.defaultsKey, WeeklyNoteStore.defaultsKey, SessionHabitStore.defaultsKey,
        SessionHabitStore.reminderAnsweredKey,
        // Complete cheers (plan 08/10/2026 task 3.6).
        CheerMemoryStore.defaultsKey,
    ]
}

/// "Delete all my data" (task 6.10): every SwiftData record, app settings and pending
/// notifications. Workouts already saved in Apple Health stay there (the confirmation says so).
@MainActor struct DataEraser {
    let context: ModelContext
    let defaults: UserDefaults
    let notifications: PendingNotificationClearing

    func eraseAll() throws {
        try context.delete(model: UserProfile.self)
        try context.delete(model: WorkoutRecord.self)
        try context.delete(model: PainReport.self)
        try context.delete(model: JourneyState.self)
        try context.delete(model: PostcardUnlock.self)
        try context.delete(model: EverydayWin.self)
        try context.delete(model: NotificationHistory.self)
        try context.delete(model: ProgramState.self)
        try context.delete(model: SelfCheckRecord.self)
        try context.save()
        AppDefaultsKeys.all.forEach(defaults.removeObject(forKey:))
        notifications.removeAllPending()
    }
}
