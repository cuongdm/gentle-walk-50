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
        cover = .paywall(.onboarding)
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
        guard (try? await store.purchase(option.id)) == .purchased else { return }
        reload()
        await notifications.reschedule()
        if option.kind == .lifetime, store.activeRenewingProductID != nil {
            cover = .cancelGuide(afterLifetime: true)
        } else {
            afterPaywall(trigger)
        }
    }

    func restorePurchases() async {
        try? await store.restore()
        reload()
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
        let model = WorkoutPreviewModel(day: request.day, intensity: request.intensity, checkIn: checkIn,
                                        suggestedLevel: request.level, limits: request.limits, rotationIndex: request.rotationIndex,
                                        minutesDelta: request.minutesDelta, content: content, defaults: defaults)
        cover = .preview(model)
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
        guard let plan = try? request.plan(content: content) else { cover = nil; return }
        let media = await SessionMedia.prepare(plan: plan, content: content, voiceSource: voiceSource)
        let musicURL = music.defaultStyle?.files.first.flatMap { Bundle.main.url(forResource: $0, withExtension: nil) }
        guard let engine = media.makeEngine(musicURL: defaults.bool(forKey: "musicOff") ? nil : musicURL) else { cover = nil; return }
        let session = WorkoutSessionModel(request: request, content: content, engine: engine, completion: completion,
                                          painRecorder: painRecorder, now: now)
        if request.place == .outdoors { attachOutdoor(to: session) }
        if request.day.main == .chair || request.day.chairMoves > 0 { attachMotion(to: session) }
        try? await session.load(timeline: media.timeline)
        let context: AudioContext = request.place == .outdoors && AVAudioSession.sharedInstance().isOtherAudioPlaying
            ? .overUserAudio : .guided
        try? AudioSessionConfigurator.apply(context)
        session.player.nowPlaying = NowPlayingController(
            title: request.title, onPlay: { [weak session] in session?.player.resume() },
            onPause: { [weak session] in session?.player.pause(.user) })
        session.play()
        cover = .workout(session)
    }

    private func attachOutdoor(to session: WorkoutSessionModel) {
        let start = now()
        if usesLocationOutdoors, location.isAuthorized {
            location.startWalk(at: start)
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
        try? DataEraser(context: container.mainContext, defaults: defaults, notifications: notifications).eraseAll()
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
    func openTodaySession() {
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
