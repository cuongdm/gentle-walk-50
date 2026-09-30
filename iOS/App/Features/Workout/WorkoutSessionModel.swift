import Foundation
import Observation
import GentleWalkCore

/// Runs one workout from start to the Complete screen: prepares audio, owns the `SessionPlayer`,
/// counts Breaks, shows safety screens and hands the summary to `SessionCompletionService`.
@Observable @MainActor final class WorkoutSessionModel {
    enum Stage: Equatable {
        case preparing
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
    /// Called once when the session ends (stops location and pedometer).
    @ObservationIgnored var onEnded: (() -> Void)?
    /// Sit-to-stand counting when the phone is held to the chest (task 8.9).
    var motion: MotionService?
    /// Route kept for Complete after the outdoor services stop.
    private(set) var route: [RoutePoint] = []

    @ObservationIgnored let content: ContentBundle
    @ObservationIgnored private let painRecorder: PainReportRecording?
    @ObservationIgnored private let completion: SessionCompletionService?
    @ObservationIgnored private let prepareMedia: Bool
    @ObservationIgnored private var confirmedStanding: Set<String> = []
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
        walkModel = WalkPlayerModel(player: player, level: request.level)
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

    /// Shows the 3-2-1 first; `countdownFinished()` starts the session.
    func startWithCountdown() { stage = .countdown }

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
        player.pause(.breakTaken)
        stage = .breakTime(startedAt: now())
    }

    func endBreak() {
        stage = .playing
        player.resume()
    }

    func openHurts() {
        player.pause(.hurts)
        if let painRecorder { hurtsModel = ThisHurtsModel(player: player, recorder: painRecorder, now: now) }
        stage = .hurts
    }

    func closeHurts(_ outcome: HurtOutcome) async {
        hurtsModel = nil
        switch outcome {
        case .continueSession:
            stage = .playing
            player.resume()
        case .endSession(let counts):
            await finish(counts: counts)
        }
    }

    func askToEnd() {
        player.pause(.user)
        stage = .confirmEnd
    }

    func keepGoing() {
        stage = .playing
        player.resume()
    }

    func confirmStanding() {
        guard case .standBehindChair(let id) = stage else { return }
        confirmedStanding.insert(id)
        stage = .playing
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

    /// - Parameter counts: true when the session must be saved however short (stopping for pain).
    func finish(counts: Bool = false) async {
        guard stage != .saving, !isComplete else { return }
        player.end()
        stage = .saving
        motion?.stop()
        let total = player.timeline.isOpenEnded ? player.currentTime : player.timeline.total
        secondsDone = Int(min(player.currentTime, total).rounded())
        if !counts, secondsDone < Self.minimumSeconds {
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
        stage = .complete(result)
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
        if phase.block == .walk, [.brisk, .easy, .cooldown].contains(phase.kind) {
            PhaseSignal.play()
            let model = WalkPlayerModel(player: player, level: request.level)
            showTransition(PhaseTransition(label: model.phaseLabel, tone: model.tone))
        }
        if let id = phase.exerciseID, let exercise = exercisesByID[id], exercise.standing,
           !confirmedStanding.contains(id), phase.kind == .move || phase.kind == .stretch, !phase.isEasier {
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
    #endif
}
