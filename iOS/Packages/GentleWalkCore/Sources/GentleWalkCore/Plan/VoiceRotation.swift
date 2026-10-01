/// Picks voice-line variants so back-to-back sessions do not sound the same (A2 §3.2: the variant
/// moves with the rotation index). Only families written as interchangeable variants rotate, and a
/// family only rotates among the variants that fit her level and limits ("chỉ In place / Pad").
public enum VoiceRotation {
    /// Families whose numbered lines say the same thing in different words. Others (A1 lines, warm-up
    /// sequences, A10 hold lines, counts) have a fixed role and never rotate.
    static let families: Set<String> = [
        "a2.open", "a2.setup.seated", "a2.setup.inplace", "a2.setup.pad", "a2.soon",
        "a2.brisk.seated", "a2.brisk.inplace", "a2.brisk.pad", "a2.brisk.again", "a2.brisk.mid", "a2.brisk.end",
        "a2.easy", "a2.easy.mid", "a2.round", "a2.close", "a2.now", "a2.gentle", "a2.talk",
        // Not "a2.cool.stretch": its variants say "a few" and "two" stretches, so each walk picks one.
        "a2.cool.seated", "a2.cool.inplace", "a2.cool.mid",
        "a4.demo", "a4.with-me", "a4.rest", "a4.slow",
        "a10.into", "a10.switch", "a10.hold.start", "a10.round2", "a10.close", "a11.break.close",
    ]

    /// Variant numbers per rotating family, from the lines that exist in the content.
    public struct Table: Sendable {
        let variants: [String: [Int]]
        let lines: [String: VoiceLine]

        public init(lines: [VoiceLine]) {
            var variants: [String: [Int]] = [:]
            var book: [String: VoiceLine] = [:]
            for line in lines {
                book[line.id] = line
                if let (family, number) = VoiceRotation.split(line.id), families.contains(family) {
                    variants[family, default: []].append(number)
                }
            }
            self.variants = variants.mapValues { $0.sorted() }
            self.lines = book
        }

        /// The line to play: same family, shifted by the rotation index among the variants that fit.
        public func rotate(_ id: String, by rotationIndex: Int, level: WalkLevel?, limits: Set<BodyLimit>) -> String {
            guard let (family, number) = VoiceRotation.split(id), let all = variants[family] else { return id }
            let fitting = all.filter { lines["\(family).\($0)"]?.fits(level: level, limits: limits) ?? false }
            guard fitting.count > 1, let index = fitting.firstIndex(of: number) else { return id }
            return "\(family).\(fitting[(index + max(0, rotationIndex)) % fitting.count])"
        }

        /// Every line the id can become (itself included), for content checks.
        public func alternatives(of id: String, level: WalkLevel?) -> [String] {
            guard let (family, _) = VoiceRotation.split(id), let all = variants[family] else { return [id] }
            let fitting = all.map { "\(family).\($0)" }.filter { lines[$0]?.fits(level: level, limits: []) ?? false }
            return fitting.contains(id) ? fitting : [id]
        }
    }

    /// "a2.brisk.mid.2" → ("a2.brisk.mid", 2).
    static func split(_ id: String) -> (String, Int)? {
        guard let dot = id.lastIndex(of: "."), let number = Int(id[id.index(after: dot)...]), number > 0 else { return nil }
        return (String(id[..<dot]), number)
    }
}
