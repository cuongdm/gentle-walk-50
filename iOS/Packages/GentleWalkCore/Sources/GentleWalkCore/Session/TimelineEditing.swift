/// Changes made while a session is playing (task 2.12).
public enum TimelineEdit: Equatable, Sendable {
    /// This hurts → Show an easier version: the rest of this exercise switches to the easier version.
    case easierVersion(exerciseID: String)
    /// This hurts → Skip, or the Skip control: the rest of the current part is dropped.
    case skip
    /// Outdoors only: the rest becomes an easy walk until the user taps End.
    case walkHomeGently
}

public enum TimelineEditing {
    public static func apply(_ edit: TimelineEdit, to timeline: SessionTimeline, at time: Double) -> SessionTimeline {
        guard let index = timeline.phases.firstIndex(where: { $0.start <= time && time < $0.end }) else { return timeline }
        var result = timeline
        let phase = timeline.phases[index]

        switch edit {
        case .easierVersion(let exerciseID):
            guard phase.exerciseID == exerciseID else { return timeline }
            var rest = phase
            rest.start = time
            rest.isEasier = true
            if time > phase.start {
                result.phases[index].end = time
                result.phases.insert(rest, at: index + 1)
            } else {
                result.phases[index] = rest
            }
            result.voice.removeAll { $0.start >= time && $0.start < phase.end }
            result.insertEditLine("a7.hurt.easier", at: time)

        case .skip:
            let cut = phase.end - time
            result.phases[index].end = time
            for k in result.phases.indices where k > index {
                result.phases[k].start -= cut
                result.phases[k].end -= cut
            }
            result.voice.removeAll { $0.start >= time && $0.start < phase.end }
            for k in result.voice.indices where result.voice[k].start >= phase.end { result.voice[k].start -= cut }
            result.bells.removeAll { $0.at >= time && $0.at < phase.end }
            for k in result.bells.indices where result.bells[k].at >= phase.end { result.bells[k].at -= cut }
            result.total -= cut
            result.insertEditLine("a7.hurt.skip", at: time)

        case .walkHomeGently:
            result.phases = Array(timeline.phases[..<index])
            if time > phase.start {
                var done = phase
                done.end = time
                result.phases.append(done)
            }
            result.phases.append(.init(kind: .easy, block: .walk, exerciseID: nil, start: time, end: .infinity, isEasier: false))
            result.voice.removeAll { $0.start >= time }
            result.bells.removeAll { $0.at >= time }
            result.total = time
            result.isOpenEnded = true
            result.insertEditLine("a3.home.1", at: time)
        }
        return result
    }
}

extension SessionTimeline {
    /// Adds an edit line at `time` (it may cut in on a line already playing) and pushes later lines
    /// so nothing talks over it.
    mutating func insertEditLine(_ id: String, at time: Double) {
        guard var cue = editLines[id] else { return }
        cue.start = time
        voice.append(cue)
        voice.sort { ($0.start, $0.lineID == id ? 0 : 1) < ($1.start, $1.lineID == id ? 0 : 1) }
        if let position = voice.firstIndex(where: { $0.lineID == id && $0.start == time }) {
            normalizeVoice(from: position + 1)
        }
    }
}
