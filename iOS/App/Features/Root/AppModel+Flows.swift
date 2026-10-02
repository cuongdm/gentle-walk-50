import AVFoundation
import Foundation
import GentleWalkCore
import SwiftData

/// The first-run path and everyday flows (task 4.13): onboarding → paywall → phone placement →
/// First Walk → Complete → permissions → Today. "Maybe later" never lands on an empty screen.
extension AppModel {
    // MARK: Onboarding and paywall

    func finishOnboarding() {
        _ = try? onboarding.finish(into: container.mainContext, now: now())
        reload()
        // Already Pro (reinstall, or Restore on Welcome): straight to the First Walk (review I2).
        if isPro { afterPaywall(.onboarding) } else { cover = .paywall(.onboarding) }
    }

    /// Opens the plans if the paywall policy allows it for this trigger.
    func offerPlans(_ trigger: PaywallTrigger) {
        let dismissed = defaults.object(forKey: "paywallDismissedAt") as? Date
        guard PaywallPolicy.shouldShow(trigger: trigger, entitlement: entitlement, lastDismissed: dismissed, now: now()) else { return }
        cover = .paywall(trigger)
    }

    func paywallMaybeLater(_ trigger: PaywallTrigger) {
        defaults.set(now(), forKey: "paywallDismissedAt")
        afterPaywall(trigger)
    }

    func purchase(_ option: PlanOption, trigger: PaywallTrigger) async {
        let outcome: PurchaseOutcome
        do {
            outcome = try await store.purchase(option.id)
        } catch {
            storeNotice = .failed
            return
        }
        if outcome == .pending { storeNotice = .pending }
        guard outcome == .purchased else { return }
        reload()
        await notifications.reschedule()
        if option.kind == .lifetime, store.activeRenewingProductID != nil {
            cover = .cancelGuide(afterLifetime: true)
        } else {
            afterPaywall(trigger)
        }
    }

    /// Restore, with a plain answer; from a paywall that is no longer needed, it moves on (I10).
    func restorePurchases(from trigger: PaywallTrigger? = nil) async {
        do {
            try await store.restore()
        } catch {
            reload()
            storeNotice = .failed
            return
        }
        reload()
        guard isPro else { storeNotice = .nothingToRestore; return }
        storeNotice = .restored
        if let trigger, case .paywall? = cover { afterPaywall(trigger) }
    }

    private func afterPaywall(_ trigger: PaywallTrigger) {
        if trigger == .onboarding {
            begin(.firstWalk(limits: profile?.limits ?? []))
        } else {
            oneTimeScreenClosed()
        }
    }

    // MARK: Workouts

    /// Today's Start (and Extras): the preview first (S10).
    func preview(_ request: WorkoutRequest, checkIn: CheckIn?) {
        // A picked stretch: the preview sets seated or standing itself, from her own limits.
        let preset = request.presetID.flatMap(SessionCatalog.preset(id:))
        let limits = preset?.main == .stretch ? (profile?.limits ?? request.limits.subtracting([.standingIsHard])) : request.limits
        let model = WorkoutPreviewModel(day: request.day, intensity: request.intensity, checkIn: checkIn,
                                        suggestedLevel: request.level, limits: limits, rotationIndex: request.rotationIndex,
                                        minutesDelta: request.minutesDelta, content: content, defaults: defaults,
                                        presetID: request.presetID, standing: preset?.standing ?? false)
        cover = .preview(model)
    }

    /// Complete → "Do it again": the same session from its preview, as a new run.
    func again(_ request: WorkoutRequest) {
        var request = request
        request.id = UUID()
        afterOneTimeScreens { [self] in preview(request, checkIn: today?.checkedIn) }
    }

    /// Runs `action` now, or once "Two quick things" or the cancel guide closes: those show once and
    /// were replaced (lost for good) by "Do it again", "Do them now" or a reminder's Start (review
    /// 02/10/2026).
    func afterOneTimeScreens(_ action: @escaping () -> Void) {
        switch cover {
        // The plans offered at the end of New York wait too (they flashed and were lost).
        case .permissions?, .cancelGuide?, .paywall?: pendingAfterCover = action
        default: action()
        }
    }

    /// The one-time screen closed: what was waiting runs now.
    func oneTimeScreenClosed() {
        cover = nil
        let action = pendingAfterCover
        pendingAfterCover = nil
        action?()
    }

    /// Starts a session, showing phone placement or outdoor prep the first time. `showsReady`: an
    /// "Up next" screen before the count, for sessions that did not come from their preview (the
    /// First Walk, chair moves after an outdoor walk); the preview and outdoor prep already say it.
    func begin(_ request: WorkoutRequest, showsReady: Bool = true) {
        if request.place != .outdoors, !defaults.bool(forKey: PhonePlacement.seenKey) {
            cover = .phonePlacement(request)
        } else if request.place == .outdoors, !defaults.bool(forKey: "outdoorPrepSeen") {
            cover = .outdoorPrep(request)
        } else {
            cover = .preparing(request)
            Task { await prepareAndPlay(request, showsReady: showsReady) }
        }
    }

    /// Start now on the preview: she has just seen the session, so straight to the count.
    func beginFromPreview(_ request: WorkoutRequest) { begin(request, showsReady: false) }

    func placementDone(_ request: WorkoutRequest) {
        defaults.set(true, forKey: PhonePlacement.seenKey)
        begin(request)
    }

    func outdoorPrepDone(_ request: WorkoutRequest, useLocation: Bool?) {
        defaults.set(true, forKey: "outdoorPrepSeen")
        if let useLocation { defaults.set(useLocation ? "location" : "steps", forKey: "outdoorLocationChoice") }
        begin(request, showsReady: false)
    }

    var usesLocationOutdoors: Bool { defaults.string(forKey: "outdoorLocationChoice") == "location" }

    private func prepareAndPlay(_ request: WorkoutRequest, showsReady: Bool) async {
        guard var plan = try? request.plan(content: content) else { cover = nil; return }
        let levels = AudioLevels.saved(in: defaults)
        // "Move introductions" off: each chair move starts with its instructions, not its name.
        if !levels.moveIntroductions { plan = plan.withoutMoveIntroductions() }
        let media = await SessionMedia.prepare(plan: plan, content: content, voiceSource: voiceSource)
        let kind: MusicKind = switch request.day.main {
        case .chair: .chair
        case .stretch: .stretch
        default: .walk
        }
        // Music is always in the program so the Music button can bring it back; the Me switch sets the start.
        // "Voice louder than music" (on by default): music dips further while the coach speaks.
        let voiceLouder = defaults.object(forKey: "voiceLouder") as? Bool ?? true
        guard let engine = media.makeEngine(musicURL: music.url(for: kind),
                                            duckedVolume: voiceLouder ? SessionAudioComposer.duckedVolume : 0.6)
        else { cover = nil; return }
        let session = WorkoutSessionModel(request: request, content: content, engine: engine, completion: completion,
                                          painRecorder: painRecorder, now: now)
        do {
            try await session.load(timeline: media.timeline)
        } catch {
            // The audio could not be built: back to where she was, with a plain word (review I7).
            cover = nil
            storeNotice = .sessionFailed
            return
        }
        // GPS, pedometer and motion start only for a session that will run (they kept running after a
        // failed build; review 02/10/2026).
        if request.place == .outdoors { attachOutdoor(to: session) }
        if request.day.main == .chair || request.day.chairMoves > 0 { attachMotion(to: session) }
        if defaults.bool(forKey: "musicOff") { session.player.setMusicOn(false) }
        session.player.setLevels(voice: levels.voice, music: levels.music)
        let context: AudioContext = request.place == .outdoors && AVAudioSession.sharedInstance().isOtherAudioPlaying
            ? .overUserAudio : .guided
        try? AudioSessionConfigurator.apply(context)
        // Her own podcast or music outdoors: no app music on top of it (the Music button can still add it).
        if context == .overUserAudio { session.player.setMusicOn(false) }
        session.player.nowPlaying = NowPlayingController(
            title: request.title, onPlay: { [weak session] in session?.remoteResume() },
            onPause: { [weak session] in session?.player.pause(.user) })
        // "Get ready" 3-2-1 first, like a class starting: time to set the phone down.
        session.startWithCountdown(showsReady: showsReady)
        cover = .workout(session)
    }

    private func attachOutdoor(to session: WorkoutSessionModel) {
        let start = now()
        if usesLocationOutdoors, location.isAuthorized {
            location.startWalk(at: start)
            session.tracksRoute = true
        } else {
            pedometer.start(at: start)
        }
        session.outdoorDistance = { [weak self] in
            guard let self else { return nil }
            return self.location.hasFix ? self.location.miles : self.pedometer.miles
        }
        session.routeProvider = { [weak self] in self?.location.route ?? [] }
        session.locationOn = { [weak self] in self?.location.hasFix ?? false }
        session.onEnded = { [weak self] in
            self?.location.endWalk()
            self?.pedometer.stop()
        }
    }

    private func attachMotion(to session: WorkoutSessionModel) {
        guard PhonePlacement.saved(in: defaults) == .chest else { return }
        motion.reset()
        session.motion = motion
    }

    /// "Not yet" on the First Walk: offer a reminder, once, unless iOS was already asked.
    func offerReminderAfterNotYet() async {
        guard !defaults.bool(forKey: "reminderOfferShown"), await SystemPermission.reminders() == .notAsked else { return }
        defaults.set(true, forKey: "reminderOfferShown")
        if cover == nil { cover = .reminderOffer }
    }

    func workoutClosed(_ result: CompletionResult?) {
        AudioSessionConfigurator.deactivate()
        reload()
        // After the first saved session of any kind (an Extra or a swap can come before the First Walk).
        if result != nil, !defaults.bool(forKey: "permissionsShown") {
            defaults.set(true, forKey: "permissionsShown")
            defaults.set(now(), forKey: "permissionsShownAt")
            cover = .permissions
        } else {
            cover = nil
            if result?.journeyComplete == true, journey.journeyID == "jr.ny" { offerPlans(.finishedNewYork) }
        }
        Task { await notifications.reschedule() }
    }

    /// Asks for a rating only at a milestone and on a calm day (5.6.1, task 6.11).
    func reviewMilestone(for result: CompletionResult) -> ReviewMilestone? {
        let milestone: ReviewMilestone? = result.journeyComplete && result.journeyID == "jr.ny" ? .finishedNewYork
            : result.activeDays == 7 ? .sevenActiveDays : nil
        guard let milestone else { return nil }
        let asked = Set((defaults.stringArray(forKey: "reviewPromptMilestones") ?? []).compactMap(ReviewMilestone.init))
        let sessions = (try? container.mainContext.fetchCount(FetchDescriptor<WorkoutRecord>())) ?? 0
        let startOfDay = calendar.startOfDay(for: now())
        let painToday = !painRecorder.snapshots(since: startOfDay).isEmpty
        let records = (try? container.mainContext.fetch(FetchDescriptor<WorkoutRecord>(predicate: #Predicate { $0.date >= startOfDay }))) ?? []
        let tooHard = records.contains { $0.feeling == Feeling.tooHard.rawValue }
        guard ReviewPromptPolicy.shouldAsk(milestone: milestone, history: ReviewPromptHistory(askedMilestones: asked, completedSessions: sessions),
                                           today: ReviewPromptDay(reportedPain: painToday, saidTooHard: tooHard)) else { return nil }
        return milestone
    }

    func markReviewAsked(_ milestone: ReviewMilestone) {
        var asked = defaults.stringArray(forKey: "reviewPromptMilestones") ?? []
        asked.append(milestone.rawValue)
        defaults.set(asked, forKey: "reviewPromptMilestones")
    }

    // MARK: Settings

    func answerFewerReminders(_ fewer: Bool) {
        defaults.set(true, forKey: "fewerRemindersAnswered")
        if fewer { updateProfile { $0.reminderFrequency = ReminderFrequency.quietDays.rawValue } }
        reload()
    }

    func dismissHealthCard() {
        defaults.set(true, forKey: "healthCardDismissed")
        reload()
    }

    func updateProfile(_ change: (UserProfile) -> Void) {
        guard let stored = (try? container.mainContext.fetch(FetchDescriptor<UserProfile>()))?.first else { return }
        change(stored)
        try? container.mainContext.save()
        reload()
        Task { await notifications.reschedule() }
    }

    func eraseAllData() {
        // In-memory settings first (their setters write defaults), then everything is removed.
        textSize = TextSizeOverride(step: 0)
        appearance = .auto
        units = UnitPreferences.regionDefault()
        notificationSettings = NotificationSettings()
        try? DataEraser(context: container.mainContext, defaults: defaults, notifications: notifications).eraseAll()
        favourites = FavouriteSessions(defaults: defaults)
        onboarding = OnboardingFlow()
        cover = nil
        tab = .today
        reload()
        storeNotice = .dataDeleted
    }

    func chooseJourney(_ journeyID: String) {
        let context = container.mainContext
        let states = (try? context.fetch(FetchDescriptor<JourneyState>())) ?? []
        states.forEach { $0.isCurrent = false }
        if let existing = states.first(where: { $0.journeyID == journeyID }) {
            existing.isCurrent = true
        } else {
            context.insert(JourneyState(journeyID: journeyID, isCurrent: true, startedAt: now()))
        }
        try? context.save()
        reload()
    }
}

// MARK: Deep links from notifications (task 6.12)

extension AppModel: DeepLinkTarget {
    /// "Start walk" on a reminder. Never while a session is getting ready or running: that would
    /// throw it away unsaved (review I5).
    func openTodaySession() {
        switch cover {
        case .preparing?, .workout?: return
        default: break
        }
        tab = .today
        afterOneTimeScreens { [self] in
            if let today, let request = today.request { startFromToday(request, checkIn: today.checkedIn) }
        }
    }

    /// Today's Start: the preview, except the First Walk, which has its own "Up next" (it is set,
    /// with nothing to choose).
    func startFromToday(_ request: WorkoutRequest, checkIn: CheckIn?) {
        if request.isFirstWalk { begin(request) } else { preview(request, checkIn: checkIn) }
    }

    func markRestToday() {
        // The notification delegate wrote the day she tapped (the app may open on a later day).
        reload()
        Task { await notifications.reschedule() }
    }

    func openJourney() {
        tab = .journey
        journeyPath = []
    }

    func openToday() { tab = .today }
}
