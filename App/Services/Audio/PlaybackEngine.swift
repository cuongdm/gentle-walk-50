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

    init(voiceURLs: [String: URL], bellURL: URL, doneBellURL: URL?, musicURL: URL?) {
        self.voiceURLs = voiceURLs
        self.bellURL = bellURL
        self.doneBellURL = doneBellURL
        self.musicURL = musicURL
        player.automaticallyWaitsToMinimizeStalling = false
        let token = player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 4), queue: .main) { [weak self] time in
            MainActor.assumeIsolated { self?.onTime?(time.seconds) }
        }
        let player = player
        nonisolated(unsafe) let unsafeToken = token
        cleanup.add { player.removeTimeObserver(unsafeToken) }
    }

    func load(_ timeline: SessionTimeline) async throws {
        let length = timeline.isOpenEnded ? timeline.total + Self.openEndedPadding : timeline.total
        let (composition, mix) = try await SessionAudioComposer.compose(
            timeline: timeline, voiceURL: voiceURLs, bellURL: bellURL, doneBellURL: doneBellURL,
            musicURL: musicURL, length: length)
        let item = AVPlayerItem(asset: composition)
        musicParameters = mix.inputParameters
        voiceTrackID = composition.tracks(withMediaType: .audio).first?.trackID
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
        player.replaceCurrentItem(with: item)
    }

    func setVoiceOn(_ on: Bool) {
        voiceOn = on
        player.currentItem?.audioMix = currentMix()
    }

    /// Music ducking from the composer plus the voice on/off switch.
    private func currentMix() -> AVAudioMix {
        let mix = AVMutableAudioMix()
        var parameters = musicParameters
        if let voiceTrackID {
            let voice = AVMutableAudioMixInputParameters()
            voice.trackID = voiceTrackID
            voice.setVolume(voiceOn ? 1 : 0, at: .zero)
            parameters.append(voice)
        }
        mix.inputParameters = parameters
        return mix
    }

    func play() { player.play() }
    func pause() { player.pause() }

    func seek(to seconds: Double) {
        player.seek(to: CMTime(seconds: seconds, preferredTimescale: 600), toleranceBefore: .zero, toleranceAfter: .zero)
    }
}
