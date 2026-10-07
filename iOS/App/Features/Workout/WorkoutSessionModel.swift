import Foundation
import Observation
import GentleWalkCore

/// Runs one workout from start to the Complete screen: prepares audio, owns the `SessionPlayer`,
/// counts Breaks, shows safety screens and hands the summary to `SessionCompletionService`.
@Observable @MainActor final class WorkoutSessionModel {
    enum Stage: Equatable {
        case preparing
        /// "Up next": what the session is and what to have ready, until she taps "I'm ready".
        /// Only when no preview came first (owner 01/10/2026: Continue on phone placement went
        /// straight into the count).
        case ready
        /// "Get ready" 3-2-1 before the first word (nothing plays yet).
        case countdown
        case playing
        case standBehindChair(exerciseID: String)
        case breakTime(startedAt: Date)
        case hurts
        case confirmEnd
        case saving
        case complete(CompletionResult)
        /// Ended in under a minute: nothing saved (owner 30/09/2026).
        case notSaved
    }

    let request: WorkoutRequest
    let player: SessionPlayer
    private(set) var stage: Stage = .preparing
    private(set) var breakCount = 0
    private(set) var sitToStandCount = 0
    private(set) var holdSeconds = 20
    /// Phase-change card (walk only), shown briefly.
    private(set) var transition: PhaseTransition?
    private(set) var easierExerciseIDs: Set<String> = []
    private(set) var feelingSaved = false
    /// Ended from This hurts → Stop for today (Complete stays calm).
    private(set) var stoppedForPain = false

    struct PhaseTransition: Equatable {
        var label: String
        var tone: PhaseTone
    }

    /// Open while the This hurts screen shows.
    private(set) var hurtsModel: ThisHurtsModel?
    /// Seconds of session time done when it ended.
    private(set) var secondsDone = 0

    @ObservationIgnored private(set) var walkModel: WalkPlayerModel!
    @ObservationIgnored private(set) var chairModel: ChairPlayerModel!
    @ObservationIgnored private(set) var stretchModel: StretchPlayerModel!

    /// Outdoors: miles from GPS or steps, read when the session ends.
    @ObservationIgnored var outdoorDistance: (() -> Double?)?
    /// Outdoors: the route for the Complete map (never shared).
    @ObservationIgnored var routeProvider: (() -> [RoutePoint])?
    /// Outdoors: whether GPS has a fix ("Location on").
    @ObservationIgnored var locationOn: (() -> Bool)?
    /// Steps so far on an outdoor walk; nil when steps are not counted (Motion not allowed).
    @ObservationIgnored var outdoorSteps: (() -> Int?)?
    /// Outdoors with GPS: the player shows the live map (otherwise steps are counted).
    @ObservationIgnored var tracksRoute = false
    /// Called once when the session ends (stops location and pedometer).
    @ObservationIgnored var onEnded: (() -> Void)?
    /// Called when a saved session ends: balance exercises held through, and those with This hurts or a
    /// Break (the support ladder, Pro).
    @ObservationIgnored var onBalanceResult: ((_ steady: Set<String>, _ troubled: Set<String>) -> Void)?
    /// Balance exercises where she tapped This hurts or took a Break.
    @ObservationIgnored private var troubledExercises: Set<String> = []
    /// Sit-to-stand counting when the phone is held to the chest (task 8.9).
    var motion: MotionService?
    /// Route kept for Complete after the outdoor services stop.
    private(set) var route: [RoutePoint] = []

    @ObservationIgnored let content: ContentBundle
    @ObservationIgnored private let painRecorder: PainReportRecording?
    @ObservationIgnored private let completion: SessionCompletionService?
    @ObservationIgnored private let prepareMedia: Bool
    /// Parts of the session (chair moves, stretch) where she has confirmed standing behind the chair.
    @ObservationIgnored private var confirmedStanding: Set<SessionPlan.Block.Kind> = []
    @ObservationIgnored private var lastWalkKind: SessionTemplate.Segment.Kind?
    @ObservationIgnored private var transitionTask: Task<Void, Never>?
    @ObservationIgnored private let now: () -> Date

    /// - Parameters:
    ///   - engine: `AVPlaybackEngine` in the app; a silent engine for screenshots and tests.
    ///   - prepareMedia: resolve voice files and measure them (off for screenshots).
    init(request: WorkoutRequest, content: ContentBundle, engine: PlaybackEngine, completion: SessionCompletionService?,
         painRecorder: PainReportRecording? = nil, prepareMedia: Bool = true, now: @escaping () -> Date = Date.init) {
        self.request = request
        self.content = content
        self.completion = completion
        self.painRecorder = painRecorder
        self.prepareMedia = prepareMedia
        self.now = now
        player = SessionPlayer(engine: engine)
        player.onPhaseChange = { [weak self] phase in self?.phaseChanged(to: phase) }
        player.onSkip = { CueSounds.shared.skip() }
        walkModel = WalkPlayerModel(player: player, level: request.level,
                                    exercises: Dictionary(content.exercises.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first }))
        chairModel = ChairPlayerModel(session: self)
        stretchModel = StretchPlayerModel(session: self)
    }

    /// Whole minutes shown on Complete (at least one).
    var minutesDone: Int { max(1, Int((Double(secondsDone) / 60).rounded())) }

    var exercisesByID: [String: Exercise] {
        Dictionary(content.exercises.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    }

    /// Loads the session and starts it. The timeline comes from `SessionMedia` when audio is prepared.
    func load(timeline override: SessionTimeline? = nil) async throws {
        let plan = try request.plan(content: content)
        holdSeconds = plan.holdSeconds ?? 15
        easierExerciseIDs = plan.easierExerciseIDs
        let timeline = override ?? SessionTimeline.make(plan: plan, voice: content.voiceLines)
        try await player.load(timeline)
        stage = .playing
    }

    func play() { player.play() }

    /// Shows "Up next" (when asked) and then the 3-2-1; `countdownFinished()` starts the session.
    func startWithCountdown(showsReady: Bool = false) { stage = showsReady ? .ready : .countdown }

    /// "I'm ready": on to the 3-2-1.
    func readyConfirmed() {
        guard stage == .ready else { return }
        stage = .countdown
    }

    /// End of the count, or "Start now". Only acts while the count shows.
    func countdownFinished() {
        guard stage == .countdown else { return }
        stage = .playing
        player.play()
    }

    // MARK: Controls

    func togglePause() {
        if case .paused = player.state { player.resume() } else { player.pause(.user) }
    }

    func takeBreak() {
        breakCount += 1
        noteTrouble()
        player.pause(.breakTaken)
        stage = .breakTime(startedAt: now())
    }

    func endBreak() {
        stage = .playing
        player.resume()
    }

    func openHurts() {
        noteTrouble()
        player.pause(.hurts)
        if let painRecorder { hurtsModel = ThisHurtsModel(player: player, recorder: painRecorder, now: now) }
        stage = .hurts
    }

    func closeHurts(_ outcome: HurtOutcome) async {
        hurtsModel = nil
        switch outcome {
        case .continueSession:
            // Skipping or easing a move can land on a standing one: its "Stand behind your chair"
            // screen (set while This hurts was open) stays, and waits for her (review 02/10/2026).
            // This hurts never resumes by itself, so nothing plays behind that screen.
            if case .standBehindChair = stage { return }
            stage = .playing
            player.resume()
        case .endSession(let counts):
            stoppedForPain = true
            await finish(counts: counts)
        }
    }

    /// Play from the lock screen, headphones or the car: only on the session itself after her own
    /// pause or a phone call, never behind Break, This hurts, "Stand behind your chair" or the End
    /// question (a car sends Play on connect; review 02/10/2026).
    func remoteResume() {
        guard stage == .playing else { return }
        switch player.state {
        case .paused(.user), .paused(.interrupted): player.resume()
        default: break
        }
    }

    func askToEnd() {
        // From "Stand behind your chair", Keep going comes back to it (not into the standing move).
        if case .standBehindChair = stage { stageBeforeEnd = stage }
        player.pause(.user)
        stage = .confirmEnd
    }

    func keepGoing() {
        if let previous = stageBeforeEnd {
            stageBeforeEnd = nil
            stage = previous
            return
        }
        stage = .playing
        player.resume()
    }

    @ObservationIgnored private var stageBeforeEnd: Stage?

    func confirmStanding() {
        guard case .standBehindChair = stage else { return }
        confirmedStanding.insert(player.currentPhase?.block ?? .chair)
        stage = .playing
        player.resume()
    }

    /// "Skip this move" on "Stand behind your chair": on to the next part. Another standing move
    /// right after it gets its own screen.
    func skipStandingMove() {
        guard case .standBehindChair = stage else { return }
        let before = player.phaseIndex
        stage = .playing
        player.skip()
        // The next part is standing too (a second round of the same stretch): its own screen, set
        // by the phase change. Nothing skipped (a rebuild loading): the same screen stays.
        if case .standBehindChair = stage { return }
        if player.phaseIndex == before, let id = player.currentPhase?.exerciseID {
            stage = .standBehindChair(exerciseID: id)
            return
        }
        player.resume()
    }

    func addRep() { sitToStandCount += 1 }

    /// Reps shown and saved: counted by hand, plus what the sensor counted when it is sure.
    var totalSitToStands: Int { sitToStandCount + ((motion?.confident ?? false) ? (motion?.count ?? 0) : 0) }
    var isCountedForYou: Bool { forceCountedForYou || (motion?.isRunning == true && motion?.confident == true) }
    /// DEBUG screenshots of "Counted for you".
    @ObservationIgnored var forceCountedForYou = false

    /// Ends the session (End, Finish here for today, Stop for today, or the program finished).
    /// Sessions shorter than this are not saved when she ends them herself.
    static let minimumSeconds = 60

    /// The one rule for "saved or not", used by finish() and by the End question.
    static func wouldSave(seconds: Double) -> Bool { Int(seconds.rounded()) >= minimumSeconds }

    /// - Parameter counts: true when the session must be saved however short (stopping for pain).
    func finish(counts: Bool = false) async {
        guard stage != .saving, !isComplete else { return }
        player.end()
        stage = .saving
        motion?.stop()
        let total = player.timeline.isOpenEnded ? player.currentTime : player.timeline.total
        secondsDone = Int(min(player.currentTime, total).rounded())
        if !counts, !Self.wouldSave(seconds: Double(secondsDone)) {
            // Nothing to save: stop the outdoor services and say so kindly.
            route = []
            onEnded?()
            stage = .notSaved
            return
        }
        let outdoorMiles = request.place == .outdoors ? outdoorDistance?() : nil
        route = routeProvider?() ?? []
        onEnded?()
        let reps = totalSitToStands
        let summary = SessionSummary(
            date: now(), kind: request.recordKind, level: request.level, intensity: request.intensity, place: request.place,
            activeSeconds: secondsDone, breakCount: breakCount, outdoorMiles: outdoorMiles, sitToStandCount: reps > 0 ? reps : nil,
            route: route)
        let result = (try? await completion?.complete(summary)) ?? CompletionResult(activeDays: 1, isFirstWorkout: request.isFirstWalk)
        onBalanceResult?(balanceHeldThrough, troubledExercises)
        stage = .complete(result)
    }

    private func noteTrouble() {
        if let id = player.currentPhase?.exerciseID, SupportLadder.exercises.contains(id) { troubledExercises.insert(id) }
    }

    /// Balance exercises whose every part was played, without This hurts or a Break.
    private var balanceHeldThrough: Set<String> {
        let phases = player.timeline.phases.filter { $0.exerciseID.map(SupportLadder.exercises.contains) ?? false }
        let ids = Set(phases.compactMap(\.exerciseID))
        return ids.filter { id in phases.filter { $0.exerciseID == id }.allSatisfy { $0.end <= player.currentTime + 0.5 } }
            .subtracting(troubledExercises)
    }

    /// The saved result once Complete shows.
    var completionResult: CompletionResult? {
        if case .complete(let result) = stage { return result }
        return nil
    }

    /// Shows a finished state directly (screenshots).
    func show(_ result: CompletionResult, seconds: Int) {
        secondsDone = seconds
        stage = .complete(result)
    }

    func recordFeeling(_ feeling: Feeling) {
        guard case .complete(let result) = stage else { return }
        try? completion?.recordFeeling(feeling, for: result.recordID)
        feelingSaved = true
    }

    var isComplete: Bool { if case .complete = stage { true } else { false } }

    // MARK: Phase changes

    private func phaseChanged(to phase: SessionTimeline.Phase) {
        if phase.exerciseID == "mv.sit-to-stand", phase.kind == .move { motion?.start() } else { motion?.stop() }
        // A new pace gets the signal and the card; a new move at the same pace has its bell and line.
        if phase.block == .walk, [.brisk, .easy, .cooldown].contains(phase.kind), phase.kind != lastWalkKind {
            PhaseSignal.play()
            let model = WalkPlayerModel(player: player, level: request.level)
            showTransition(PhaseTransition(label: model.phaseLabel, tone: model.tone))
        }
        if phase.block == .walk { lastWalkKind = phase.kind }
        // Once she stands behind the chair in a part of the session, the next standing moves follow on.
        if let id = phase.exerciseID, let exercise = exercisesByID[id], exercise.standing,
           !confirmedStanding.contains(phase.block), phase.kind == .move || phase.kind == .stretch, !phase.isEasier {
            player.pause(.getReady)
            stage = .standBehindChair(exerciseID: id)
        }
    }

    private func showTransition(_ value: PhaseTransition) {
        transition = value
        transitionTask?.cancel()
        transitionTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(1.6))
            guard !Task.isCancelled else { return }
            self?.transition = nil
        }
    }

    #if DEBUG
    /// Screenshots: freeze on a stage without playing.
    func stage(_ stage: Stage) { self.stage = stage }
    func setTransition(_ value: PhaseTransition?) {
        transitionTask?.cancel()
        transition = value
    }
    func setRoute(_ points: [RoutePoint]) { route = points }
    func markStoppedForPain() { stoppedForPain = true }
    #endif
}
