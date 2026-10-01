/// Builds a day's session from content templates (task 2.8; content plan 30/09/2026): walk by level
/// and intensity, chair moves in frames with rotation, stretch days, the cool-down set and the extras.
/// Body limits drop hidden exercises and swap in safer lines; voice variants rotate by day.
public enum SessionBuilder {
    public struct MissingTemplate: Error, Equatable { public var id: String }

    /// Template variants picked from "All sessions" (SessionPreset.variant).
    public enum Variant {
        public static let commercial = "commercial"
        public static let balance = "balance"
        public static let morning = "morning"
    }

    /// Chair move library for an intensity: one ready segment per move (`ses.moves.<intensity>`).
    public static func moveLibraryID(for intensity: Intensity) -> String { "ses.moves.\(intensity.rawValue)" }

    public static func build(kind day: PlannedDay, level: WalkLevel, intensity: Intensity, limits: Set<BodyLimit>,
                             rotationIndex: Int, content: ContentBundle, variant: String? = nil) throws -> SessionPlan {
        let allowed = Set(BodyLimitFilter.allowed(content.exercises, limits: limits).map(\.id))
        let context = Context(limits: limits, rotationIndex: rotationIndex, allowed: allowed, content: content,
                              table: VoiceRotation.Table(lines: content.voiceLines))
        var plan = SessionPlan()

        switch day.main {
        case nil:
            return plan
        case .walk, .longWalk:
            let pace = variant ?? (day.main == .longWalk && intensity != .gentle ? "long" : intensity.rawValue)
            var walk = try context.segments(of: "ses.walk.\(level.rawValue).\(pace)")
            let movesAfter = day.chairMoves > 0
            // A cool-down stretch set follows the chair moves: the walk keeps only its slow walking.
            if movesAfter && day.cooldown { walk.removeAll { $0.kind == .cooldown && $0.exerciseID?.hasPrefix("st.") == true } }
            plan.blocks.append(.init(kind: .walk, segments: walk))
            if movesAfter {
                let moves = try ChairSessionPlanner.afterWalk(count: day.chairMoves, context: context)
                plan.blocks.append(.init(kind: .chair, segments: moves))
                if day.cooldown {
                    let standing = level != .seated && !limits.contains(.standingIsHard)
                    plan.blocks.append(.init(kind: .cooldown, segments: try context.segments(of: standing ? "ses.cooldown.stand" : "ses.cooldown")))
                }
            }
        case .chair:
            if variant == Variant.balance {
                plan.blocks.append(.init(kind: .chair, segments: try context.segments(of: "ses.balance.\(intensity.rawValue)")))
            } else {
                plan.blocks.append(.init(kind: .chair, segments: try ChairSessionPlanner.chairDay(intensity: intensity, context: context)))
                plan.blocks.append(.init(kind: .cooldown, segments: try context.segments(of: "ses.chair.close")))
            }
        case .stretch:
            if variant == Variant.morning {
                plan.blocks.append(.init(kind: .stretch, segments: try context.segments(of: "ses.morning")))
            } else {
                let standing = level != .seated && !limits.contains(.standingIsHard)
                let id = "ses.stretch.\(standing ? "standing" : "seated").\(intensity.rawValue)"
                plan.blocks.append(.init(kind: .stretch, segments: try context.segments(of: id)))
                plan.holdSeconds = intensity.stretchHoldSeconds
            }
        }

        plan.easierExerciseIDs = Set(BodyLimitFilter.allowed(content.exercises, limits: limits)
            .filter { plan.exerciseIDs.contains($0.id) && BodyLimitFilter.startsEasier($0, limits: limits) }.map(\.id))
        return plan
    }

    static func template(_ id: String, in content: ContentBundle) throws -> SessionTemplate {
        guard let template = content.sessions.first(where: { $0.id == id }) else { throw MissingTemplate(id: id) }
        return template
    }

    /// What every template needs to become part of her session.
    struct Context {
        let limits: Set<BodyLimit>
        let rotationIndex: Int
        let allowed: Set<String>
        let content: ContentBundle
        let table: VoiceRotation.Table

        /// A template's segments for her: limits applied, lines rotated for the day.
        func segments(of id: String) throws -> [SessionTemplate.Segment] {
            let template = try SessionBuilder.template(id, in: content)
            return prepare(template.segments, level: template.level)
        }

        /// Drops segments her limits leave out (and a "stand up" pause before a dropped exercise),
        /// then rotates and filters every cue.
        func prepare(_ segments: [SessionTemplate.Segment], level: WalkLevel?) -> [SessionTemplate.Segment] {
            var result: [SessionTemplate.Segment] = []
            for segment in segments {
                let hidden = segment.exerciseID.map { !allowed.contains($0) } ?? false
                if hidden || !segment.applies(to: limits) {
                    if hidden, result.last?.kind == .rest { result.removeLast() }
                    continue
                }
                result.append(prepare(segment, level: level))
            }
            return result
        }

        func prepare(_ segment: SessionTemplate.Segment, level: WalkLevel?) -> SessionTemplate.Segment {
            var copy = segment
            copy.cues = segment.cues.compactMap { cue in
                guard cue.applies(to: limits) else { return nil }
                let line = table.rotate(cue.line, by: rotationIndex, level: level, limits: limits)
                if let known = table.lines[line], !known.fits(level: level, limits: limits) { return nil }
                return SessionTemplate.Cue(at: cue.at, line: line)
            }
            return copy
        }
    }
}
