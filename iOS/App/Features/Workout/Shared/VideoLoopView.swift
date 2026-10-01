import AVFoundation
import SwiftUI

/// Muted, seamless loop of an exercise clip (task 3.10). Stops when the app is not active, restarts
/// on the move being done; Reduce Motion or a broken file shows a still frame from the same clip.
struct ExerciseVideo: View {
    let fileName: String?
    /// Stop on the hold frame (stretch: after the move into the pose).
    var isHolding = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.forceStillFrames) private var forceStillFrames
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.videoPaused) private var videoPaused
    @State private var failed = false

    var body: some View {
        ZStack {
            Palette.surface
            if let url = Self.url(for: fileName) {
                if reduceMotion || forceStillFrames || failed {
                    StillFrameView(url: url)
                } else {
                    VideoLoopView(url: url, isPlaying: scenePhase == .active && !isHolding && !videoPaused, onFailure: { failed = true })
                }
            } else {
                IllustrationPlaceholder(symbol: "figure.seated.side", tint: Palette.secondary, height: 200)
            }
        }
        .aspectRatio(16 / 9, contentMode: .fit)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .accessibilityHidden(true)
    }

    static func url(for fileName: String?) -> URL? {
        guard let fileName else { return nil }
        let name = (fileName as NSString).deletingPathExtension
        return Bundle.main.url(forResource: name, withExtension: (fileName as NSString).pathExtension)
    }

    /// The first clip of `candidates` that is in the app bundle (best first, see
    /// `Exercise.videoCandidates`); nil keeps the still picture. A clip dropped in later is picked
    /// up with no code change.
    static func firstBundled(_ candidates: [String]) -> String? {
        candidates.first { url(for: $0) != nil }
    }
}

extension EnvironmentValues {
    /// Shows still frames instead of video (screenshots of the Reduce Motion variant; the system
    /// setting cannot be set from the app).
    @Entry var forceStillFrames = false
    /// Opens the chair and stretch players in full-screen video (screenshots).
    @Entry var startsFullScreen = false
    /// The session is not playing (paused, break, interruption): exercise clips hold their frame.
    @Entry var videoPaused = false
}

/// `AVQueuePlayer` + `AVPlayerLooper` in a layer-backed view.
struct VideoLoopView: UIViewRepresentable {
    let url: URL
    let isPlaying: Bool
    var onFailure: @MainActor @Sendable () -> Void = {}

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.configure(url: url, onFailure: onFailure)
        return view
    }

    func updateUIView(_ view: PlayerView, context: Context) {
        if view.url != url { view.configure(url: url, onFailure: onFailure) }
        view.setPlaying(isPlaying)
    }

    static func dismantleUIView(_ view: PlayerView, coordinator: ()) {
        view.stop()
    }

    final class PlayerView: UIView {
        override class var layerClass: AnyClass { AVPlayerLayer.self }
        private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
        private var looper: AVPlayerLooper?
        private var statusObservation: NSKeyValueObservation?
        private(set) var url: URL?

        func configure(url: URL, onFailure: @escaping @MainActor @Sendable () -> Void) {
            self.url = url
            let item = AVPlayerItem(url: url)
            let player = AVQueuePlayer()
            player.isMuted = true
            player.preventsDisplaySleepDuringVideoPlayback = false
            // Video never takes the audio session: the coach's voice owns it.
            player.audiovisualBackgroundPlaybackPolicy = .pauses
            looper = AVPlayerLooper(player: player, templateItem: item)
            playerLayer.player = player
            playerLayer.videoGravity = .resizeAspectFill
            statusObservation = item.observe(\.status) { item, _ in
                if item.status == .failed { Task { @MainActor in onFailure() } }
            }
        }

        func setPlaying(_ playing: Bool) {
            playing ? playerLayer.player?.play() : playerLayer.player?.pause()
        }

        func stop() {
            playerLayer.player?.pause()
            looper?.disableLooping()
            looper = nil
            playerLayer.player = nil
            statusObservation = nil
        }
    }
}

/// First frame of a clip, generated once and cached.
struct StillFrameView: View {
    let url: URL
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                Palette.surface
            }
        }
        .task(id: url) { image = await StillFrameProvider.shared.frame(for: url) }
    }
}

/// Still frames from clips (Reduce Motion, broken video, thumbnails), cached in memory.
actor StillFrameProvider {
    static let shared = StillFrameProvider()
    private var cache: [URL: UIImage] = [:]

    func frame(for url: URL, at seconds: Double = 0.5) async -> UIImage? {
        if let cached = cache[url] { return cached }
        let generator = AVAssetImageGenerator(asset: AVURLAsset(url: url))
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 1280, height: 720)
        guard let cgImage = try? await generator.image(at: CMTime(seconds: seconds, preferredTimescale: 600)).image else {
            return nil
        }
        let image = UIImage(cgImage: cgImage)
        cache[url] = image
        return image
    }
}
