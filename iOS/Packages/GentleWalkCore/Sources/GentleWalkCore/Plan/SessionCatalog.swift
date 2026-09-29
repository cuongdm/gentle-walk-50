/// A named session anyone can pick outside the plan (milestone 10, docs/idea/session-choice.md).
/// It is only a recipe: the app builds the session with `SessionBuilder` like a planned day.
public struct SessionPreset: Equatable, Hashable, Sendable, Identifiable {
    /// The four groups of "All sessions", in screen order.
    public enum Group: String, CaseIterable, Sendable { case walks, chair, stretch, extras }

    /// Stable: favourites store it.
    public let id: String
    public let group: Group
    public let main: PlannedDay.Main
    public let intensity: Intensity
    /// Suggested walking level; the preview still lets her change it.
    public let level: WalkLevel
    /// Stretch only: standing, holding the chair (otherwise seated).
    public let standing: Bool
    /// Open on the free plan.
    public let isFree: Bool
    /// Fixed move rotation (Balance always uses the same moves); nil follows the active days.
    public let fixedRotation: Int?

    init(_ id: String, _ group: Group, _ main: PlannedDay.Main, _ intensity: Intensity, level: WalkLevel = .seated,
         standing: Bool = false, isFree: Bool = false, fixedRotation: Int? = nil) {
        self.id = id; self.group = group; self.main = main; self.intensity = intensity; self.level = level
        self.standing = standing; self.isFree = isFree; self.fixedRotation = fixedRotation
    }
}

/// Every session in "All sessions" and the choices of "Try something else" (decided 29/09/2026):
/// the free plan opens every walk plus the lightest chair and stretch sessions; extras stay Pro.
public enum SessionCatalog {
    /// The gentle walk doubles as "Just 5 minutes today" in the swap sheet.
    public static let justFiveMinutesID = "walk.gentle"

    public static let all: [SessionPreset] = [
        SessionPreset("walk.gentle", .walks, .walk, .gentle, level: .seated, isFree: true),
        SessionPreset("walk.steady", .walks, .walk, .steady, level: .inPlace, isFree: true),
        SessionPreset("walk.strong", .walks, .walk, .strong, level: .inPlace, isFree: true),
        SessionPreset("walk.long", .walks, .longWalk, .steady, level: .inPlace, isFree: true),
        SessionPreset("chair.gentle", .chair, .chair, .gentle, isFree: true),
        SessionPreset("chair.steady", .chair, .chair, .steady),
        SessionPreset("chair.strong", .chair, .chair, .strong),
        SessionPreset("stretch.seated.gentle", .stretch, .stretch, .gentle, isFree: true),
        SessionPreset("stretch.seated.steady", .stretch, .stretch, .steady),
        SessionPreset("stretch.standing.gentle", .stretch, .stretch, .gentle, standing: true),
        SessionPreset("stretch.standing.steady", .stretch, .stretch, .steady, standing: true),
        SessionPreset("extra.commercial", .extras, .walk, .gentle),
        SessionPreset("extra.morning", .extras, .stretch, .gentle),
        SessionPreset("extra.balance", .extras, .chair, .gentle, fixedRotation: 5),
    ]

    public static func presets(in group: SessionPreset.Group) -> [SessionPreset] {
        all.filter { $0.group == group }
    }

    public static func preset(id: String) -> SessionPreset? {
        all.first { $0.id == id }
    }

    /// "Try something else": the two kinds not planned today, then five gentle minutes. All free,
    /// so a tired day never meets a paywall. Nothing on a rest day.
    public static func swapOptions(planned: PlannedDay.Main?) -> [SessionPreset] {
        let ids: [String]
        switch planned {
        case nil: return []
        case .walk, .longWalk: ids = ["chair.gentle", "stretch.seated.gentle"]
        case .chair: ids = ["walk.steady", "stretch.seated.gentle"]
        case .stretch: ids = ["walk.steady", "chair.gentle"]
        }
        return (ids + [justFiveMinutesID]).compactMap(preset(id:))
    }
}
