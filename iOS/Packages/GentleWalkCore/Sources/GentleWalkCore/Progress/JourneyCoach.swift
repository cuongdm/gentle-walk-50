/// The coach's line when she reaches a stop (A8: New York in A-min-support.md, the Pro journeys in
/// A8-journeys.md): `a8.<route>.<stop number>`, one line per stop. Nil when the content has none.
public enum JourneyCoach {
    /// "jr.smoky" → "smoky".
    public static func route(of journeyID: String) -> String {
        journeyID.hasPrefix("jr.") ? String(journeyID.dropFirst(3)) : journeyID
    }

    public static func lineID(journeyID: String, stopIndex: Int, content: ContentBundle) -> String? {
        let id = "a8.\(route(of: journeyID)).\(stopIndex + 1)"
        return content.voiceLines.contains { $0.id == id } ? id : nil
    }

    /// The line said on Complete when a session reached new stops (their postcards open then): the
    /// furthest of them, so a session that reaches two stops says one line. Nil when none is new.
    public static func arrivalLineID(journey: Journey, unlocked: [Journey.Stop.ID], content: ContentBundle) -> String? {
        let reached = Set(unlocked)
        guard let index = journey.stops.lastIndex(where: { reached.contains($0.id) }) else { return nil }
        return lineID(journeyID: journey.id, stopIndex: index, content: content)
    }
}
