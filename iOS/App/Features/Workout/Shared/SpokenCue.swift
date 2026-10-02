import AVFoundation
import GentleWalkCore

/// A few coach lines played one after another outside the session's program, while it is paused
/// ("Stand behind your chair", then "We'll start in ten seconds"). Lines without a recording are
/// skipped (development builds may lack them).
@MainActor final class SpokenCue {
    private var player: AVQueuePlayer?

    func play(_ ids: [String], from content: ContentBundle, bundle: Bundle = .main) {
        stop()
        let lines = Dictionary(content.voiceLines.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let items = ids.compactMap { id -> AVPlayerItem? in
            guard let file = lines[id]?.file else { return nil }
            let name = (file as NSString).deletingPathExtension
            let ext = (file as NSString).pathExtension
            return bundle.url(forResource: name, withExtension: ext).map(AVPlayerItem.init(url:))
        }
        guard !items.isEmpty else { return }
        let queue = AVQueuePlayer(items: items)
        player = queue
        queue.play()
    }

    func stop() {
        player?.pause()
        player = nil
    }
}
