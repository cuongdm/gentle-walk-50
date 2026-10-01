/// One walking move, chair move, stretch pose or balance exercise. Copy comes from docs/scripts
/// (D-min-texts.md §D5, A10-stretch.md §2 and §8); built by tools/content/build_content.py.
public struct Exercise: Codable, Equatable, Identifiable, Sendable {
    public enum Kind: String, Codable, Sendable { case walk, move, stretch, balance }
    /// How the player measures the exercise: counted reps, a timer, or a held pose (stretch).
    public enum Counting: String, Codable, Sendable { case reps, timed, hold }

    /// Screen text for a body limit (S06 chip) that changes how the exercise is done (D5 chip table).
    public struct LimitNote: Codable, Equatable, Sendable {
        public var limit: BodyLimit
        public var text: String

        public init(limit: BodyLimit, text: String) {
            self.limit = limit; self.text = text
        }
    }

    public var id: String
    public var kind: Kind
    public var name: String
    /// Everyday purpose line shown under the name ("For getting up from chairs").
    public var purpose: String
    public var tips: [String]
    public var easier: String
    /// Stretches have no harder version (spec S12b).
    public var harder: String?
    /// Looping clip in the app bundle (walks: the "In place" clip). Named even before the file
    /// arrives; the player shows a still picture while it is missing.
    public var videoFile: String?
    /// Walks only: the clip for the Seated level.
    public var videoSeated: String?
    /// Clip for the easier version (slowed from the same source, or another pose).
    public var videoEasy: String?
    /// Clip that loops while a pose is held (breathing only); without it the clip rests on its hold frame.
    public var videoHold: String?
    /// The move done another way (heel and toe raises standing behind the chair, as in Balance).
    public var videoAlt: String?
    /// Clips of this exercise that come in a later batch: missing ones are expected, not errors.
    public var videoLater: [String]?
    public var counting: Counting
    /// True when the exercise is done standing (needs the "Stand behind your chair" screen).
    public var standing: Bool
    /// Body limits (S06) for which this exercise is never offered.
    public var hiddenFor: [BodyLimit]
    /// Body limits (S06) for which the easier version is used by default.
    public var easierFor: [BodyLimit]
    /// Screen notes for body limits that change the exercise ("Keep your knees well below your hips").
    public var limitNotes: [LimitNote]?
    /// Public sources (codes of docs/research/2026-09-30-exercise-standards.md §9, e.g. "S9 p.58").
    public var source: String?

    public init(
        id: String, kind: Kind, name: String, purpose: String, tips: [String], easier: String,
        harder: String? = nil, videoFile: String? = nil, videoSeated: String? = nil, videoEasy: String? = nil,
        videoHold: String? = nil, videoAlt: String? = nil, videoLater: [String]? = nil, counting: Counting, standing: Bool,
        hiddenFor: [BodyLimit] = [], easierFor: [BodyLimit] = [], limitNotes: [LimitNote]? = nil, source: String? = nil
    ) {
        self.id = id; self.kind = kind; self.name = name; self.purpose = purpose; self.tips = tips
        self.easier = easier; self.harder = harder; self.videoFile = videoFile; self.videoSeated = videoSeated
        self.videoEasy = videoEasy; self.videoHold = videoHold; self.videoAlt = videoAlt; self.videoLater = videoLater
        self.counting = counting; self.standing = standing; self.hiddenFor = hiddenFor; self.easierFor = easierFor
        self.limitNotes = limitNotes; self.source = source
    }

    /// The first note for one of her limits, shown under the tips.
    public func note(for limits: Set<BodyLimit>) -> String? {
        limitNotes?.first { limits.contains($0.limit) }?.text
    }
}

/// The chips on onboarding screen S06 "Anything we should go easy on?".
public enum BodyLimit: String, Codable, CaseIterable, Sendable {
    case knees, hips, lowerBack, shoulders, noFloor, standingIsHard, dizzy, jointReplacement, noJumping
}
