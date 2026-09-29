/// Builds a day's session from content templates (task 2.8): walk by level and intensity, chair
/// moves rotated by day, stretch poses filtered by body limits, and the cool-down set.
public enum SessionBuilder {
    public struct MissingTemplate: Error, Equatable { public var id: String }

    /// Chair moves in the order they rotate (library template `ses.moves`).
    static let moveLibraryID = "ses.moves"

    public static func build(kind day: PlannedDay, level: WalkLevel, intensity: Intensity, limits: Set<BodyLimit>,
                             rotationIndex: Int, content: ContentBundle) throws -> SessionPlan {
        let allowed = BodyLimitFilter.allowed(content.exercises, limits: limits)
        let allowedIDs = Set(allowed.map(\.id))
        var plan = SessionPlan()

        switch day.main {
        case nil:
            return plan
        case .walk, .longWalk:
            var walk = try template("ses.walk.\(level.rawValue).\(intensity.rawValue)", in: content).segments
            if day.main == .longWalk { walk = addRound(to: walk, level: level) }
            plan.blocks.append(.init(kind: .walk, segments: walk))
            if day.chairMoves > 0 {
                let moves = try pickMoves(day.chairMoves, allowed: allowedIDs, rotationIndex: rotationIndex, content: content)
                plan.blocks.append(.init(kind: .chair, segments: chairBlock(moves, open: "a9.to-chair", close: nil)))
            }
        case .chair:
            let moves = try pickMoves(intensity.chairDayMoves, allowed: allowedIDs, rotationIndex: rotationIndex, content: content)
            plan.blocks.append(.init(kind: .chair, segments: chairBlock(moves, open: "a9.chair.open", close: "a9.chair.close")))
        case .stretch:
            let standing = level != .seated && !limits.contains(.standingIsHard)
            let id = "ses.stretch.\(standing ? "standing" : "seated").\(intensity.rawValue)"
            plan.blocks.append(.init(kind: .stretch, segments: filterPoses(try template(id, in: content).segments, allowed: allowedIDs)))
            plan.holdSeconds = intensity.stretchHoldSeconds
        }

        if day.cooldown {
            let cooldown = filterPoses(try template("ses.cooldown", in: content).segments, allowed: allowedIDs)
            plan.blocks.append(.init(kind: .cooldown, segments: cooldown))
        }

        let counts = VoiceRotation.variantCounts(in: content.voiceLines)
        for b in plan.blocks.indices {
            for s in plan.blocks[b].segments.indices {
                plan.blocks[b].segments[s].cues = plan.blocks[b].segments[s].cues.map {
                    SessionTemplate.Cue(at: $0.at, line: VoiceRotation.rotate($0.line, by: rotationIndex, counts: counts))
                }
            }
        }
        plan.easierExerciseIDs = Set(allowed.filter { plan.exerciseIDs.contains($0.id) && BodyLimitFilter.startsEasier($0, limits: limits) }.map(\.id))
        return plan
    }

    static func template(_ id: String, in content: ContentBundle) throws -> SessionTemplate {
        guard let template = content.sessions.first(where: { $0.id == id }) else { throw MissingTemplate(id: id) }
        return template
    }

    /// `count` allowed moves starting at the rotation index, so consecutive days differ.
    static func pickMoves(_ count: Int, allowed: Set<String>, rotationIndex: Int, content: ContentBundle) throws -> [SessionTemplate.Segment] {
        let library = try template(moveLibraryID, in: content).segments.filter { $0.exerciseID.map(allowed.contains) ?? false }
        guard !library.isEmpty else { return [] }
        return (0..<min(count, library.count)).map { library[(rotationIndex + $0) % library.count] }
    }

    /// Moves with a 20-second rest between them, framed by optional opening and closing lines.
    static func chairBlock(_ moves: [SessionTemplate.Segment], open: String, close: String?) -> [SessionTemplate.Segment] {
        var segments = [SessionTemplate.Segment(kind: .intro, seconds: 8, cues: [.init(at: 0, line: open)])]
        for (index, move) in moves.enumerated() {
            if index > 0 { segments.append(.init(kind: .rest, seconds: 20, cues: [.init(at: 0, line: "a5.rest20")])) }
            segments.append(move)
        }
        if let close { segments.append(.init(kind: .outro, seconds: 8, cues: [.init(at: 0, line: close)])) }
        return segments
    }

    /// Drops poses hidden by body limits, and the "stand up" pause before a dropped standing pose.
    static func filterPoses(_ segments: [SessionTemplate.Segment], allowed: Set<String>) -> [SessionTemplate.Segment] {
        var result: [SessionTemplate.Segment] = []
        for segment in segments {
            if let id = segment.exerciseID, !allowed.contains(id) {
                if result.last?.kind == .rest { result.removeLast() }
                continue
            }
            result.append(segment)
        }
        return result
    }

    /// Long walk (Friday): one more brisk + easy round, copied from the round before the last, with
    /// the "here we go again" opening instead of the first-round set-up line.
    static func addRound(to walk: [SessionTemplate.Segment], level: WalkLevel) -> [SessionTemplate.Segment] {
        let brisks = walk.indices.filter { walk[$0].kind == .brisk }
        guard brisks.count >= 2, let source = brisks.dropLast().last, walk.indices.contains(source + 1) else { return walk }
        var brisk = walk[source]
        let easy = walk[source + 1]
        brisk.cues = brisk.cues.map { cue in
            cue.line.hasPrefix("a2.brisk.\(level.rawValue).") ? .init(at: cue.at, line: "a2.brisk.again.1") : cue
        }
        var result = walk
        result.insert(contentsOf: [brisk, easy], at: brisks.last!)
        return result
    }
}
