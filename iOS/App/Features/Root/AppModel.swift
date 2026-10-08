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
    /// Me's rows open their screens here (plan 08/10/2026 task 3.4).
    var mePath: [MeRoute] = []
    /// "Rest today" from a reminder: the day it was tapped.
    nonisolated static let restTodayKey = "restTodayDate"
    /// Waits for the permission screens or the cancel guide to close (`afterOneTimeScreens`).
    @ObservationIgnored var pendingAfterCover: (() -> Void)?
    private(set) var today: TodayModel?
    private(set) var journey = JourneySnapshot.empty
    private(set) var progress = ProgressSnapshot.empty
    var textSize: TextSizeOverride { didSet { textSize.save(to: defaults) } }
    /// Distance, weight and height units (Me → Language & units).
    var units: UnitPreferences {
        didSet {
            units.save(to: defaults)
            UnitPreferences.current = units
            reload()
        }
    }
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
        let wins = (try? JSONDecoder().decode(File.self, from: data).wins) ?? []
        let texts = AppContent.texts?.wins ?? [:]
        return wins.map { win in
            var copy = win
            copy.text = texts[win.id] ?? win.text
            return copy
        }
    }()
    /// Hearted sessions of "All sessions" (milestone 10).
    @ObservationIgnored lazy var favourites = FavouriteSessions(defaults: defaults)
    /// Clock, injectable for screenshots.
    @ObservationIgnored var now: () -> Date = Date.init
    @ObservationIgnored var calendar: Calendar = .autoupdatingCurrent
    /// Today's busy-day answer from Apple Health steps (P11), read once a day.
    @ObservationIgnored var busyDayCache: BusyDayCache?

    @ObservationIgnored private(set) lazy var completion = SessionCompletionService(
        context: container.mainContext, content: content, entitlement: { [unowned self] in self.entitlement },
        health: health, notifications: notifications, levels: walkLevels,
        cheers: CheerMemoryStore(defaults: defaults), calendar: calendar)
    /// Her current walking level (plan 08/10/2026 decision D1).
    var walkLevels: WalkLevelStore { WalkLevelStore(defaults: defaults) }

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
        let units = UnitPreferences(defaults: defaults)
        self.units = units
        UnitPreferences.current = units
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
        offerWeeklyCheckInIfDue()
        await notifications.reschedule()
    }

    /// The day Today was built for; a new day (midnight, time zone change) rebuilds it (review I4).
    private(set) var loadedDay: Date?

    /// Back in the foreground, or the calendar day changed: rebuild the screens for today.
    func sceneBecameActive() {
        guard loadedDay != calendar.startOfDay(for: now()) else { return }
        reload()
        offerWeeklyCheckInIfDue()
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
        let checks = selfCheckRecords()
        let program = ensureProgram(firstWorkout: records.first?.date)
        journey = JourneySnapshot(states: states, unlocks: unlocks, content: content, entitlement: entitlement)
        // Pro: the hands level each balance exercise is at today (Progress, task 4.10).
        let support = isPro ? SupportLadder.plan(progress: SupportLadderStore(defaults: defaults).progress, intensity: .steady,
                                                 limits: profile?.limits ?? []).levels : [:]
        progress = ProgressSnapshot(records: records, wins: wins, checks: checks, supportLevels: support, restDays: restDays,
                                    calendar: calendar, now: now())
        progress.weeklyNotes = weeklyNoteStore.notes.reversed()
        guard let profile else { today = nil; return }
        let levelState = currentLevel(startLevel: profile.level, records: records)
        let pains = painRecorder.snapshots(since: now().addingTimeInterval(-14 * 86_400))
        var input = TodayInput(
            now: now(), calendar: calendar, name: profile.name, restDays: profile.restDays, limits: profile.limits,
            level: levelState.level, entitlement: entitlement, trialEnds: trialEnds, workouts: records.map {
                TodayInput.Workout(date: $0.date, feeling: $0.feeling.flatMap(Feeling.init), breakCount: $0.breakCount,
                                   level: WalkLevel(rawValue: $0.level) ?? .seated, kind: $0.kind)
            }, pains: pains, healthConnected: health.isConnected || defaults.bool(forKey: "healthCardDismissed")
                || healthAskedRecently,
            suggestFewerReminders: suggestsFewerReminders(records.map(\.date), profile: profile),
            journeyID: journey.journeyID, journeyMiles: journey.totalMiles,
            restedToday: (defaults.object(forKey: Self.restTodayKey) as? Date).map { calendar.isDate($0, inSameDayAs: now()) } ?? false,
            program: program?.programRound, programFinishedAt: program?.finishedAt, selfChecks: checks.map(\.date),
            selfCheckDismissedAt: selfCheckDismissedAt, levelCard: walkLevels.pendingCard)
        // Personalisation (milestone 4).
        let habits = habitSignals(records: records, reminderMinutes: profile.reminderMinutes)
        input.levelChangedAt = levelState.changedAt
        input.goals = profile.goals
        input.activity = profile.activity
        input.exerciseRules = exerciseRules(now: now())
        input.swapMemory = exerciseMemory.memory.activeSwaps(now: now())
        input.checkTrend = SelfCheckComparison.trend(history: checks.map(\.result), now: now(), calendar: calendar)
        input.weeklyNotes = weeklyNoteStore.notes
        input.reminderMinutes = profile.reminderMinutes
        input.reminderSuggestion = habits.reminder
        input.lengthSignal = habits.length
        input.busyDay = isBusyToday
        today = TodayModel(input: input, content: content)
        refreshBusyDayIfNeeded()
    }

    /// Me → Your body: her current level, since when, and where she started (task 0.6).
    var walkingLevel: WalkingLevelSummary? {
        guard let profile else { return nil }
        let state = walkLevels.state(startLevel: profile.level)
        return WalkingLevelSummary(level: state.level, since: state.changedAt, start: profile.level)
    }

    /// Her current level; the card explaining its last change goes once she has done a session after
    /// it, or after 7 days (plan 08/10/2026 task 0.4).
    private func currentLevel(startLevel: WalkLevel, records: [WorkoutRecord]) -> LevelState {
        let store = walkLevels
        if store.pendingCard != nil, let changedAt = store.changedAt,
           records.contains(where: { $0.date > changedAt }) || now().timeIntervalSince(changedAt) >= 7 * 86_400 {
            store.clearCard()
        }
        return store.state(startLevel: startLevel)
    }

    /// The permission screens asked about Apple Health in the last 7 days: Today does not ask again yet
    /// (it asked right after "Not now"; review 02/10/2026).
    private var healthAskedRecently: Bool {
        guard let asked = defaults.object(forKey: "permissionsShownAt") as? Date else { return false }
        return now().timeIntervalSince(asked) < 7 * 86_400
    }

    /// The wins she can do, those for her goal first (P4).
    var everydayWins: [EverydayWinItem] {
        let limits = profile?.limits ?? []
        return GoalText.sorted(allWins.filter { limits.isDisjoint(with: $0.hiddenFor) }, id: \.id,
                               goal: GoalText.main(of: profile?.goals ?? []))
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
        if let rest = defaults.object(forKey: Self.restTodayKey) as? Date, calendar.isDate(rest, inSameDayAs: now()) {
            restDays.insert(Weekday(of: now(), in: calendar))
        }
        return PlannerInput(calendar: calendar, restDays: restDays, reminderMinutes: profile.reminderMinutes,
                            frequency: profile.frequency, workouts: records.map(\.date), trialReminder: nil,
                            landmark: journey.landmarkSoon, settings: notificationSettings, newJourneyName: nil,
                            selfCheckDue: SelfCheckSchedule.dueDate(results: selfCheckRecords().map(\.date), calendar: calendar))
    }
}
