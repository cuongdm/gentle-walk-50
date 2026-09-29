/// Picks voice-line variants so back-to-back sessions do not sound the same (A2 §2.1: the variant
/// moves with the rotation index). Only families written as interchangeable variants rotate.
public enum VoiceRotation {
    /// Families whose numbered lines say the same thing in different words. Others (A1 lines,
    /// `a2.cool.pad.1/2`, A10 hold lines) have a fixed role and never rotate.
    static let families: Set<String> = [
        "a2.open", "a2.setup.seated", "a2.setup.inplace", "a2.setup.pad", "a2.warm", "a2.soon",
        "a2.brisk.seated", "a2.brisk.inplace", "a2.brisk.pad", "a2.brisk.again", "a2.brisk.mid",
        "a2.easy", "a2.easy.mid", "a2.round", "a2.close",
    ]

    /// Variant counts per family, from the lines that exist in the content.
    public static func variantCounts(in lines: [VoiceLine]) -> [String: Int] {
        var counts: [String: Int] = [:]
        for line in lines {
            if let (family, _) = split(line.id), families.contains(family) { counts[family, default: 0] += 1 }
        }
        return counts
    }

    /// The line to play: same family, variant shifted by the rotation index.
    public static func rotate(_ id: String, by rotationIndex: Int, counts: [String: Int]) -> String {
        guard let (family, number) = split(id), let count = counts[family], count > 1 else { return id }
        let variant = (number - 1 + rotationIndex) % count + 1
        return "\(family).\(variant)"
    }

    /// "a2.brisk.mid.2" → ("a2.brisk.mid", 2).
    static func split(_ id: String) -> (String, Int)? {
        guard let dot = id.lastIndex(of: "."), let number = Int(id[id.index(after: dot)...]), number > 0 else { return nil }
        return (String(id[..<dot]), number)
    }
}
