/// Which clip files can show an exercise, best first (content plan 30/09/2026 §3 "Sửa app kèm theo").
/// Pure: the app picks the first file that is in its bundle, so a clip dropped in later needs no
/// code change, and a missing one falls back to the next (in the end: a still picture).
public extension Exercise {
    /// Walking pace of the phase the clip plays in.
    enum Pace: Sendable { case easy, quicker }

    /// - Parameters:
    ///   - level: walking level (walk moves have one clip per level; the walking pad has none yet).
    ///   - pace: walks only: easy (slowed, `-easy`) or quicker (`-quick`) version of the level clip.
    ///   - easier: the easier version is on (This hurts, or a body limit).
    ///   - holding: a stretch is being held.
    ///   - alternate: the session does the move its other way (Balance: heel raises standing).
    func videoCandidates(level: WalkLevel = .seated, pace: Pace? = nil, easier: Bool = false,
                         holding: Bool = false, alternate: Bool = false) -> [String] {
        switch kind {
        case .walk:
            let base: String? = switch level {
            case .seated: videoSeated
            case .inPlace: videoFile
            case .pad: nil
            }
            guard let base else { return [] }
            switch pace {
            case .easy: return [Self.variant(base, "easy"), base]
            case .quicker: return [Self.variant(base, "quick"), base]
            case nil: return [base]
            }
        case .move, .stretch, .balance:
            var files: [String?] = []
            if holding { files.append(videoHold) }
            if alternate { files.append(videoAlt) }
            if easier { files.append(videoEasy) }
            files.append(videoFile)
            return files.compactMap { $0 }
        }
    }

    /// Every clip the content names for this exercise, and whether it must ship now.
    var namedVideos: [(file: String, required: Bool)] {
        let later = Set(videoLater ?? [])
        let main = [videoFile, videoSeated].compactMap { $0 }.map { ($0, !later.contains($0)) }
        let extras = [videoEasy, videoHold, videoAlt].compactMap { $0 }.map { ($0, false) }
        return main + extras
    }

    /// "W2-1.mp4" + "easy" → "W2-1-easy.mp4" (clips re-timed from the same source, PROMPTS §6).
    static func variant(_ file: String, _ suffix: String) -> String {
        guard let dot = file.lastIndex(of: ".") else { return "\(file)-\(suffix)" }
        return "\(file[..<dot])-\(suffix)\(file[dot...])"
    }
}
