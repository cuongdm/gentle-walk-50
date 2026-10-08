import Foundation

/// A chair move she swapped on a preview (P12) and when.
public struct SwapChoice: Codable, Equatable, Sendable {
    public var replacement: String
    public var date: Date

    public init(replacement: String, date: Date) {
        self.replacement = replacement; self.date = date
    }
}

/// What she chose during and before her sessions, remembered on the phone (P5, P3, P12; plan 4.4–4.6):
/// Easier taps per move, Harder done in full, moves brought back from "set aside", and preview swaps.
/// Only allows or suggests: she can always change it in the session.
public struct ExerciseMemory: Codable, Equatable, Sendable {
    public var easierTaps: [String: [Date]]
    /// Harder chosen and the move done in full (Pro), the latest time.
    public var harderDone: [String: Date]
    /// "Bring it back" in Me, move id → when: pain reports until then no longer set it aside.
    public var restored: [String: Date]
    /// Preview swaps, original move → her choice.
    public var swaps: [String: SwapChoice]
    /// Free plan: "With Pro, more reps when you're ready" was said once.
    public var harderProNoteShown: Bool

    public init(easierTaps: [String: [Date]] = [:], harderDone: [String: Date] = [:], restored: [String: Date] = [:],
                swaps: [String: SwapChoice] = [:], harderProNoteShown: Bool = false) {
        self.easierTaps = easierTaps; self.harderDone = harderDone; self.restored = restored; self.swaps = swaps
        self.harderProNoteShown = harderProNoteShown
    }

    /// Easier this many times in `easierWindowDays`: the move starts easier.
    public static let easierTaps = 2
    public static let easierWindowDays = 14
    /// Harder done in full allows one more step for this long (D10).
    public static let harderWindowDays = 7
    /// A preview swap holds for two weeks, then the move comes back in the rotation.
    public static let swapDays = 14
    /// Taps kept per move.
    static let keptTaps = 6

    private static func within(_ date: Date, days: Int, of now: Date) -> Bool {
        date <= now && now.timeIntervalSince(date) < Double(days) * 86_400
    }

    /// Moves that start with the easier version: two Easier taps in the last two weeks.
    public func defaultsEasier(now: Date) -> Set<String> {
        Set(easierTaps.filter { $0.value.filter { Self.within($0, days: Self.easierWindowDays, of: now) }.count >= Self.easierTaps }
            .keys)
    }

    /// Counted moves where Harder was done in full lately (Pro): the rep ladder may go one step higher.
    public func harderBonus(now: Date) -> Set<String> {
        Set(harderDone.filter { Self.within($0.value, days: Self.harderWindowDays, of: now) }.keys)
    }

    /// Preview swaps still remembered, original → replacement.
    public func activeSwaps(now: Date) -> [String: String] {
        swaps.filter { Self.within($0.value.date, days: Self.swapDays, of: now) }.mapValues(\.replacement)
    }

    /// The remembered Easier taps as rules for the session builder (merged with the pain rules).
    public func exerciseRules(now: Date) -> ExerciseRules { ExerciseRules(easier: defaultsEasier(now: now)) }

    public mutating func noteEasier(_ id: String, at date: Date) {
        easierTaps[id, default: []] = Array((easierTaps[id, default: []] + [date]).suffix(Self.keptTaps))
    }

    /// "Try the usual one": the move starts with its usual version again.
    public mutating func useUsualVersion(_ id: String) { easierTaps[id] = nil }

    public mutating func noteHarderDone(_ id: String, at date: Date) { harderDone[id] = date }

    public mutating func restore(_ id: String, at date: Date) { restored[id] = date }

    /// Swaps chosen on a preview she started: each replaces the remembered one for the same move.
    public mutating func noteSwaps(_ chosen: [String: String], at date: Date) {
        for (original, replacement) in chosen { swaps[original] = SwapChoice(replacement: replacement, date: date) }
    }
}
