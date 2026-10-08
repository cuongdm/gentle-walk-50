import Foundation
import SwiftData

/// Version 2 of the on-device store (steady program, plan docs/plans/2026-10-08-steady-program.md task 3.1):
/// every model of SchemaV1 unchanged, plus the 12-week program and the 2-week self-checks. Added before
/// the first release so no real store has to change; V1 stays for the migration plan. Never delete a
/// version once the app ships.
enum SchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [UserProfile.self, WorkoutRecord.self, PainReport.self, JourneyState.self,
         PostcardUnlock.self, EverydayWin.self, NotificationHistory.self, ProgramState.self, SelfCheckRecord.self]
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

    /// The current round of the 12-week program (`ProgramRound` in GentleWalkCore). One row; a new round
    /// replaces its values.
    @Model final class ProgramState {
        @Attribute(.unique) var id: UUID
        var start: Date
        var round: Int
        /// Days she was away and chose to pick up where she stopped.
        var pausedDays: Int
        var finishedAt: Date?

        init(id: UUID = UUID(), start: Date, round: Int = 1, pausedDays: Int = 0, finishedAt: Date? = nil) {
            self.id = id; self.start = start; self.round = round; self.pausedDays = pausedDays; self.finishedAt = finishedAt
        }
    }

    /// One 2-week self-check: 30 seconds of sit-to-stands, counted by her. Stays on the device.
    @Model final class SelfCheckRecord {
        @Attribute(.unique) var id: UUID
        var date: Date
        var count: Int
        /// Pushed up from the chair with her hands; only checks done the same way are compared.
        var usedHands: Bool
        /// Program week when it was done (0 = the first check, after the first session).
        var week: Int

        init(id: UUID = UUID(), date: Date, count: Int, usedHands: Bool, week: Int) {
            self.id = id; self.date = date; self.count = count; self.usedHands = usedHands; self.week = week
        }
    }
}

typealias UserProfile = SchemaV2.UserProfile
typealias WorkoutRecord = SchemaV2.WorkoutRecord
typealias PainReport = SchemaV2.PainReport
typealias JourneyState = SchemaV2.JourneyState
typealias PostcardUnlock = SchemaV2.PostcardUnlock
typealias EverydayWin = SchemaV2.EverydayWin
typealias NotificationHistory = SchemaV2.NotificationHistory
typealias ProgramState = SchemaV2.ProgramState
typealias SelfCheckRecord = SchemaV2.SelfCheckRecord
