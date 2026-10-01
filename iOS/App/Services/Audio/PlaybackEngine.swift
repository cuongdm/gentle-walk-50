import AVFoundation
import GentleWalkCore

/// Plays a session timeline. `SessionPlayer` talks to this protocol so tests can drive the clock.
@MainActor protocol PlaybackEngine: AnyObject {
    /// Called about four times a second with the program time in seconds.
    var onTime: ((Double) -> Void)? { get set }
    var onEnd: (() -> Void)? { get set }
    func load(_ timeline: SessionTimeline) async throws
    func play()
    func pause()
    func seek(to seconds: Double)
    /// Voice button: mutes or restores the coach; bells and music keep playing.
    func setVoiceOn(_ on: Bool)
    /// Music button: mutes or restores the music track (voice and bells keep playing).
    func setMusicOn(_ on: Bool)
    /// Sound sheet: coach voice and music volumes, 0...1 (applied live).
    func setLevels(voice: Float, music: Float)
}

extension PlaybackEngine {
    func setLevels(voice: Float, music: Float) {}
}

/// The real engine: one composition per timeline (`SessionAudioComposer`), played by one `AVPlayer`.
@MainActor final class AVPlaybackEngine: PlaybackEngine {
    var onTime: ((Double) -> Void)?
    var onEnd: (() -> Void)?

    /// Extra program length after "Walk home gently": the walk lasts until the user taps End.
    static let openEndedPadding = 3600.0

    private let player = AVPlayer()
    private let voiceURLs: [String: URL]
    private let bellURL: URL
    private let doneBellURL: URL?
    private let musicURL: URL?
    private var endObserver: NSObjectProtocol?
    private let cleanup = DeinitCleanup()
    private var voiceOn = true
    private var musicParameters: [AVAudioMixInputParameters] = []
    private var voiceTrackID: CMPersistentTrackID?
    private var musicTrackID: CMPersistentTrackID?
    private var musicOn = true
    /// Music volume under the coach's voice ("Voice louder than music" in Me).
    private let duckedVolume: Float
    /// Sound sheet levels, 0...1.
    private var voiceLevel: Float = 1
    private var musicLevel: Float = 1
    /// When the coach speaks: the music dips in these windows.
    private var speechWindows: [(start: Double, end: Double)] = []

    init(voiceURLs: [String: URL], bellURL: URL, doneBellURL: URL?, musicURL: URL?,
         duckedVolume: Float = SessionAudioComposer.duckedVolume) {
        self.voiceURLs = voiceURLs
        self.bellURL = bellURL
        self.doneBellURL = doneBellURL
        self.musicURL = musicURL
        self.duckedVolume = duckedVolume
        player.automaticallyWaitsToMinimizeStalling = false
        let token = player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 4), queue: .main) { [weak self] time in
            MainActor.assumeIsolated {
                // While a new item loads or seeks, its clock reads 0 or a stale time: don't move the screen.
                guard let self, self.isReady, self.pendingSeek == nil, !self.isSeeking else { return }
                self.onTime?(time.seconds)
            }
        }
        let player = player
        nonisolated(unsafe) let unsafeToken = token
        cleanup.add { player.removeTimeObserver(unsafeToken) }
    }

    func load(_ timeline: SessionTimeline) async throws {
        let length = timeline.isOpenEnded ? timeline.total + Self.openEndedPadding : timeline.total
        let (composition, mix) = try await SessionAudioComposer.compose(
            timeline: timeline, voiceURL: voiceURLs, bellURL: bellURL, doneBellURL: doneBellURL,
            musicURL: musicURL, length: length, duckedVolume: duckedVolume)
        let item = AVPlayerItem(asset: composition)
        musicParameters = mix.inputParameters
        speechWindows = timeline.voice.filter { voiceURLs[$0.lineID] != nil }.map { ($0.start, $0.end) }
        let tracks = composition.tracks(withMediaType: .audio)
        voiceTrackID = tracks.first?.trackID
        musicTrackID = tracks.count > 2 ? tracks[2].trackID : nil
        item.audioMix = currentMix()
        if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
        endObserver = NotificationCenter.default.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification, object: item,
                                                             queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.onEnd?() }
        }
        if let endObserver {
            nonisolated(unsafe) let observer = endObserver
            cleanup.add { NotificationCenter.default.removeObserver(observer) }
        }
        isReady = false
        readyObserver = item.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
            guard item.status == .readyToPlay else { return }
            Task { @MainActor in self?.itemBecameReady() }
        }
        player.replaceCurrentItem(with: item)
    }

    /// A new item is not ready right after `replaceCurrentItem`: a seek sent then can be dropped and the
    /// program would restart from 0 (heard as the coach repeating herself after Skip). Seek and play wait.
    private var isReady = false
    private var readyObserver: NSKeyValueObservation?
    private var pendingSeek: Double?
    private var pendingPlay = false
    private var isSeeking = false

    private func itemBecameReady() {
        guard !isReady else { return }
        isReady = true
        if let seconds = pendingSeek {
            pendingSeek = nil
            isSeeking = true
            player.seek(to: CMTime(seconds: seconds, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
                Task { @MainActor in
                    guard let self else { return }
                    self.isSeeking = false
                    guard self.pendingPlay else { return }
                    self.pendingPlay = false
                    self.player.play()
                }
            }
        } else if pendingPlay {
            pendingPlay = false
            player.play()
        }
    }

    func setVoiceOn(_ on: Bool) {
        voiceOn = on
        player.currentItem?.audioMix = currentMix()
    }

    func setMusicOn(_ on: Bool) {
        musicOn = on
        player.currentItem?.audioMix = currentMix()
    }

    func setLevels(voice: Float, music: Float) {
        voiceLevel = voice
        musicLevel = music
        player.currentItem?.audioMix = currentMix()
    }

    /// Music ducking under the voice at the chosen music level, plus the voice and music switches.
    private func currentMix() -> AVAudioMix {
        let mix = AVMutableAudioMix()
        var parameters: [AVAudioMixInputParameters] = []
        if let musicTrackID {
            let music = AVMutableAudioMixInputParameters()
            music.trackID = musicTrackID
            let level = musicOn ? musicLevel : 0
            music.setVolume(level, at: .zero)
            for window in speechWindows where level > 0 {
                music.setVolume(level * duckedVolume, at: SessionAudioComposer.time(window.start))
                music.setVolume(level, at: SessionAudioComposer.time(window.end))
            }
            parameters.append(music)
        } else {
            parameters = musicParameters
        }
        if let voiceTrackID {
            let voice = AVMutableAudioMixInputParameters()
            voice.trackID = voiceTrackID
            voice.setVolume(voiceOn ? voiceLevel : 0, at: .zero)
            parameters.append(voice)
        }
        mix.inputParameters = parameters
        return mix
    }

    func play() {
        guard isReady, pendingSeek == nil else { pendingPlay = true; return }
        player.play()
    }

    func pause() {
        pendingPlay = false
        player.pause()
    }

    func seek(to seconds: Double) {
        guard isReady else { pendingSeek = seconds; return }
        player.seek(to: CMTime(seconds: seconds, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero)
    }
}
