import Foundation
import Observation
import SwiftData
import GentleWalkCore

/// App state: services, the profile, which cover is open, and the Today model. Screens get narrow
/// inputs from here; flows live in `AppModel+Flows.swift`.
@Observable @MainActor final class AppModel {
    let container: ModelContainer
    let content: ContentBundle
    let store: StoreService
    let health: HealthService
    let notifications: NotificationScheduler
    let music: MusicLibrary
    let painRecorder: SwiftDataPainRecorder
    let location: LocationService
    let pedometer: PedometerService
    let motion: MotionService
    let voiceSource: VoiceSource
    let defaults: UserDefaults

    private(set) var profile: ProfileSnapshot?
    var onboarding = OnboardingFlow()
    var cover: AppCover?
    var tab: AppTab = .today
    var todayPath: [TodayRoute] = []
    /// Shown as an alert after a purchase or Restore (review I10).
    var storeNotice: StoreNotice?
    var showsStoreNotice: Bool {
        get { storeNotice != nil }
        set { if !newValue { storeNotice = nil } }
    }
    var journeyPath: [JourneyRoute] = []
    var progressPath: [ProgressRoute] = []
    private(set) var today: TodayModel?
    private(set) var journey = JourneySnapshot.empty
    private(set) var progress = ProgressSnapshot.empty
    var textSize: TextSizeOverride { didSet { textSize.save(to: defaults) } }
    var appearance: AppearanceChoice {
        didSet {
            appearance.save(to: defaults)
            appearance.apply()
        }
    }
    var notificationSettings: NotificationSettings {
        didSet {
            if let data = try? JSONEncoder().encode(notificationSettings) { defaults.set(data, forKey: "notificationSettings") }
            Task { await notifications.reschedule() }
        }
    }
    /// DEBUG screenshots pin the entitlement; the app always reads StoreKit.
    var entitlementOverride: Entitlement?
    /// DEBUG screenshots: prices from the local StoreKit file when StoreKit is not attached.
    @ObservationIgnored var priceOverride: [String: String] = [:]
    /// D9 Everyday wins, without the ones hidden for the user's body limits.
    @ObservationIgnored private(set) lazy var allWins: [EverydayWinItem] = {
        struct File: Decodable { var wins: [EverydayWinItem] }
        guard let url = Bundle.main.url(forResource: "wins", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode(File.self, from: data).wins) ?? []
    }()
    /// Hearted sessions of "All sessions" (milestone 10).
    @ObservationIgnored lazy var favourites = FavouriteSessions(defaults: defaults)
    /// Clock, injectable for screenshots.
    @ObservationIgnored var now: () -> Date = Date.init
    @ObservationIgnored var calendar: Calendar = .autoupdatingCurrent

    @ObservationIgnored private(set) lazy var completion = SessionCompletionService(
        context: container.mainContext, content: content, entitlement: { [unowned self] in self.entitlement },
        health: health, notifications: notifications, calendar: calendar)

    var entitlement: Entitlement { entitlementOverride ?? store.entitlement }

    /// "All sessions" for her plan and limits, moves rotating with her active days.
    func makeAllSessions() -> AllSessionsModel {
        AllSessionsModel(isPro: isPro, limits: profile?.limits ?? [], rotationIndex: today?.activeDays ?? 0,
                         content: content, favourites: favourites)
    }
    var isPro: Bool { entitlement.isPro }
    var onboardingDone: Bool { profile != nil }

    init(container: ModelContainer, content: ContentBundle, store: StoreService, health: HealthService,
         notificationCenter: NotificationCenterProtocol, location: LocationService, pedometer: PedometerService,
         motion: MotionService, defaults: UserDefaults = .standard) {
        self.container = container
        self.content = content
        self.store = store
        self.health = health
        self.location = location
        self.pedometer = pedometer
        self.motion = motion
        self.defaults = defaults
        music = (try? MusicLibrary.load(bundle: .main)) ?? (try! MusicLibrary(data: Data(#"{"schemaVersion":1,"tracks":[]}"#.utf8)))
        painRecorder = SwiftDataPainRecorder(context: container.mainContext)
        voiceSource = VoiceSource(lines: content.voiceLines)
        textSize = TextSizeOverride(defaults: defaults)
        appearance = AppearanceChoice(defaults: defaults)
        notificationSettings = defaults.data(forKey: "notificationSettings")
            .flatMap { try? JSONDecoder().decode(NotificationSettings.self, from: $0) } ?? NotificationSettings()
        let bank = (try? PhraseBank.load(bundle: .main)) ?? PhraseBank(phrases: [])
        var planner: (() -> PlannerInput?)?
        notifications = NotificationScheduler(center: notificationCenter, bank: bank, context: container.mainContext,
                                              input: { planner?() })
        planner = { [weak self] in self?.plannerInput() }
        store.setTrialReminders(notifications)
    }

    /// The app as shipped.
    static func live() -> AppModel {
        let container = (try? ModelContainerFactory.make(inMemory: false)) ?? (try! ModelContainerFactory.make(inMemory: true))
        return AppModel(container: container, content: AppContent.bundle, store: StoreService(),
                        health: HealthService(store: SystemHealthStore()), notificationCenter: SystemNotificationCenter(),
                        location: LocationService(manager: SystemLocationManager(), background: SystemBackgroundActivity()),
                        pedometer: PedometerService(pedometer: SystemPedometer()), motion: MotionService())
    }

    /// Launch: StoreKit listener and products, data, notifications. No permission is asked here.
    func launch() async {
        // Her data and plan first, so a returning user never sees Welcome while products load and a
        // subscriber offline is not treated as free (review I3); products (prices) come after.
        reload()
        store.onUpdate = { [weak self] in self?.reload() }
        store.startListening()
        await store.refresh()
        reload()
        try? await store.loadProducts()
        reload()
        await notifications.reschedule()
    }

    /// The day Today was built for; a new day (midnight, time zone change) rebuilds it (review I4).
    private(set) var loadedDay: Date?

    /// Back in the foreground, or the calendar day changed: rebuild the screens for today.
    func sceneBecameActive() {
        guard loadedDay != calendar.startOfDay(for: now()) else { return }
        reload()
        Task { await notifications.reschedule() }
    }

    // MARK: Reading the store

    func reload() {
        loadedDay = calendar.startOfDay(for: now())
        let context = container.mainContext
        profile = (try? context.fetch(FetchDescriptor<UserProfile>()))?.first { $0.onboardingCompleted }.map(ProfileSnapshot.init)
        let records = (try? context.fetch(FetchDescriptor<WorkoutRecord>(sortBy: [SortDescriptor(\.date)]))) ?? []
        let states = (try? context.fetch(FetchDescriptor<JourneyState>())) ?? []
        let unlocks = (try? context.fetch(FetchDescriptor<PostcardUnlock>())) ?? []
        let wins = (try? context.fetch(FetchDescriptor<EverydayWin>())) ?? []
        journey = JourneySnapshot(states: states, unlocks: unlocks, content: content, entitlement: entitlement)
        progress = ProgressSnapshot(records: records, wins: wins, restDays: restDays, calendar: calendar, now: now())
        guard let profile else { today = nil; return }
        let pains = painRecorder.snapshots(since: now().addingTimeInterval(-14 * 86_400))
        let input = TodayInput(
            now: now(), calendar: calendar, name: profile.name, restDays: profile.restDays, limits: profile.limits,
            level: profile.level, entitlement: entitlement, trialEnds: trialEnds, workouts: records.map {
                TodayInput.Workout(date: $0.date, feeling: $0.feeling.flatMap(Feeling.init), breakCount: $0.breakCount,
                                   level: WalkLevel(rawValue: $0.level) ?? .seated)
            }, pains: pains, healthConnected: health.isConnected || defaults.bool(forKey: "healthCardDismissed"),
            suggestFewerReminders: suggestsFewerReminders(records.map(\.date), profile: profile),
            journeyID: journey.journeyID, journeyMiles: journey.totalMiles)
        today = TodayModel(input: input, content: content)
    }

    var everydayWins: [EverydayWinItem] {
        let limits = profile?.limits ?? []
        return allWins.filter { limits.isDisjoint(with: $0.hiddenFor) }
    }

    func toggleWin(_ key: String) {
        let context = container.mainContext
        let existing = (try? context.fetch(FetchDescriptor<EverydayWin>(predicate: #Predicate { $0.key == key }))) ?? []
        if existing.isEmpty { context.insert(EverydayWin(key: key, checkedAt: now())) } else { existing.forEach(context.delete) }
        try? context.save()
        reload()
    }

    /// DEBUG screenshots: a plan that still renews next to lifetime.
    @ObservationIgnored var renewalOverride: (productID: String, date: Date)?
    var renewingProductID: String? { renewalOverride?.productID ?? store.activeRenewingProductID }
    var renewalDate: Date? { renewalOverride?.date ?? store.renewalDate }

    /// Display price for a product (always from StoreKit in the app).
    func price(_ productID: String) -> String? {
        store.products[productID]?.displayPrice ?? priceOverride[productID]
    }

    var restDays: Set<Weekday> {
        RestDays.effective(chosen: profile?.restDays ?? RestDays.freeTier, entitlement: entitlement)
    }

    /// End of the last trial (kept so Today can say "Your trial has ended").
    var trialEnds: Date? {
        if case .trial(let ends) = entitlement {
            defaults.set(ends, forKey: "lastTrialEnds")
            return ends
        }
        return defaults.object(forKey: "lastTrialEnds") as? Date
    }

    private func suggestsFewerReminders(_ dates: [Date], profile: ProfileSnapshot) -> Bool {
        guard profile.frequency == .daily, !defaults.bool(forKey: "fewerRemindersAnswered") else { return false }
        return NotificationPlanner.offersFewerReminders(workouts: dates, reminderMinutes: profile.reminderMinutes, calendar: calendar)
    }

    /// What the notification planner needs, from the profile, workouts and settings.
    func plannerInput() -> PlannerInput? {
        guard let profile else { return nil }
        let records = (try? container.mainContext.fetch(FetchDescriptor<WorkoutRecord>())) ?? []
        var restDays = restDays
        // "Rest today" from a reminder: today counts as a rest day (its weekday appears once in 7 days).
        if let rest = defaults.object(forKey: "restTodayDate") as? Date, calendar.isDate(rest, inSameDayAs: now()) {
            restDays.insert(Weekday(of: now(), in: calendar))
        }
        return PlannerInput(calendar: calendar, restDays: restDays, reminderMinutes: profile.reminderMinutes,
                            frequency: profile.frequency, workouts: records.map(\.date), trialReminder: nil,
                            landmark: journey.landmarkSoon, settings: notificationSettings, newJourneyName: nil)
    }
}
