import Foundation
import SwiftData
import Testing
@testable import GentleWalk

@MainActor final class FakePendingNotifications: PendingNotificationClearing {
    private(set) var cleared = 0
    func removeAllPending() { cleared += 1 }
}

@MainActor @Suite(.serialized) struct DataEraserTests {
    let container = try! ModelContainerFactory.make(inMemory: true)
    let defaults = UserDefaults(suiteName: "eraser-tests")!

    @Test func deletesEveryRecordAppSettingAndPendingNotification() throws {
        let context = container.mainContext
        let now = Date()
        context.insert(UserProfile(name: "Margaret", onboardingCompleted: true))
        context.insert(WorkoutRecord(date: now, kind: "walk", level: "seated", intensity: "steady", place: "indoors",
                                     activeSeconds: 300, journeyMiles: 0.25))
        context.insert(PainReport(date: now, area: "knees"))
        context.insert(JourneyState(journeyID: "jr.ny", miles: 1, isCurrent: true, startedAt: now))
        context.insert(PostcardUnlock(journeyID: "jr.ny", stopID: "pc.ny.zoo", unlockedAt: now))
        context.insert(EverydayWin(key: "sofa", checkedAt: now))
        context.insert(NotificationHistory(kind: "reminder", phraseID: "n1", date: now))
        context.insert(ProgramState(start: now))
        context.insert(SelfCheckRecord(date: now, count: 8, usedHands: true, week: 0))
        try context.save()
        defaults.set("pocket", forKey: PhonePlacement.defaultsKey)
        defaults.set(2, forKey: TextSizeOverride.defaultsKey)
        let notifications = FakePendingNotifications()

        try DataEraser(context: context, defaults: defaults, notifications: notifications).eraseAll()

        #expect(try context.fetchCount(FetchDescriptor<UserProfile>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<WorkoutRecord>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<PainReport>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<JourneyState>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<PostcardUnlock>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<EverydayWin>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<NotificationHistory>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<ProgramState>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<SelfCheckRecord>()) == 0)
        #expect(defaults.string(forKey: PhonePlacement.defaultsKey) == nil)
        #expect(defaults.object(forKey: TextSizeOverride.defaultsKey) == nil)
        #expect(notifications.cleared == 1)
    }

    @Test func textSizeStepsWithinRange() {
        var size = TextSizeOverride(step: 0)
        #expect(size.dynamicTypeSize == nil)
        size.increase()
        size.increase()
        #expect(size.dynamicTypeSize == .xxLarge)
        for _ in 0..<10 { size.increase() }
        #expect(size.step == TextSizeOverride.maxStep)
        for _ in 0..<20 { size.decrease() }
        #expect(size.step == TextSizeOverride.minStep)
        #expect(size.dynamicTypeSize == .medium)
    }
}
