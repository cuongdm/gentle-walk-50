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

/// Which way the last part change went: on to a later part (playing on, Skip) or back (Back).
/// The exercise clip slides in from the matching side.
enum MoveDirection: Equatable, Sendable { case forward, backward }

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
    private(set) var moveDirection: MoveDirection = .forward

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
        engine.onTime = { [weak self] seconds in self?.mediaTick(seconds) }
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
        cuts = []
        timeFloor = nil
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

    /// Skip control and "Skip rest": drops the rest of the current part and goes straight on, with no
    /// rebuild of the audio program. The program keeps playing the media built at load; the player
    /// remembers each cut (a media interval that is no longer part of the program) and maps between
    /// program time and media time. A tap is one seek, so taps never queue or race, and the screen,
    /// the voice and the clip all move at the same instant. The coach does not announce it (she did
    /// for every tap, which piled up when tapped quickly); the sound is a short tick.
    func skip() {
        let at = currentTime
        guard let phase = timeline.phases.first(where: { $0.start <= at && at < $0.end }) else { return }
        let start = mediaTime(at)
        cuts.append(Cut(start: start, end: start + (phase.end - at)))
        cuts.sort { $0.start < $1.start }
        timeline = TimelineEditing.apply(.skip(spoken: false), to: timeline, at: at)
        captions = CaptionTimeline(timeline: timeline)
        moveDirection = .forward
        seekMedia(to: mediaTime(at))
        tick(at)
        onSkip?()
    }

    /// The Skip control's tick (set by the screen; nil in tests).
    @ObservationIgnored var onSkip: (() -> Void)?

    /// This hurts (easier version, Skip) / Walk home gently: rebuilds the program and continues from
    /// the same moment. Used from the This hurts screen, where the session is paused, so the rebuild
    /// is not heard. A second edit during a rebuild is ignored (two rebuilds raced and replayed audio).
    func apply(_ edit: TimelineEdit) async throws {
        guard !isEditing else { return }
        isEditing = true
        defer { isEditing = false }
        let at = currentTime
        let wasPlaying = state == .playing
        let edited = TimelineEditing.apply(edit, to: timeline, at: at)
        timeline = edited
        captions = CaptionTimeline(timeline: edited)
        tick(at)
        if wasPlaying { engine.pause() }
        try await engine.load(edited)
        // The new media is the edited program itself: no cuts any more.
        cuts = []
        seekMedia(to: at)
        if wasPlaying && state == .playing { engine.play() }
        tick(at)
    }

    /// True while a This hurts rebuild is loading.
    private(set) var isEditing = false

    // MARK: Program time vs. media time

    /// A media interval dropped by Skip: the program jumps from `start` to `end`.
    private struct Cut { var start: Double; var end: Double; var length: Double { end - start } }
    @ObservationIgnored private var cuts: [Cut] = []
    /// After a seek, media times reported below the target are read as the target: the player lands a
    /// sample or two early, which read as the last moment of the part just left (seen as "00:01" of the
    /// skipped move flashing back). Cleared once the media is past it.
    @ObservationIgnored private var timeFloor: Double?

    private func mediaTime(_ program: Double) -> Double {
        var media = program
        for cut in cuts where cut.start <= media { media += cut.length }
        return media
    }

    private func programTime(_ media: Double) -> Double {
        var program = media
        for cut in cuts where cut.end <= media { program -= cut.length }
        return program
    }

    private func seekMedia(to media: Double) {
        timeFloor = media
        engine.seek(to: media)
    }

    /// The engine's clock (media time) → program time, skipping over cuts.
    private func mediaTick(_ media: Double) {
        var media = media
        if let floor = timeFloor {
            if media < floor { media = floor } else if media > floor + 0.3 { timeFloor = nil }
        }
        // Back played into skipped media: jump over it, and over any cut right after it (Skip tapped
        // several times leaves cuts end to end).
        var jumped = false
        while let cut = cuts.first(where: { $0.start <= media && media < $0.end }) {
            media = cut.end
            jumped = true
        }
        if jumped { seekMedia(to: media) }
        tick(programTime(media))
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

    /// Back control: jumps to a moment in the program.
    func seek(to seconds: Double) {
        moveDirection = seconds < currentTime ? .backward : .forward
        seekMedia(to: mediaTime(seconds))
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
            if changed, index > phaseIndex { moveDirection = .forward }
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
