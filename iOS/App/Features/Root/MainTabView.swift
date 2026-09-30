import SwiftUI
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
            NavigationStack { ProgressTab(app: app) }
                .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
                .tag(AppTab.progress)
            NavigationStack { MeView(app: app) }
                .tabItem { Label("Me", systemImage: "person.fill") }
                .tag(AppTab.me)
        }
        .tint(Palette.accent)
    }
}

struct TodayTab: View {
    let app: AppModel

    var body: some View {
        if let today = app.today {
            TodayView(model: today, actions: TodayActions(
                yearlyPrice: app.price(ProductID.yearly),
                onStart: { request in app.preview(request, checkIn: today.checkedIn) },
                onSeePlans: { app.offerPlans(.lockedContent) },
                onManagePlan: { app.tab = .me },
                onOpenJourney: { app.tab = .journey },
                onSeeAllSessions: { app.todayPath.append(.allSessions) },
                onConnectHealth: { Task { _ = await app.health.requestAuthorization(); app.reload() } },
                onDismissCard: app.dismissHealthCard,
                onFewerReminders: app.answerFewerReminders))
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
                       calendar: app.calendar, now: app.now(), onToggleWin: app.toggleWin,
                       onConnectHealth: { Task { _ = await app.health.requestAuthorization(); app.reload() } })
            .task {
                if let result = await app.health.weeklySteps(now: app.now(), calendar: app.calendar) {
                    steps = StepsSummary(thisWeek: result.thisWeek, lastWeek: result.lastWeek)
                }
            }
    }
}
