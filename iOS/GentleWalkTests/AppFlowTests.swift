import Foundation
import SwiftData
import Testing
import GentleWalkCore
@testable import GentleWalk

/// App-level flows (review 29/09/2026): an AppModel on the Margaret fixture with fake services.
@MainActor @Suite(.serialized) struct AppFlowTests {
    struct RestoreFailed: Error {}

    func makeApp(entitlement: Entitlement, sync: @escaping () async throws -> Void = {}) -> AppModel {
        let container = try! ModelContainerFactory.make(inMemory: true)
        let defaults = UserDefaults(suiteName: "app-flow-tests")!
        defaults.removePersistentDomain(forName: "app-flow-tests")
        if let fixture = try? CaptureFixture.load(bundle: .main) {
            try? CaptureHook.seed(fixture, into: container.mainContext, now: .now, calendar: .current)
        }
        try? container.mainContext.save()
        let app = AppModel(container: container, content: TestFixtures.content, store: StoreService(sync: sync),
                           health: HealthService(store: CaptureHealthStore(connected: true), defaults: defaults),
                           notificationCenter: CaptureNotificationCenter(),
                           location: LocationService(manager: CaptureLocationManager(), background: CaptureBackgroundActivity()),
                           pedometer: PedometerService(pedometer: CapturePedometer()), motion: MotionService(), defaults: defaults)
        app.entitlementOverride = entitlement
        app.reload()
        return app
    }

    func isPaywall(_ cover: AppCover?) -> Bool {
        if case .paywall? = cover { return true } else { return false }
    }

    // I2
    @Test func onboardingSkipsThePaywallForSomeoneAlreadyPro() {
        let pro = makeApp(entitlement: .subscribed)
        pro.finishOnboarding()
        #expect(!isPaywall(pro.cover))
        let free = makeApp(entitlement: .free)
        free.finishOnboarding()
        #expect(isPaywall(free.cover))
    }

    /// Me → Your goal (plan 08/10/2026 task 2.13): one goal saved, the snapshot (paywall, plan) follows.
    @Test func changingTheGoalUpdatesTheSnapshot() {
        let app = makeApp(entitlement: .free)
        #expect(app.profile?.goal == .steadier)
        #expect(app.profile?.barriers == [.joints, .charged])
        app.updateProfile { $0.goals = [Goal.chairs.rawValue] }
        #expect(app.profile?.goal == .chairs)
        let stored = try? app.container.mainContext.fetch(FetchDescriptor<UserProfile>()).first
        #expect(stored?.goals == ["chairs"])
    }

    // I10
    @Test func restoreSaysWhatHappened() async {
        let failing = makeApp(entitlement: .free, sync: { throw RestoreFailed() })
        await failing.restorePurchases()
        #expect(failing.storeNotice == .failed)

        let nothing = makeApp(entitlement: .free)
        await nothing.restorePurchases()
        #expect(nothing.storeNotice == .nothingToRestore)

        let restored = makeApp(entitlement: .subscribed)
        restored.cover = .paywall(.lockedContent)
        await restored.restorePurchases(from: .lockedContent)
        #expect(restored.storeNotice == .restored)
        #expect(restored.cover == nil)
    }

    // M1
    @Test func deleteAllMyDataForgetsEverySettingAndFavourite() {
        #expect(Set(["permissionsShown", "fewerRemindersAnswered", "lastTrialEnds"]).isSubset(of: AppDefaultsKeys.all))
        let app = makeApp(entitlement: .subscribed)
        app.favourites.toggle("walk.long")
        app.eraseAllData()
        #expect(app.favourites.ids.isEmpty)
        #expect(app.defaults.object(forKey: FavouriteSessions.defaultsKey) == nil)
    }

    /// Plan 08/10/2026 task 1.6: one permission per screen, after the first session only.
    @Test func permissionsComeAfterFirstSession() {
        let app = makeApp(entitlement: .subscribed)
        app.workoutClosed(CompletionResult(isFirstWorkout: true))
        guard case .permissions(.reminders)? = app.cover else { Issue.record("first: \(String(describing: app.cover))"); return }
        var ranAfter = false
        app.afterOneTimeScreens { ranAfter = true }
        #expect(!ranAfter)

        app.permissionStepDone(.reminders)  // "Continue", or "Don't Allow" in Apple's dialog
        guard case .permissions(.health)? = app.cover else { Issue.record("second: \(String(describing: app.cover))"); return }
        #expect(!ranAfter)

        app.permissionStepDone(.health)
        #expect(app.cover == nil)
        #expect(ranAfter)

        // Shown once: the next session goes straight back to Today.
        app.workoutClosed(CompletionResult())
        #expect(app.cover == nil)
    }

    // I5
    @Test func startWalkFromANotificationNeverReplacesARunningSession() {
        let app = makeApp(entitlement: .subscribed)
        let running = WorkoutRequest(day: PlannedDay(main: .walk, chairMoves: 0, cooldown: false), level: .seated,
                                     intensity: .steady, place: .indoors, limits: [], rotationIndex: 0)
        app.cover = .preparing(running)
        app.openTodaySession()
        guard case .preparing(let kept)? = app.cover else { Issue.record("cover replaced: \(String(describing: app.cover))"); return }
        #expect(kept.id == running.id)
    }

    // I4
    @Test func comingBackOnANewDayRebuildsToday() {
        let app = makeApp(entitlement: .subscribed)
        let tomorrow = Date.now.addingTimeInterval(86_400)
        app.now = { tomorrow }
        app.sceneBecameActive()
        #expect(app.loadedDay == app.calendar.startOfDay(for: tomorrow))
    }
}
