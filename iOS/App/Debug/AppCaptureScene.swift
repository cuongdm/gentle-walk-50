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
                "me", "cancel-guide", "sound-sheet", "watch-on-tv", "permissions", "outdoor-prep", "outdoor-location-ask", "root", "all-sessions"]
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
        case .onboardingWelcome, .onboardingPart2, .onboardingGoal, .onboardingBarriers, .onboardingUnderstandingJoints,
             .onboardingUnderstandingCharged, .onboardingName, .onboardingStrength, .onboardingBody, .onboardingPlan:
            OnboardingView(flow: app.onboarding, onRestore: {}, onFinished: {})
        case .onboardingPlanMoment:
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    DailyMomentPicker(moment: .coffee, minutes: 510, onChoose: { _ in }, onStep: { _ in }, onSet: { _ in })
                    ContinueButton(title: "See my options", action: {})
                }
                .padding(Metrics.screenMargin)
            }
            .screenBackground()
        case .paywallEligible, .paywallMonthly, .paywallLifetime, .paywallNotEligible, .paywallLifetimeWhileSubscribed:
            PaywallView(model: paywallModel, onPurchase: { _ in }, onRestore: {}, onMaybeLater: {})
        case .permissions, .permissionsGranted:
            PermissionsView(model: PermissionsModel(health: nil, notifications: nil, healthConnected: state == .permissionsGranted,
                                                    remindersAllowed: state == .permissionsGranted),
                            reminderTitle: CoverView.reminderTitle(.coffee), onDone: {})
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
        case .outdoorPrep:
            OutdoorPrepView(asksLocation: true, onRequestLocation: {}, onDone: { _ in })
        case .outdoorLocationAsk:
            ScrollView { OutdoorLocationAskView(onUseLocation: {}, onStepsOnly: {}) }.screenBackground()
        case .postcard:
            if let stop = app.content.journeys.first?.stops[1] { PostcardDetailView(stop: stop) }
        case .todaySwap:
            SwapSessionSheet(options: app.today?.swapOptions ?? []) { _ in }
        case .allSessions, .allSessionsFree:
            NavigationStack { AllSessionsScreen(app: app) }
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
        case .todayFree, .journeysFree, .todayTrialEnded, .lockedStop, .allSessionsFree: .free
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
        case .progress:
            let records = (try? context.fetch(FetchDescriptor<WorkoutRecord>())) ?? []
            for (index, record) in records.enumerated() {
                record.sitToStandCount = 5 + index / 3
                if index % 4 == 0 { record.activeSeconds = 10 * 60 }
            }
            context.insert(EverydayWin(key: "win.1", checkedAt: now))
            context.insert(EverydayWin(key: "win.3", checkedAt: now))
        default:
            break
        }
    }

    private func prepare(_ app: AppModel) {
        switch state {
        case .allSessions:
            app.favourites.toggle("walk.long")
            app.favourites.toggle("extra.balance")
        case .onboardingWelcome: app.onboarding.jump(to: .welcome)
        case .onboardingPart2: app.onboarding.jump(to: .part2)
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
        case .progress, .progressNoHealth: app.tab = .progress
        case .me, .meLifetime, .meLifetimeAndSubscription: app.tab = .me
        default: app.tab = .today
        }
    }
}
#endif
