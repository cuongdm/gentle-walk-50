/// Chair moves in the frames of docs/scripts/A4-chair-moves.md §5: which moves (rotated so two chair
/// days in a row differ), in which order, and the rests and sit ↔ stand changes between them.
enum ChairSessionPlanner {
    typealias Segment = SessionTemplate.Segment

    /// Seated moves the gentle day rotates through (A4 §5.5).
    static let seatedPool = ["mv.knee-lift", "mv.leg-ext", "mv.arm-raise", "mv.row", "mv.heel-toe"]
    static let sitToStand = "mv.sit-to-stand"

    /// Chair day: warm-up frame, then the moves with rests and changes, ending seated.
    static func chairDay(intensity: Intensity, context: SessionBuilder.Context) throws -> [Segment] {
        let ids = moves(intensity: intensity, context: context)
        let library = try context.segments(of: SessionBuilder.moveLibraryID(for: intensity))
        var segments = try context.segments(of: "ses.chair.\(intensity.rawValue).open")
        let rest = intensity == .strong ? "ses.chair.rest.10" : "ses.chair.rest.15"
        for (index, id) in ids.enumerated() {
            guard var move = try library.first(where: { $0.exerciseID == id }).map(context.move) else { continue }
            let next = ids.indices.contains(index + 1) ? ids[index + 1] : nil
            let standsNext = next.map { isStanding($0, context) } ?? false
            if id == sitToStand && standsNext { move = staysStanding(move) }
            segments.append(move)
            let change: String
            if isStanding(id, context) && !standsNext {
                change = "ses.chair.to-sit"
            } else if !isStanding(id, context) && standsNext {
                change = id == sitToStand ? "ses.chair.to-stand.sts" : "ses.chair.to-stand"
            } else {
                change = rest
            }
            segments += try context.segments(of: change)
        }
        return segments
    }

    /// One or two moves after a walk (the free plan and walk days), rotated through every allowed move.
    static func afterWalk(count: Int, context: SessionBuilder.Context) throws -> [Segment] {
        let library = try context.segments(of: SessionBuilder.moveLibraryID(for: .steady))
        let moves = library.filter { $0.exerciseID.map(context.allowed.contains) ?? false }
        guard !moves.isEmpty else { return [] }
        var picked = (0..<min(count, moves.count)).map { moves[(context.rotationIndex + $0) % moves.count] }
        // Her preview swap (P12) takes the place of the move she swapped away.
        picked = picked.map { move in
            guard let id = move.exerciseID, let swap = context.swapMemory[id],
                  !picked.contains(where: { $0.exerciseID == swap }),
                  let replacement = moves.first(where: { $0.exerciseID == swap }) else { return move }
            return replacement
        }
        var segments = [Segment(kind: .intro, seconds: 8, cues: [.init(at: 0, line: "a9.to-chair")])]
        for (index, move) in picked.enumerated() {
            if index > 0 { segments += try context.segments(of: "ses.chair.rest.15") }
            segments.append(try context.move(move))
        }
        return segments
    }

    /// The moves of a chair day, in order (A4 §5.2–5.4, adapted: see docs/reviews/2026-09-30-can-duyet.md).
    static func moves(intensity: Intensity, context: SessionBuilder.Context) -> [String] {
        let day = max(0, context.rotationIndex)
        let limits = context.limits
        let standingIsHard = limits.contains(.standingIsHard)
        var picked: [String]
        switch intensity {
        case .gentle:
            let pool = seatedPool.filter(context.allowed.contains)
            guard !pool.isEmpty else { return [] }
            picked = (0..<min(3, pool.count)).map { pool[(3 * day + $0) % pool.count] }
        case .steady:
            picked = ["mv.leg-ext", "mv.arm-raise", "mv.row"]
            if standingIsHard {
                picked += ["mv.heel-toe", sitToStand]
            } else {
                picked.append(limits.contains(.dizzy) ? "mv.heel-toe" : sitToStand)
                picked.append(["mv.single-leg", "mv.side-leg"][day % 2])
            }
        case .strong:
            picked = ["mv.row", "mv.leg-ext", sitToStand]
            if standingIsHard {
                picked += ["mv.knee-lift", "mv.arm-raise", "mv.heel-toe"]
            } else {
                picked += [["mv.single-leg", "mv.knee-curl"][day % 2], ["mv.side-leg", "mv.back-leg"][day % 2],
                           ["mv.mini-squat", "mv.wall-push"][day % 2]]
            }
        }
        // A move she swapped on a preview lately gives way to her choice (P12); a move her limits hide
        // gives way to a seated move not used yet.
        picked = picked.map { id in
            guard let swap = context.swapMemory[id], context.allowed.contains(swap), !picked.contains(swap) else { return id }
            return swap
        }
        var used = Set<String>()
        return picked.compactMap { id in
            let choice = context.allowed.contains(id) && !used.contains(id)
                ? id : seatedPool.first { context.allowed.contains($0) && !used.contains($0) && !picked.contains($0) }
            if let choice { used.insert(choice) }
            return choice
        }
    }

    static func isStanding(_ id: String, _ context: SessionBuilder.Context) -> Bool {
        context.content.exercises.first { $0.id == id }?.standing ?? false
    }

    /// Sit-to-stand before a standing move: "After this last one, stay standing." with the last rep.
    static func staysStanding(_ move: Segment) -> Segment {
        var copy = move
        guard let last = move.cues.lastIndex(where: { $0.line.hasPrefix("a5.last") || $0.line == "a4.v1.8" }) else { return copy }
        copy.cues.insert(.init(at: move.cues[last].at, line: "a4.to-stand.sts"), at: last + 1)
        return copy
    }
}
