import AVFoundation

/// Short UI sounds outside the session's audio program (tools/audio/make_cue_sounds.py): the countdown's
/// "ting" for 3, 2, 1 and its "Go" chime, and the "ta-da" with Complete's falling leaves. Loaded on first
/// use and kept, so a sound rings on after its screen is gone. They play on the workout's audio session,
/// which is active from the countdown until the session closes.
@MainActor final class CueSounds {
    static let shared = CueSounds()

    private lazy var tickPlayer = Self.player("countdown-tick", volume: 0.8)
    private lazy var goPlayer = Self.player("countdown-go", volume: 0.8)
    private lazy var cheerPlayer = Self.player("complete-cheer", volume: 0.7)

    func tick() { restart(tickPlayer) }
    func go() { restart(goPlayer) }
    func cheer() { restart(cheerPlayer) }

    /// "Skip the countdown": no chime after she skipped it.
    func stop() {
        tickPlayer?.stop()
        goPlayer?.stop()
    }

    private func restart(_ player: AVAudioPlayer?) {
        guard let player else { return }
        player.currentTime = 0
        player.play()
    }

    private static func player(_ name: String, volume: Float) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "m4a"),
              let player = try? AVAudioPlayer(contentsOf: url) else { return nil }
        player.volume = volume
        player.prepareToPlay()
        return player
    }
}
