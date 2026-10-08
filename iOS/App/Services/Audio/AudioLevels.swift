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

    // MARK: Five steps for − / + (plan 08/10/2026 task 1.10: no sliders for shaky hands)

    static let steps = 5
    /// Music never steps down to silence here (the player's Music switch turns it off).
    static let musicFloor = 0.2

    static func voice(atStep step: Int) -> Double { value(atStep: step, floor: voiceFloor) }
    static func music(atStep step: Int) -> Double { value(atStep: step, floor: musicFloor) }
    static func voiceStep(for value: Double) -> Int { step(for: value, floor: voiceFloor) }
    static func musicStep(for value: Double) -> Int { step(for: value, floor: musicFloor) }

    /// Step 1 is `floor`, step 5 full volume, evenly spaced.
    private static func value(atStep step: Int, floor: Double) -> Double {
        let clamped = min(steps, max(1, step))
        return floor + (1 - floor) * Double(clamped - 1) / Double(steps - 1)
    }

    /// The nearest step for a stored value (older values from the slider fall between steps).
    private static func step(for value: Double, floor: Double) -> Int {
        let share = (min(1, max(floor, value)) - floor) / (1 - floor)
        return Int((share * Double(steps - 1)).rounded()) + 1
    }

    var clamped: AudioLevels {
        AudioLevels(voice: min(1, max(Self.voiceFloor, voice)), music: min(1, max(0, music)),
                    moveIntroductions: moveIntroductions)
    }
}
