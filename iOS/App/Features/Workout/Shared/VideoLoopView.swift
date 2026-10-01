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
    @Environment(\.clipDirection) private var clipDirection
    @State private var failed = false

    var body: some View {
        ZStack {
            Palette.surface
            if let url = Self.url(for: fileName) {
                if reduceMotion || forceStillFrames || failed {
                    StillFrameView(url: url)
                } else {
                    // The clip's first frame sits under the player, so the very first load never shows
                    // an empty card either.
                    StillFrameView(url: url)
                    VideoLoopView(url: url, isPlaying: scenePhase == .active && !isHolding && !videoPaused,
                                  direction: clipDirection, onFailure: { failed = true })
                }
            } else {
                IllustrationPlaceholder(symbol: "figure.seated.side", tint: Palette.secondary, height: 200)
            }
        }
        .aspectRatio(16 / 9, contentMode: .fit)
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .accessibilityHidden(true)
        // The next clip's frame is ready before its card appears (the Rest screen shows the next move).
        .task(id: fileName) { if let url = Self.url(for: fileName) { _ = await StillFrameProvider.shared.frame(for: url) } }
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
    /// Which way the session last moved, for the clip's slide (Back slides in from the left).
    @Entry var clipDirection: MoveDirection = .forward
}

/// `AVQueuePlayer` + `AVPlayerLooper` per clip, in a view that swaps clips without a blank frame:
/// the clip on screen stays until the next one has its first frame, then the new one slides in
/// (from the right for the next part, from the left for Back) or fades in (the same move's hold or
/// easier clip). Before, the old player was replaced at once and the empty layer flashed white.
struct VideoLoopView: UIViewRepresentable {
    let url: URL
    let isPlaying: Bool
    var direction: MoveDirection = .forward
    var animates = true
    var onFailure: @MainActor @Sendable () -> Void = {}

    func makeUIView(context: Context) -> PlayerView {
        let view = PlayerView()
        view.show(url: url, direction: direction, animated: false, onFailure: onFailure)
        view.setPlaying(isPlaying)
        return view
    }

    func updateUIView(_ view: PlayerView, context: Context) {
        view.show(url: url, direction: direction, animated: animates, onFailure: onFailure)
        view.setPlaying(isPlaying)
    }

    static func dismantleUIView(_ view: PlayerView, coordinator: ()) {
        view.stop()
    }

    /// "S5-hold.mp4" and "S5.mp4" are the same move: those swap with a fade, not a slide.
    static func moveName(of url: URL) -> String {
        var name = url.deletingPathExtension().lastPathComponent
        for suffix in ["-hold", "-easy", "-quick"] where name.hasSuffix(suffix) { name.removeLast(suffix.count) }
        return name
    }

    /// One clip: its layer, looping player and readiness watch.
    @MainActor final class Clip {
        let url: URL
        let layer = AVPlayerLayer()
        let player = AVQueuePlayer()
        private var looper: AVPlayerLooper?
        private var observations: [NSKeyValueObservation] = []

        init(url: URL, onReady: @escaping @MainActor (Clip) -> Void, onFailure: @escaping @MainActor @Sendable () -> Void) {
            self.url = url
            let item = AVPlayerItem(url: url)
            player.isMuted = true
            player.preventsDisplaySleepDuringVideoPlayback = false
            // Video never takes the audio session: the coach's voice owns it.
            player.audiovisualBackgroundPlaybackPolicy = .pauses
            looper = AVPlayerLooper(player: player, templateItem: item)
            layer.player = player
            layer.videoGravity = .resizeAspectFill
            observations.append(layer.observe(\.isReadyForDisplay, options: [.initial, .new]) { [weak self] layer, _ in
                guard layer.isReadyForDisplay else { return }
                Task { @MainActor [weak self] in if let self { onReady(self) } }
            })
            observations.append(item.observe(\.status) { item, _ in
                if item.status == .failed { Task { @MainActor in onFailure() } }
            })
        }

        func tearDown() {
            observations = []
            player.pause()
            looper?.disableLooping()
            looper = nil
            layer.player = nil
            layer.removeFromSuperlayer()
        }
    }

    final class PlayerView: UIView {
        private var current: Clip?
        /// The next clip, loading off screen until its first frame is ready.
        private var incoming: Clip?
        private var pending: (direction: MoveDirection, animated: Bool) = (.forward, false)
        private var playing = false
        var url: URL? { incoming?.url ?? current?.url }

        override func layoutSubviews() {
            super.layoutSubviews()
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            current?.layer.frame = bounds
            incoming?.layer.frame = bounds
            CATransaction.commit()
        }

        func show(url: URL, direction: MoveDirection, animated: Bool, onFailure: @escaping @MainActor @Sendable () -> Void) {
            guard url != self.url else { return }
            incoming?.tearDown()   // a newer clip replaces one still loading (quick Skip taps)
            pending = (direction, animated && current != nil)
            let clip = Clip(url: url, onReady: { [weak self] clip in self?.reveal(clip) }, onFailure: onFailure)
            clip.layer.frame = bounds
            clip.layer.isHidden = true
            layer.addSublayer(clip.layer)
            incoming = clip
            if playing { clip.player.play() }
        }

        private func reveal(_ clip: Clip) {
            guard incoming === clip else { return }
            incoming = nil
            if pending.animated, let old = current {
                let transition = CATransition()
                transition.duration = 0.35
                transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                if VideoLoopView.moveName(of: old.url) == VideoLoopView.moveName(of: clip.url) {
                    transition.type = .fade
                } else {
                    transition.type = .push
                    transition.subtype = pending.direction == .forward ? .fromRight : .fromLeft
                }
                layer.add(transition, forKey: "clipSwap")
            }
            CATransaction.begin()
            if !pending.animated { CATransaction.setDisableActions(true) }
            clip.layer.isHidden = false
            current?.tearDown()
            CATransaction.commit()
            current = clip
        }

        func setPlaying(_ playing: Bool) {
            self.playing = playing
            for clip in [current, incoming].compactMap({ $0 }) {
                playing ? clip.player.play() : clip.player.pause()
            }
        }

        func stop() {
            incoming?.tearDown()
            current?.tearDown()
            incoming = nil
            current = nil
        }
    }
}

/// First frame of a clip, generated once and cached. A cached frame shows on the first draw, so a
/// freshly made video card (Rest → the move) is never empty while its player loads.
struct StillFrameView: View {
    let url: URL
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            if let image = image ?? StillFrameProvider.shared.cached(url) {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                Palette.surface
            }
        }
        .task(id: url) { image = await StillFrameProvider.shared.frame(for: url) }
    }
}

/// Still frames from clips (Reduce Motion, broken video, thumbnails, the frame under a loading
/// player), cached in memory.
final class StillFrameProvider: @unchecked Sendable {
    static let shared = StillFrameProvider()
    private let lock = NSLock()
    private var cache: [URL: UIImage] = [:]

    func cached(_ url: URL) -> UIImage? { lock.withLock { cache[url] } }

    func frame(for url: URL, at seconds: Double = 0.5) async -> UIImage? {
        if let cached = cached(url) { return cached }
        let generator = AVAssetImageGenerator(asset: AVURLAsset(url: url))
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 1280, height: 720)
        guard let cgImage = try? await generator.image(at: CMTime(seconds: seconds, preferredTimescale: 600)).image else {
            return nil
        }
        let image = UIImage(cgImage: cgImage)
        lock.withLock { cache[url] = image }
        return image
    }
}
