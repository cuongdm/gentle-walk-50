import AVFoundation
import Observation
import GentleWalkCore

/// The audio session as the coach preview uses it, so a test can watch it turn on and off.
@MainActor protocol PreviewAudioSession: AnyObject {
    func activate() throws
    func deactivate()
}

/// The real shared session: spoken audio while the preview plays, released at once afterwards.
@MainActor final class SystemPreviewAudioSession: PreviewAudioSession {
    func activate() throws { try AudioSessionConfigurator.apply(.guided) }
    func deactivate() { AudioSessionConfigurator.deactivate() }
}

/// "Hear your coach · 10 seconds" on Your plan (plan 08/10/2026 task 2.11, D3): the first two lines of
/// her first walk (`a1.01`, `a1.02`), the real recordings in her language through the normal path
/// (`VoiceSource` → `SessionAudioComposer` → one `AVPlayer`). Voice only: no bells, no music, nothing
/// silent, no background audio (2.3.1, 2.5.4). It stops when she taps Stop, when it ends, and when the
/// screen goes away.
@Observable @MainActor final class CoachPreviewPlayer {
    enum State: Equatable { case idle, loading, playing, finished }

    /// The opening lines of the First Walk (`ses.firstWalk`).
    static let lineIDs = SessionTimeline.coachPreviewLineIDs

    private(set) var state: State = .idle
    private let voiceSource: VoiceSource
    private let lines: [VoiceLine]
    private let audioSession: PreviewAudioSession
    private var player: AVPlayer?
    private var task: Task<Void, Never>?
    private var endObserver: NSObjectProtocol?

    init(voiceSource: VoiceSource, lines: [VoiceLine], audioSession: PreviewAudioSession = SystemPreviewAudioSession()) {
        self.voiceSource = voiceSource
        self.lines = lines
        self.audioSession = audioSession
    }

    /// Play, or Stop while playing.
    func toggle() {
        switch state {
        case .idle, .finished: play()
        case .loading, .playing: stop()
        }
    }

    func play() {
        stop()
        state = .loading
        task = Task { [weak self] in
            guard let self, let composition = try? await self.composition(), !Task.isCancelled else {
                if let self, !Task.isCancelled { self.state = .idle }
                return
            }
            try? self.audioSession.activate()
            let item = AVPlayerItem(asset: composition)
            let player = AVPlayer(playerItem: item)
            self.endObserver = NotificationCenter.default.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification,
                                                                      object: item, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.finish() }
            }
            self.player = player
            self.state = .playing
            player.play()
        }
    }

    /// Stops the sound and gives the audio session back.
    func stop() {
        task?.cancel()
        task = nil
        let wasActive = player != nil || state == .playing
        tearDown()
        if wasActive { audioSession.deactivate() }
        if state != .finished { state = .idle }
    }

    private func finish() {
        tearDown()
        audioSession.deactivate()
        state = .finished
    }

    private func tearDown() {
        player?.pause()
        player = nil
        if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
        endObserver = nil
    }

    /// The two lines, one after the other, as one voice-only program.
    func composition() async throws -> AVMutableComposition {
        var urls: [String: URL] = [:]
        for id in Self.lineIDs {
            switch await voiceSource.resolve(id) {
            case .bundled(let url), .synthesized(let url): urls[id] = url
            case .missing: break
            }
        }
        let timeline = SessionTimeline.coachPreview(voice: lines)
        return try await SessionAudioComposer.compose(timeline: timeline, voiceURL: urls, bellURL: nil, musicURL: nil).0
    }
}
