import MediaPlayer

/// Lock-screen card and play/pause buttons for a session (task 3.7).
@MainActor final class NowPlayingController {
    private let title: String
    private var targets: [(MPRemoteCommand, Any)] = []

    /// - Parameters:
    ///   - title: session name, e.g. "First walk".
    ///   - onPlay / onPause: forwarded from the lock screen, headphones or car controls.
    init(title: String, onPlay: @escaping @MainActor () -> Void, onPause: @escaping @MainActor () -> Void) {
        self.title = title
        let center = MPRemoteCommandCenter.shared()
        let play = center.playCommand.addTarget { _ in
            Task { @MainActor in onPlay() }
            return .success
        }
        let pause = center.pauseCommand.addTarget { _ in
            Task { @MainActor in onPause() }
            return .success
        }
        let toggle = center.togglePlayPauseCommand.addTarget { _ in
            Task { @MainActor in
                MPNowPlayingInfoCenter.default().playbackState == .playing ? onPause() : onPlay()
            }
            return .success
        }
        targets = [(center.playCommand, play), (center.pauseCommand, pause), (center.togglePlayPauseCommand, toggle)]
        for command in [center.nextTrackCommand, center.previousTrackCommand, center.changePlaybackPositionCommand] {
            command.isEnabled = false
        }
    }

    func update(elapsed: Double, duration: Double, isPlaying: Bool) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: AppBrand.name,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsed,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
        ]
        MPNowPlayingInfoCenter.default().playbackState = isPlaying ? .playing : .paused
    }

    func clear() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        MPNowPlayingInfoCenter.default().playbackState = .stopped
        for (command, target) in targets { command.removeTarget(target) }
        targets = []
    }
}
