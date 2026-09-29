import AVFoundation
import GentleWalkCore

/// Builds the whole session as one audio program (task 3.2): a voice track, a bell track and an
/// optional looping music track, with the music lowered while the coach speaks. One `AVPlayer`
/// plays it, so guidance keeps going with the screen locked. Without music the program ends with
/// its last sound: nothing silent is ever added to keep the app running (2.5.4).
enum SessionAudioComposer {
    /// Music volume while a line is spoken.
    static let duckedVolume: Float = 0.25
    static let timescale: CMTimeScale = 600

    enum ComposeError: Error { case noTrack }

    /// - Parameters:
    ///   - voiceURL: audio file per voice line id; lines without a file are left silent.
    ///   - doneBellURL: the completion bell; the phase bell is used when nil.
    ///   - length: how long music plays; defaults to the timeline total (open-ended walks pass more).
    static func compose(timeline: SessionTimeline, voiceURL: [String: URL], bellURL: URL, doneBellURL: URL? = nil,
                        musicURL: URL?, length: Double? = nil) async throws -> (AVMutableComposition, AVAudioMix) {
        let total = time(length ?? timeline.total)
        let composition = AVMutableComposition()

        var voiceTrack = TrackWriter(composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid))
        for cue in timeline.voice {
            guard let url = voiceURL[cue.lineID] else { continue }
            try await voiceTrack.place(url, at: time(cue.start), limit: total)
        }

        var bellTrack = TrackWriter(composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid))
        for bell in timeline.bells {
            let url = bell.kind == .done ? (doneBellURL ?? bellURL) : bellURL
            try await bellTrack.place(url, at: time(bell.at), limit: total)
        }

        let mix = AVMutableAudioMix()
        if let musicURL {
            var musicTrack = TrackWriter(composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid))
            try await musicTrack.loop(musicURL, until: total)
            let parameters = AVMutableAudioMixInputParameters(track: musicTrack.track)
            parameters.setVolume(1, at: .zero)
            for cue in timeline.voice where voiceURL[cue.lineID] != nil {
                parameters.setVolume(duckedVolume, at: time(cue.start))
                parameters.setVolume(1, at: time(cue.end))
            }
            mix.inputParameters = [parameters]
        }
        return (composition, mix)
    }

    static func time(_ seconds: Double) -> CMTime { CMTime(seconds: seconds, preferredTimescale: timescale) }

    /// Appends clips in time order so nothing already placed gets shifted.
    struct TrackWriter {
        let track: AVMutableCompositionTrack
        private var cursor = CMTime.zero
        /// Source assets stay alive while their tracks are inserted: an `AVAssetTrack` does not
        /// keep its asset, and a freed asset makes the insert fail (-12780).
        private var sources: [URL: (AVURLAsset, AVAssetTrack, CMTimeRange)] = [:]

        init(_ track: AVMutableCompositionTrack?) {
            // addMutableTrack only fails for invalid media types; audio is always valid.
            self.track = track!
        }

        mutating func place(_ url: URL, at start: CMTime, limit: CMTime) async throws {
            let (source, range) = try await load(url)
            let begin = CMTimeMaximum(start, cursor)
            guard begin < limit else { return }
            if begin > cursor { track.insertEmptyTimeRange(CMTimeRange(start: cursor, end: begin)) }
            let length = CMTimeMinimum(range.duration, limit - begin)
            try track.insertTimeRange(CMTimeRange(start: range.start, duration: length), of: source, at: begin)
            cursor = begin + length
        }

        mutating func loop(_ url: URL, until limit: CMTime) async throws {
            let (source, range) = try await load(url)
            guard range.duration > .zero else { return }
            while cursor < limit {
                let length = CMTimeMinimum(range.duration, limit - cursor)
                try track.insertTimeRange(CMTimeRange(start: range.start, duration: length), of: source, at: cursor)
                cursor = cursor + length
            }
        }

        /// The audio track and its own time range (an AAC file's track can be shorter than the file).
        /// Each file is loaded once per track and kept for the life of the writer.
        private mutating func load(_ url: URL) async throws -> (AVAssetTrack, CMTimeRange) {
            if let cached = sources[url] { return (cached.1, cached.2) }
            let asset = AVURLAsset(url: url)
            guard let source = try await asset.loadTracks(withMediaType: .audio).first else { throw ComposeError.noTrack }
            let range = try await source.load(.timeRange)
            sources[url] = (asset, source, range)
            return (source, range)
        }
    }
}
