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
            cover = nil
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
        preview(request, checkIn: today?.checkedIn)
    }

    /// Starts a session, showing phone placement or outdoor prep the first time.
    func begin(_ request: WorkoutRequest) {
        if request.place != .outdoors, !defaults.bool(forKey: PhonePlacement.seenKey) {
            cover = .phonePlacement(request)
        } else if request.place == .outdoors, !defaults.bool(forKey: "outdoorPrepSeen") {
            cover = .outdoorPrep(request)
        } else {
            cover = .preparing(request)
            Task { await prepareAndPlay(request) }
        }
    }

    func placementDone(_ request: WorkoutRequest) {
        defaults.set(true, forKey: PhonePlacement.seenKey)
        begin(request)
    }

    func outdoorPrepDone(_ request: WorkoutRequest, useLocation: Bool?) {
        defaults.set(true, forKey: "outdoorPrepSeen")
        if let useLocation { defaults.set(useLocation ? "location" : "steps", forKey: "outdoorLocationChoice") }
        begin(request)
    }

    var usesLocationOutdoors: Bool { defaults.string(forKey: "outdoorLocationChoice") == "location" }

    private func prepareAndPlay(_ request: WorkoutRequest) async {
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
        if request.place == .outdoors { attachOutdoor(to: session) }
        if request.day.main == .chair || request.day.chairMoves > 0 { attachMotion(to: session) }
        do {
            try await session.load(timeline: media.timeline)
        } catch {
            // The audio could not be built: back to where she was, with a plain word (review I7).
            cover = nil
            storeNotice = .sessionFailed
            return
        }
        if defaults.bool(forKey: "musicOff") { session.player.setMusicOn(false) }
        session.player.setLevels(voice: levels.voice, music: levels.music)
        let context: AudioContext = request.place == .outdoors && AVAudioSession.sharedInstance().isOtherAudioPlaying
            ? .overUserAudio : .guided
        try? AudioSessionConfigurator.apply(context)
        session.player.nowPlaying = NowPlayingController(
            title: request.title, onPlay: { [weak session] in session?.player.resume() },
            onPause: { [weak session] in session?.player.pause(.user) })
        // "Get ready" 3-2-1 first, like a class starting: time to set the phone down.
        session.startWithCountdown()
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
        session.motion = motion
    }

    func workoutClosed(_ result: CompletionResult?) {
        AudioSessionConfigurator.deactivate()
        reload()
        if result?.isFirstWorkout == true, !defaults.bool(forKey: "permissionsShown") {
            defaults.set(true, forKey: "permissionsShown")
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
        notificationSettings = NotificationSettings()
        try? DataEraser(context: container.mainContext, defaults: defaults, notifications: notifications).eraseAll()
        favourites = FavouriteSessions(defaults: defaults)
        onboarding = OnboardingFlow()
        cover = nil
        tab = .today
        reload()
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
        if let today, let request = today.request { preview(request, checkIn: today.checkedIn) }
    }

    func markRestToday() {
        defaults.set(now(), forKey: "restTodayDate")
        Task { await notifications.reschedule() }
    }

    func openJourney() {
        tab = .journey
        journeyPath = []
    }

    func openToday() { tab = .today }
}
