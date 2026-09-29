#if DEBUG
import GentleWalkCore

/// Screenshot engine: plays nothing; the capture scene moves the clock by hand.
@MainActor final class SilentPlaybackEngine: PlaybackEngine {
    var onTime: ((Double) -> Void)?
    var onEnd: (() -> Void)?

    func load(_ timeline: SessionTimeline) async throws {}
    func play() {}
    func pause() {}
    func seek(to seconds: Double) {}
    func setVoiceOn(_ on: Bool) {}
}

@MainActor final class DiscardingPainRecorder: PainReportRecording {
    func record(_ report: PainReportSnapshot) {}
}
#endif
