import Foundation

/// How loud the coach and the music are, and whether each chair move starts with its name and
/// purpose (Me → Workout and the player's Sound sheet). Stored on this phone only (CA92.1).
struct AudioLevels: Equatable {
    static let voiceKey = "voiceVolume"
    static let musicKey = "musicVolume"
    static let introsKey = "moveIntroductionsOn"
    /// The coach is never quieter than this, so her guidance stays audible.
    static let voiceFloor = 0.4
    static let defaultMusic = 0.8

    var voice: Double
    var music: Double
    var moveIntroductions: Bool

    static func saved(in defaults: UserDefaults = .standard) -> AudioLevels {
        AudioLevels(voice: defaults.object(forKey: voiceKey) as? Double ?? 1,
                    music: defaults.object(forKey: musicKey) as? Double ?? defaultMusic,
                    moveIntroductions: defaults.object(forKey: introsKey) as? Bool ?? true).clamped
    }

    func save(in defaults: UserDefaults = .standard) {
        let levels = clamped
        defaults.set(levels.voice, forKey: Self.voiceKey)
        defaults.set(levels.music, forKey: Self.musicKey)
        defaults.set(levels.moveIntroductions, forKey: Self.introsKey)
    }

    var clamped: AudioLevels {
        AudioLevels(voice: min(1, max(Self.voiceFloor, voice)), music: min(1, max(0, music)),
                    moveIntroductions: moveIntroductions)
    }
}
