import AVFoundation
import GentleWalkCore

/// The self-check's 40 seconds of audio as one program (`SessionTimeline.selfCheck`), built by
/// `SessionAudioComposer` and played by one `AVPlayer`, like a session (task 4.7). Lines without a
/// recording stay silent; the bells always ring. No music, nothing silent added.
@MainActor final class SelfCheckAudioPlayer: SelfCheckAudioPlaying {
    private let content: ContentBundle
    private let voiceSource: VoiceSource
    private var player: AVPlayer?
    private var task: Task<Void, Never>?

    init(content: ContentBundle, voiceSource: VoiceSource) {
        self.content = content
        self.voiceSource = voiceSource
    }

    func start(onPlaying: @escaping @MainActor () -> Void) {
        stop()
        task = Task { [weak self] in
            guard let self else { return }
            let timeline = SessionTimeline.selfCheck(voice: content.voiceLines)
            var urls: [String: URL] = [:]
            for id in SessionTimeline.selfCheckLineIDs {
                switch await voiceSource.resolve(id) {
                case .bundled(let url), .synthesized(let url): urls[id] = url
                case .missing: break
                }
            }
            guard !Task.isCancelled else { return }
            guard let bell = SessionMedia.phaseBellURL,
                  let built = try? await SessionAudioComposer.compose(timeline: timeline, voiceURL: urls, bellURL: bell,
                                                                       doneBellURL: SessionMedia.doneBellURL, musicURL: nil),
                  !Task.isCancelled else {
                // No audio: the screen still runs the 30 seconds with words.
                if !Task.isCancelled { onPlaying() }
                return
            }
            try? AudioSessionConfigurator.apply(.guided)
            let item = AVPlayerItem(asset: built.0)
            item.audioMix = built.1
            let player = AVPlayer(playerItem: item)
            self.player = player
            player.play()
            onPlaying()
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        player?.pause()
        if player != nil { AudioSessionConfigurator.deactivate() }
        player = nil
    }
}
