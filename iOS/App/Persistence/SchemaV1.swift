import Foundation
import SwiftData

/// Version 1 of the on-device store. Health-related data lives only here, never in iCloud (5.1.3).
/// Never delete this version once the app ships; add SchemaV2 + a migration stage instead.
enum SchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [UserProfile.self, WorkoutRecord.self, PainReport.self, JourneyState.self,
         PostcardUnlock.self, EverydayWin.self, NotificationHistory.self]
    }

    /// Answers from onboarding (S02–S07) and settings chosen later (S20).
    @Model final class UserProfile {
        @Attribute(.unique) var id: UUID
        var name: String?
        var goals: [String]
        var barriers: [String]
        var activityLevel: String
        var stairsAnswer: String
        var chairAnswer: String
        /// `BodyLimit` raw values from S06.
        var bodyLimits: [String]
        var startLevel: String
        /// Daily moment for the reminder (S07): coffee, lunch, tv or custom.
        var reminderMoment: String
        /// Minutes after midnight in the user's time zone.
        var reminderMinutes: Int
        /// `Calendar` weekday numbers (1 = Sunday … 7 = Saturday). Free tier: always [7, 1].
        var restDays: [Int]
        /// "daily" or "quietDays" (S20 How often).
        var reminderFrequency: String
        var createdAt: Date
        var onboardingCompleted: Bool

        init(
            id: UUID = UUID(), name: String? = nil, goals: [String] = [], barriers: [String] = [],
            activityLevel: String = "", stairsAnswer: String = "", chairAnswer: String = "",
            bodyLimits: [String] = [], startLevel: String = "seated", reminderMoment: String = "coffee",
            reminderMinutes: Int = 8 * 60 + 30, restDays: [Int] = [7, 1], reminderFrequency: String = "daily",
            createdAt: Date = .now, onboardingCompleted: Bool = false
        ) {
            self.id = id; self.name = name; self.goals = goals; self.barriers = barriers
            self.activityLevel = activityLevel; self.stairsAnswer = stairsAnswer; self.chairAnswer = chairAnswer
            self.bodyLimits = bodyLimits; self.startLevel = startLevel; self.reminderMoment = reminderMoment
            self.reminderMinutes = reminderMinutes; self.restDays = restDays; self.reminderFrequency = reminderFrequency
            self.createdAt = createdAt; self.onboardingCompleted = onboardingCompleted
        }
    }

    /// One finished (or stopped) session. A session stopped after 3 minutes still counts (S14).
    @Model final class WorkoutRecord {
        @Attribute(.unique) var id: UUID
        var date: Date
        /// `SessionTemplate.Kind` raw value: firstWalk, walk, chair, stretch, cooldown.
        var kind: String
        var level: String
        var intensity: String
        /// indoors, outdoors or pad.
        var place: String
        var activeSeconds: Int
        var journeyMiles: Double
        var outdoorMiles: Double?
        var breakCount: Int
        /// tooEasy, justRight or tooHard (S15).
        var feeling: String?
        var sitToStandCount: Int?

        init(
            id: UUID = UUID(), date: Date, kind: String, level: String, intensity: String, place: String,
            activeSeconds: Int, journeyMiles: Double, outdoorMiles: Double? = nil, breakCount: Int = 0,
            feeling: String? = nil, sitToStandCount: Int? = nil
        ) {
            self.id = id; self.date = date; self.kind = kind; self.level = level; self.intensity = intensity
            self.place = place; self.activeSeconds = activeSeconds; self.journeyMiles = journeyMiles
            self.outdoorMiles = outdoorMiles; self.breakCount = breakCount; self.feeling = feeling
            self.sitToStandCount = sitToStandCount
        }
    }

    /// "This hurts" taps (S13), used by the pain rules (task 2.10).
    @Model final class PainReport {
        @Attribute(.unique) var id: UUID
        var date: Date
        /// knee, hip, back, shoulder or other.
        var area: String
        var exerciseID: String?

        init(id: UUID = UUID(), date: Date, area: String, exerciseID: String? = nil) {
            self.id = id; self.date = date; self.area = area; self.exerciseID = exerciseID
        }
    }

    /// Progress on one journey; exactly one is current.
    @Model final class JourneyState {
        @Attribute(.unique) var id: UUID
        var journeyID: String
        var miles: Double
        var isCurrent: Bool
        var startedAt: Date
        var completedAt: Date?

        init(id: UUID = UUID(), journeyID: String, miles: Double = 0, isCurrent: Bool, startedAt: Date, completedAt: Date? = nil) {
            self.id = id; self.journeyID = journeyID; self.miles = miles; self.isCurrent = isCurrent
            self.startedAt = startedAt; self.completedAt = completedAt
        }
    }

    @Model final class PostcardUnlock {
        @Attribute(.unique) var id: UUID
        var journeyID: String
        var stopID: String
        var unlockedAt: Date
        var opened: Bool

        init(id: UUID = UUID(), journeyID: String, stopID: String, unlockedAt: Date, opened: Bool = false) {
            self.id = id; self.journeyID = journeyID; self.stopID = stopID; self.unlockedAt = unlockedAt; self.opened = opened
        }
    }

    /// Ticked "Everyday wins" on Progress (S19).
    @Model final class EverydayWin {
        @Attribute(.unique) var id: UUID
        var key: String
        var checkedAt: Date

        init(id: UUID = UUID(), key: String, checkedAt: Date) {
            self.id = id; self.key = key; self.checkedAt = checkedAt
        }
    }

    /// Notifications already scheduled or delivered, for the 14-day no-repeat rule (task 7.4).
    @Model final class NotificationHistory {
        @Attribute(.unique) var id: UUID
        var kind: String
        var phraseID: String
        var date: Date

        init(id: UUID = UUID(), kind: String, phraseID: String, date: Date) {
            self.id = id; self.kind = kind; self.phraseID = phraseID; self.date = date
        }
    }
}

typealias UserProfile = SchemaV1.UserProfile
typealias WorkoutRecord = SchemaV1.WorkoutRecord
typealias PainReport = SchemaV1.PainReport
typealias JourneyState = SchemaV1.JourneyState
typealias PostcardUnlock = SchemaV1.PostcardUnlock
typealias EverydayWin = SchemaV1.EverydayWin
typealias NotificationHistory = SchemaV1.NotificationHistory
