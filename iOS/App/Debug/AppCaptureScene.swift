#if DEBUG
import SwiftUI
import SwiftData
import GentleWalkCore

/// Screenshot scenes for onboarding, paywall, the tabs, Me, permissions and outdoor prep.
struct AppCaptureScene: View {
    let state: CaptureState
    @State private var app: AppModel?

    static func handles(_ state: CaptureState) -> Bool {
        let name = state.rawValue
        return ["onboarding", "paywall", "today", "journey", "journeys", "where-next", "postcard", "locked-stop", "progress",
                "me", "cancel-guide", "sound-sheet", "watch-on-tv", "permissions", "reminder-offer", "outdoor-prep", "outdoor-measure-choice", "outdoor-location-prompt", "root", "all-sessions",
                "program", "selfcheck"]
            .contains { name == $0 || name.hasPrefix($0 + "-") }
    }

    var body: some View {
        Group {
            if let app {
                // The same cover presenter as AppRootView, so taps in a capture scene (a session card,
                // Start, the paywall) open their screens instead of setting `app.cover` with nobody to show it.
                scene(app)
                    .fullScreenCover(item: Binding(get: { app.cover }, set: { app.cover = $0 })) { cover in
                        CoverView(app: app, cover: cover)
                    }
            } else {
                Palette.bg.ignoresSafeArea()
            }
        }
        .task { app = makeApp() }
    }

    @ViewBuilder private func scene(_ app: AppModel) -> some View {
        switch state {
        case .onboardingWelcome, .onboardingGoal, .onboardingBarriers, .onboardingUnderstandingJoints,
             .onboardingUnderstandingCharged, .onboardingName, .onboardingStrength, .onboardingBody, .onboardingPlan:
            OnboardingView(flow: app.onboarding, onRestore: {}, onFinished: {})
        case .paywallEligible, .paywallMonthly, .paywallLifetime, .paywallNotEligible, .paywallLifetimeWhileSubscribed:
            PaywallView(model: paywallModel, onPurchase: { _ in }, onRestore: {}, onMaybeLater: {})
        case .permissionsReminder, .permissionsHealth, .permissionsHealthGranted:
            PermissionStepView(ask: state == .permissionsReminder ? .reminders : .health,
                               model: PermissionsModel(health: nil, notifications: nil,
                                                       healthConnected: state == .permissionsHealthGranted,
                                                       remindersAllowed: state != .permissionsReminder),
                               moment: .coffee, minutes: 510, onReminderTime: { _, _ in }, onDone: {},
                               onBack: state == .permissionsReminder ? nil : {})
        case .soundSheet:
            SoundSheet(showsMusic: true) { _ in }
        case .watchOnTV:
            WatchOnTVSheet()
        case .cancelGuide:
            CancelGuideView(accessUntil: Date.now.addingTimeInterval(12 * 86_400).formatted(.dateTime.month(.abbreviated).day()),
                            onBack: {})
        case .meNotifications:
            ScrollView { NotificationSection(app: app).padding(Metrics.screenMargin) }.screenBackground()
        case .meDeleteConfirm:
            DeleteDataConfirmation(onDelete: {}, onCancel: {})
        case .outdoorPrep, .outdoorMeasureChoice, .outdoorLocationPrompt:
            OutdoorPrepView(asksLocation: true, onRequestLocation: { false }, onDone: { _ in },
                            startStep: state == .outdoorPrep ? .ready : state == .outdoorMeasureChoice ? .measure : .locationPrompt)
        case .postcard:
            if let stop = app.content.journeys.first?.stops[1] { PostcardDetailView(stop: stop) }
        case .todaySwap:
            SwapSessionSheet(options: app.today?.swapOptions ?? [], onPick: { _ in }, onSeeAll: {})
        case .allSessions, .allSessionsFree:
            NavigationStack { AllSessionsScreen(app: app) }
        case .progressDay:
            let day = app.progress.sessions.first?.date ?? .now
            NavigationStack { ProgressTab(app: app) }
                .sheet(isPresented: .constant(true)) {
                    DaySessionsSheet(day: day, sessions: SessionHistoryItem.on(day, in: app.progress.sessions, calendar: app.calendar))
                }
        case .progressSessions:
            NavigationStack { SessionHistoryScreen(sessions: app.progress.sessions, calendar: app.calendar) }
        case .program:
            NavigationStack { ProgramScreen(app: app) }
        case .journeys, .journeysFree:
            NavigationStack {
                JourneyListView(journeys: app.content.journeys, snapshot: app.journey, isPro: app.isPro, onChoose: { _ in })
            }
        default:
            MainTabView(app: app)
        }
    }

    private var paywallModel: PaywallModel {
        let model = PaywallModel(options: AppModel.capturePlanOptions, isEligibleForTrial: state != .paywallNotEligible,
                                 activeRenewingProductID: state == .paywallLifetimeWhileSubscribed ? ProductID.yearly : nil)
        switch state {
        case .paywallMonthly: model.selectedID = ProductID.monthly
        case .paywallLifetime, .paywallLifetimeWhileSubscribed: model.selectedID = ProductID.lifetime
        default: break
        }
        return model
    }

    private func makeApp() -> AppModel {
        let trialEnds = Date.now.addingTimeInterval(2 * 86_400)
        let entitlement: Entitlement = switch state {
        case .todayFree, .journeysFree, .todayTrialEnded, .lockedStop, .allSessionsFree, .progressFree: .free
        case .todayTrialEnding: .trial(ends: trialEnds)
        case .me: .trial(ends: Date.now.addingTimeInterval(12 * 86_400))
        case .meLifetime, .meLifetimeAndSubscription: .lifetime
        default: .subscribed
        }
        let app = AppModel.capture(entitlement: entitlement, healthConnected: state != .progressNoHealth) { context, now, calendar in
            seed(context, now: now, calendar: calendar)
        }
        if state == .meLifetimeAndSubscription {
            app.renewalOverride = (ProductID.yearly, Date.now.addingTimeInterval(12 * 86_400))
        }
        if state == .todayTrialEnded { app.defaults.set(Date.now.addingTimeInterval(-3 * 86_400), forKey: "lastTrialEnds") }
        if state == .todayRest { app.defaults.set(Date.now, forKey: AppModel.restTodayKey) }
        if state == .me {
            // Me shows "Walking level: In place since …" (task 0.6): moved up six days ago.
            app.walkLevels.set(level: .inPlace, changedAt: app.now().addingTimeInterval(-6 * 86_400), card: nil)
        }
        if state == .todayMovedUp {
            // Moved up after her last session (an hour ago, after every seeded workout).
            app.walkLevels.set(level: .inPlace, changedAt: app.now().addingTimeInterval(-3_600), card: .movedUp(to: .inPlace))
        }
        app.reload()
        prepare(app)
        return app
    }

    /// Extra data per state on top of the Margaret fixture.
    private func seed(_ context: ModelContext, now: Date, calendar: Calendar) {
        switch state {
        case .todayDone:
            context.insert(WorkoutRecord(date: now.addingTimeInterval(-3_600), kind: "walk", level: "seated", intensity: "steady",
                                         place: "indoors", activeSeconds: 480, journeyMiles: 0.4))
        case .todayPainCard:
            for day in 1...3 {
                context.insert(PainReport(date: now.addingTimeInterval(-Double(day) * 86_400), area: BodyArea.knees.rawValue))
            }
        case .todayNew:
            // "Not yet" on the First Walk: no session finished.
            ((try? context.fetch(FetchDescriptor<WorkoutRecord>())) ?? []).forEach(context.delete)
        case .todayWelcomeBack:
            let records = (try? context.fetch(FetchDescriptor<WorkoutRecord>())) ?? []
            let cutoff = now.addingTimeInterval(-5 * 86_400)
            records.filter { $0.date > cutoff }.forEach(context.delete)
        case .whereNext:
            let states = (try? context.fetch(FetchDescriptor<JourneyState>())) ?? []
            states.forEach { $0.miles = 5.2; $0.completedAt = now }
        case .lockedStop:
            let states = (try? context.fetch(FetchDescriptor<JourneyState>())) ?? []
            states.forEach { $0.isCurrent = false }
            context.insert(JourneyState(journeyID: "jr.smoky", miles: 1.4, isCurrent: true, startedAt: now))
            context.insert(PostcardUnlock(journeyID: "jr.smoky", stopID: "pc.smoky.1", unlockedAt: now))
        case .todayCheckDue:
            // The last check two weeks and a day ago: due today.
            for check in (try? context.fetch(FetchDescriptor<SelfCheckRecord>())) ?? [] {
                check.date = check.date.addingTimeInterval(-13 * 86_400)
            }
        case .progressChecks, .programFinished:
            // Three checks, week 0, 2 and 4 (7, 8, 9), with her hands; the finish screen puts the start 12 weeks back.
            ((try? context.fetch(FetchDescriptor<SelfCheckRecord>())) ?? []).forEach(context.delete)
            let back = state == .programFinished ? 84 : 28
            for (index, count) in [7, 8, 9].enumerated() {
                let daysAgo = back - index * (state == .programFinished ? 40 : 13)
                context.insert(SelfCheckRecord(date: now.addingTimeInterval(-Double(daysAgo) * 86_400), count: count, usedHands: true,
                                               week: index * (state == .programFinished ? 6 : 2)))
            }
            for program in (try? context.fetch(FetchDescriptor<ProgramState>())) ?? [] {
                program.start = calendar.startOfDay(for: now.addingTimeInterval(-Double(back + 1) * 86_400))
            }
        case .progress, .progressFree, .progressDay, .progressSessions:
            let records = ((try? context.fetch(FetchDescriptor<WorkoutRecord>())) ?? []).sorted { $0.date > $1.date }
            let feelings: [Feeling?] = [.justRight, .justRight, .tooEasy, nil, .justRight, .tooHard]
            for (index, record) in records.enumerated() {
                record.sitToStandCount = 5 + index / 3
                if index % 4 == 0 { record.activeSeconds = 10 * 60 }
                // A real mix for the history: walks, chair moves, a stretch and one outdoor walk.
                record.kind = ["walk", "chair", "walk", "stretch", "walk", "chair"][index % 6]
                record.feeling = feelings[index % feelings.count]?.rawValue
                if index == 2 { record.place = "outdoors"; record.outdoorMiles = 0.9 }
            }
            // Two sessions on the latest day, so the day sheet shows more than one.
            if let latest = records.first {
                context.insert(WorkoutRecord(date: latest.date.addingTimeInterval(8 * 3_600), kind: "balance", level: "seated",
                                             intensity: "steady", place: "indoors", activeSeconds: 5 * 60, journeyMiles: 0.25,
                                             feeling: Feeling.justRight.rawValue))
            }
            context.insert(EverydayWin(key: "win.1", checkedAt: now))
            context.insert(EverydayWin(key: "win.3", checkedAt: now))
        default:
            break
        }
    }

    private func prepare(_ app: AppModel) {
        switch state {
        case .reminderOffer: app.cover = .reminderOffer
        case .selfcheckIntro, .selfcheckTimer, .selfcheckCount:
            // The timer runs on the real clock, started 20 s back: the shot shows the count under way.
            let model = SelfCheckFlowModel(history: app.selfCheckResults(), week: 3, now: { Date.now.addingTimeInterval(-20) })
            if state != .selfcheckIntro { model.ready() }
            if state == .selfcheckCount { model.stopEarly() }
            app.cover = .selfCheck(model)
        case .programFinished: app.cover = .programFinished
        case .progressChecks: app.tab = .progress
        case .allSessions:
            app.favourites.toggle("walk.long")
            app.favourites.toggle("extra.balance")
        case .onboardingWelcome: app.onboarding.jump(to: .welcome)
        case .onboardingGoal:
            app.onboarding.toggleGoal(.steadier)
            app.onboarding.jump(to: .goal)
        case .onboardingBarriers:
            app.onboarding.toggleBarrier(.joints)
            app.onboarding.toggleBarrier(.charged)
            app.onboarding.jump(to: .barriers)
        case .onboardingUnderstandingJoints:
            app.onboarding.toggleBarrier(.joints)
            app.onboarding.jump(to: .understanding)
        case .onboardingUnderstandingCharged:
            app.onboarding.toggleBarrier(.charged)
            app.onboarding.jump(to: .understanding)
        case .onboardingName:
            app.onboarding.nameText = "Margaret"
            app.onboarding.jump(to: .name)
        case .onboardingStrength:
            app.onboarding.answers.chair = .hard
            app.onboarding.jump(to: .chair)
        case .onboardingBody:
            app.onboarding.toggleLimit(.knees)
            app.onboarding.toggleLimit(.noFloor)
            app.onboarding.jump(to: .body)
        case .onboardingPlan:
            app.onboarding.nameText = "Margaret"
            app.onboarding.toggleBarrier(.tooFast)
            app.onboarding.toggleBarrier(.charged)
            app.onboarding.toggleLimit(.knees)
            app.onboarding.toggleLimit(.noFloor)
            app.onboarding.jump(to: .plan)
        case .journey, .lockedStop: app.tab = .journey
        case .whereNext: app.tab = .journey
        case .progress, .progressNoHealth, .progressFree: app.tab = .progress
        case .me, .meLifetime, .meLifetimeAndSubscription: app.tab = .me
        default: app.tab = .today
        }
    }
}
#endif
