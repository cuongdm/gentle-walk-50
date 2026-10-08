import SwiftUI
import UIKit
import GentleWalkCore

/// Four tabs, icon and word always shown (task 6.1). One `NavigationStack` per tab.
struct MainTabView: View {
    @Bindable var app: AppModel

    var body: some View {
        TabView(selection: $app.tab) {
            NavigationStack(path: $app.todayPath) {
                TodayTab(app: app)
                    .navigationDestination(for: TodayRoute.self) { route in
                        switch route {
                        case .allSessions: AllSessionsScreen(app: app)
                        case .program: ProgramScreen(app: app)
                        }
                    }
            }
            .tabItem { Label("Today", systemImage: "sun.max.fill") }
            .tag(AppTab.today)
            NavigationStack(path: $app.journeyPath) {
                JourneyTab(app: app)
                    .navigationDestination(for: JourneyRoute.self) { route in
                        switch route {
                        case .allJourneys:
                            JourneyListView(journeys: app.content.journeys, snapshot: app.journey, isPro: app.isPro) { journey in
                                app.chooseJourney(journey.id)
                                app.journeyPath = []
                            }
                        case .postcard(let journeyID, let stopID):
                            if let stop = app.content.journeys.first(where: { $0.id == journeyID })?.stops.first(where: { $0.id == stopID }) {
                                PostcardDetailView(stop: stop)
                            }
                        }
                    }
            }
            .tabItem { Label("Journey", systemImage: "map.fill") }
            .tag(AppTab.journey)
            NavigationStack(path: $app.progressPath) {
                ProgressTab(app: app)
                    .navigationDestination(for: ProgressRoute.self) { route in
                        switch route {
                        case .sessions: SessionHistoryScreen(sessions: app.progress.sessions, calendar: app.calendar)
                        }
                    }
            }
                .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
                .tag(AppTab.progress)
            NavigationStack(path: $app.mePath) {
                MeView(app: app)
                    .navigationDestination(for: MeRoute.self) { MeDetailView(route: $0, app: app) }
            }
                .tabItem { Label("Me", systemImage: "person.fill") }
                .tag(AppTab.me)
        }
        .tint(Palette.accent)
    }

    /// Tab words at 15 pt instead of the system's ~10–13 (plan 08/10/2026 task 1.2; the selected word is
    /// `accent`, which keeps 5:1 on the page). Set once at launch.
    static func useLargerTabLabels() {
        let font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let scaled = UIFontMetrics(forTextStyle: .footnote).scaledFont(for: font, maximumPointSize: 22)
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        for item in [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance] {
            item.normal.titleTextAttributes = [.font: scaled]
            item.selected.titleTextAttributes = [.font: scaled]
        }
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct TodayTab: View {
    let app: AppModel

    var body: some View {
        if let today = app.today {
            TodayView(model: today, actions: TodayActions(
                yearlyPrice: app.price(ProductID.yearly),
                onStart: { request in app.startFromToday(request, checkIn: today.checkedIn) },
                onSeePlans: { app.offerPlans(.lockedContent) },
                // Straight to the cancel steps: the card is about being billed (review 02/10/2026).
                onManagePlan: { app.cover = .cancelGuide(afterLifetime: false) },
                onOpenJourney: { app.tab = .journey },
                onSeeAllSessions: { app.todayPath.append(.allSessions) },
                onConnectHealth: { Task { _ = await app.health.requestAuthorization(); app.reload() } },
                onDismissCard: app.dismissHealthCard,
                onFewerReminders: app.answerFewerReminders,
                onKeepEasierLevel: app.keepEasierLevel,
                // "Bring it back" lives on Me → Moves set aside.
                onOpenMe: {
                    app.tab = .me
                    app.mePath = [.setAside]
                },
                onStretchInstead: { app.startPreset("stretch.seated.gentle") },
                onMoveReminder: app.moveReminder(to:),
                onKeepReminder: app.keepReminder,
                onLongerWalk: { app.startPreset("walk.long") },
                onOpenProgram: { app.todayPath.append(.program) },
                onSelfCheck: app.openSelfCheck,
                onSelfCheckLater: app.selfCheckLater,
                onPickUpProgram: app.pickUpProgram,
                onProgramFinished: { app.cover = .programFinished }))
        } else {
            ProgressView()
        }
    }
}

struct JourneyTab: View {
    let app: AppModel

    var body: some View {
        if app.journey.isComplete {
            JourneyListView(journeys: app.content.journeys, snapshot: app.journey, isPro: app.isPro, isWhereToNext: true) {
                app.chooseJourney($0.id)
            }
        } else {
            JourneyView(snapshot: app.journey,
                        onAllJourneys: { app.journeyPath.append(.allJourneys) },
                        onPostcard: { app.journeyPath.append(.postcard(journeyID: app.journey.journeyID, stopID: $0.id)) },
                        onSeePlans: { app.offerPlans(.lockedContent) },
                        // Only when today's session is waiting: not on a rest day, not once done (review D20).
                        onWalkNow: app.today.flatMap { $0.doneToday || $0.request == nil ? nil : { app.openTodaySession() } })
        }
    }
}

struct ProgressTab: View {
    let app: AppModel
    @State private var steps: StepsSummary?

    var body: some View {
        ProgressScreen(snapshot: app.progress, wins: app.everydayWins, steps: steps, healthConnected: app.health.isConnected,
                       calendar: app.calendar, now: app.now(), isPro: app.isPro, onToggleWin: app.toggleWin,
                       onSeeAllSessions: { app.isPro ? app.progressPath.append(.sessions) : app.offerPlans(.lockedContent) },
                       onConnectHealth: { Task { _ = await app.health.requestAuthorization(); app.reload() } },
                       content: app.content, onSeePlans: { app.offerPlans(.lockedContent) },
                       goal: GoalText.main(of: app.profile?.goals ?? []))
            .task {
                if let result = await app.health.weeklySteps(now: app.now(), calendar: app.calendar) {
                    steps = StepsSummary(thisWeek: result.thisWeek, lastWeek: result.lastWeek)
                }
            }
    }
}
