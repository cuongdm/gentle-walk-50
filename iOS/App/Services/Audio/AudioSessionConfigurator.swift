import AVFoundation

/// Who owns the sound during a session.
enum AudioContext: Equatable, Sendable {
    /// Indoor sessions and outdoors with the app's voice (and optional music).
    case guided
    /// Outdoors with "My audio": the coach speaks over the user's own podcast or music.
    case overUserAudio
}

struct AudioSessionSettings: Equatable {
    var category: AVAudioSession.Category
    var mode: AVAudioSession.Mode
    var options: AVAudioSession.CategoryOptions
}

/// Audio session for a workout (task 3.1). The session is always audible spoken guidance, which is
/// what the `audio` background mode is for (2.5.4); the app never plays silence to stay awake.
enum AudioSessionConfigurator {
    static func settings(for context: AudioContext) -> AudioSessionSettings {
        switch context {
        case .guided:
            AudioSessionSettings(category: .playback, mode: .spokenAudio, options: [])
        case .overUserAudio:
            AudioSessionSettings(category: .playback, mode: .spokenAudio, options: [.mixWithOthers, .duckOthers])
        }
    }

    /// Activates the session for a workout. Call when the session starts, not at launch.
    static func apply(_ context: AudioContext, to session: AVAudioSession = .sharedInstance()) throws {
        let settings = settings(for: context)
        try session.setCategory(settings.category, mode: settings.mode, options: settings.options)
        try session.setActive(true)
    }

    static func deactivate(_ session: AVAudioSession = .sharedInstance()) {
        try? session.setActive(false, options: .notifyOthersOnDeactivation)
    }
}
