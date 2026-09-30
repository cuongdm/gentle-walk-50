import AVFoundation
import Foundation
import Observation
import OSLog
import GentleWalkCore

enum PauseReason: Equatable, Sendable {
    /// Pause control or the lock-screen button.
    case user
    /// Break (S14).
    case breakTaken
    /// Phone call, Siri or another app took the audio. Never resumes on its own.
    case interrupted
    /// Waiting on "Stand behind your chair" before a standing move.
    case getReady
    /// This hurts screen is open.
    case hurts
}

enum PlaybackState: Equatable, Sendable { case idle, ready, playing, paused(PauseReason), finished }

/// Drives one session (task 3.4): the engine plays audio, this model turns the clock into the phase,
/// caption and countdown the player screens show.
@Observable @MainActor final class SessionPlayer {
    private(set) var state: PlaybackState = .idle
    private(set) var timeline = SessionTimeline()
    private(set) var currentTime = 0.0
    private(set) var currentPhase: SessionTimeline.Phase?
    private(set) var phaseIndex = 0
    private(set) var caption: CaptionTimeline.Caption?
    /// Whole seconds left in the current phase, for the big countdown.
    private(set) var remainingInPhase = 0

    /// Called on every phase change after the first (haptics, transition card).
    @ObservationIgnored var onPhaseChange: ((SessionTimeline.Phase) -> Void)?
    /// Lock-screen info and controls; set by the screen that owns the session.
    @ObservationIgnored var nowPlaying: NowPlayingController?

    @ObservationIgnored private let engine: PlaybackEngine
    @ObservationIgnored private var captions = CaptionTimeline(timeline: SessionTimeline())
    @ObservationIgnored private let cleanup = DeinitCleanup()
    @ObservationIgnored private let notificationCenter: NotificationCenter
    @ObservationIgnored private var lastLoggedLine: String?
    static let log = Logger(subsystem: "com.kmd.gentlewalk", category: "cue")

    init(engine: PlaybackEngine, notificationCenter: NotificationCenter = .default) {
        self.engine = engine
        self.notificationCenter = notificationCenter
        engine.onTime = { [weak self] seconds in self?.tick(seconds) }
        engine.onEnd = { [weak self] in self?.programEnded() }
        let observer = notificationCenter.addObserver(forName: AVAudioSession.interruptionNotification, object: nil,
                                                              queue: .main) { [weak self] note in
            let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt
            MainActor.assumeIsolated { self?.handleInterruption(raw.flatMap(AVAudioSession.InterruptionType.init)) }
        }
        nonisolated(unsafe) let token = observer
        cleanup.add { [notificationCenter] in notificationCenter.removeObserver(token) }
    }

    func load(_ timeline: SessionTimeline) async throws {
        try await engine.load(timeline)
        self.timeline = timeline
        captions = CaptionTimeline(timeline: timeline)
        state = .ready
        tick(0)
    }

    func play() {
        guard state == .ready else { return resume() }
        engine.play()
        state = .playing
        nowPlaying?.update(elapsed: currentTime, duration: timeline.total, isPlaying: true)
    }

    func pause(_ reason: PauseReason) {
        guard state == .playing else { return }
        engine.pause()
        state = .paused(reason)
        nowPlaying?.update(elapsed: currentTime, duration: timeline.total, isPlaying: false)
    }

    /// Resumes after any pause. An interruption waits for this: nothing restarts by itself.
    func resume() {
        guard case .paused = state else { return }
        engine.play()
        state = .playing
        nowPlaying?.update(elapsed: currentTime, duration: timeline.total, isPlaying: true)
    }

    /// This hurts / Skip / Walk home gently: rebuilds the program and continues from the same moment.
    func apply(_ edit: TimelineEdit) async throws {
        let at = currentTime
        let wasPlaying = state == .playing
        let edited = TimelineEditing.apply(edit, to: timeline, at: at)
        try await engine.load(edited)
        timeline = edited
        captions = CaptionTimeline(timeline: edited)
        engine.seek(to: at)
        if wasPlaying { engine.play() }
        tick(at)
    }

    private(set) var isVoiceOn = true
    private(set) var isMusicOn = true

    func setMusicOn(_ on: Bool) {
        isMusicOn = on
        engine.setMusicOn(on)
    }

    func setVoiceOn(_ on: Bool) {
        isVoiceOn = on
        engine.setVoiceOn(on)
    }

    /// Coach voice and music volumes from the Sound sheet.
    func setLevels(voice: Double, music: Double) {
        engine.setLevels(voice: Float(voice), music: Float(music))
    }

    /// Back / Skip controls: jumps to a moment in the program.
    func seek(to seconds: Double) {
        engine.seek(to: seconds)
        tick(seconds)
    }

    /// End workout: stops audio; the caller saves what was done.
    func end() {
        engine.pause()
        state = .finished
        nowPlaying?.clear()
    }

    func tick(_ seconds: Double) {
        currentTime = seconds
        let index = timeline.phases.lastIndex { $0.start <= seconds } ?? 0
        let phase = timeline.phases.indices.contains(index) ? timeline.phases[index] : nil
        if index != phaseIndex || phase != currentPhase {
            let changed = index != phaseIndex
            phaseIndex = index
            currentPhase = phase
            if changed, let phase {
                Self.log.info("phase \(String(describing: phase.kind), privacy: .public) at \(seconds, format: .fixed(precision: 1))")
                onPhaseChange?(phase)
            }
        }
        let newCaption = captions.caption(at: seconds)
        if newCaption != caption { caption = newCaption }
        if let line = newCaption?.lineID, line != lastLoggedLine {
            lastLoggedLine = line
            Self.log.info("cue \(line, privacy: .public) at \(seconds, format: .fixed(precision: 1))")
        }
        let remaining = phase.map { max(0, Int(($0.end - seconds).rounded(.up))) } ?? 0
        if remaining != remainingInPhase { remainingInPhase = remaining }
        if !timeline.isOpenEnded, timeline.total > 0, seconds >= timeline.total - 0.05, state == .playing { finish() }
    }

    /// The audio program ran out. An open-ended walk (Walk home gently) keeps going until End.
    private func programEnded() {
        guard !timeline.isOpenEnded else { return }
        finish()
    }

    private func finish() {
        guard state != .finished else { return }
        engine.pause()
        state = .finished
        nowPlaying?.clear()
        Self.log.info("finished at \(self.currentTime, format: .fixed(precision: 1))")
    }

    private func handleInterruption(_ type: AVAudioSession.InterruptionType?) {
        // Began: pause and wait. Ended: stay paused; the screen shows Resume.
        if type == .began { pause(.interrupted) }
    }
}
