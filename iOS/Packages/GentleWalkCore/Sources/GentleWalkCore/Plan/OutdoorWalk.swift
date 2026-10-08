/// The outdoor walk (review C, 09/10/2026): the standing walk's timing and phases, with only the lines
/// that fit walking along a street. Lines for a chair, a seat, the floor or an in-place move (its intro,
/// the "watch me" demo, "Next up: Side step") are left out, and stretches that need a chair are dropped;
/// the walk ends with its slow cool-down walk and the standing chest stretch with the closing lines.
/// Every outdoor walk opens with the route line (owner 09/10/2026), the one line written for outdoors.
public enum OutdoorWalk {
    /// "Pick a flat, familiar route, and walk at a pace where you can still talk." (A3, owner 09/10/2026).
    public static let routeLine = "a3.open.route"
    /// The route line and a breath, in its own segment before anything else is said.
    public static let routeLineSeconds = 7

    /// Cool-down stretches done standing with nothing to hold.
    public static let standingStretches: Set<String> = ["st.chest"]

    /// In-place move lines that also fit walking: arms swinging with the steps, heel-then-toe landing.
    static let walkingMoveLines: Set<String> = ["a2.move.arms.intro", "a2.move.arms.swing", "a2.move.march.inplace"]

    /// Line prefixes that only make sense indoors: set-up beside the chair, move intros and demos, the
    /// "your turn" lines after a demo.
    static let indoorPrefixes = ["a2.setup.", "a2.move.", "a4.demo.", "a2.now.", "a2.cool.stretch."]

    /// Single indoor lines: heel taps (a seated swap), knees higher on the spot, "by your chair".
    static let indoorLines: Set<String> = ["a1.09", "a1.19", "a11.break.open.2"]

    /// Rotated variants that mention the chair, and the recorded variant of the same family said instead.
    static let replacements: [String: String] = ["a2.brisk.inplace.2": "a2.brisk.inplace.4"]

    public static func isOutdoorLine(_ id: String) -> Bool {
        if walkingMoveLines.contains(id) { return true }
        if indoorLines.contains(id) { return false }
        return !indoorPrefixes.contains { id.hasPrefix($0) }
    }

    /// The walk's segments for outdoors; other blocks (none on an outdoor day) are left as they are.
    public static func adapt(_ plan: SessionPlan) -> SessionPlan {
        var plan = plan
        for b in plan.blocks.indices where plan.blocks[b].kind == .walk {
            plan.blocks[b].segments = plan.blocks[b].segments
                .filter { segment in
                    guard let id = segment.exerciseID, id.hasPrefix("st.") else { return true }
                    return standingStretches.contains(id)
                }
                .map(adapt(segment:))
        }
        if let b = plan.blocks.firstIndex(where: { $0.kind == .walk }),
           !plan.blocks[b].segments.contains(where: { $0.cues.contains { $0.line == routeLine } }) {
            plan.blocks[b].segments.insert(SessionTemplate.Segment(kind: .intro, seconds: routeLineSeconds,
                                                                   cues: [.init(at: 0, line: routeLine)]), at: 0)
        }
        return plan
    }

    public static func adapt(segment: SessionTemplate.Segment) -> SessionTemplate.Segment {
        var segment = segment
        segment.cues.removeAll { !isOutdoorLine($0.line) }
        for c in segment.cues.indices {
            if let line = replacements[segment.cues[c].line] { segment.cues[c].line = line }
        }
        return segment
    }
}
