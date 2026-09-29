/// One chair move or stretch pose. Copy comes from docs/scripts (A4 in V-exercise-clips.md, A10-stretch.md, D-min-texts.md §D5).
public struct Exercise: Codable, Equatable, Identifiable, Sendable {
    public enum Kind: String, Codable, Sendable { case move, stretch }
    /// How the player measures the exercise: counted reps, a timer, or a held pose (stretch).
    public enum Counting: String, Codable, Sendable { case reps, timed, hold }

    public var id: String
    public var kind: Kind
    public var name: String
    /// Everyday purpose line shown under the name ("For getting up from chairs").
    public var purpose: String
    public var tips: [String]
    public var easier: String
    /// Stretches have no harder version (spec S12b).
    public var harder: String?
    /// Looping clip file name in the app bundle; nil until the clip exists (still frame placeholder).
    public var videoFile: String?
    public var counting: Counting
    /// True when the exercise is done standing (needs the "Stand behind your chair" screen).
    public var standing: Bool
    /// Body limits (S06) for which this exercise is never offered.
    public var hiddenFor: [BodyLimit]
    /// Body limits (S06) for which the easier version is used by default.
    public var easierFor: [BodyLimit]
    /// Public source code for stretches (see A10-stretch.md §1), e.g. "NHS-LPT".
    public var source: String?

    public init(
        id: String, kind: Kind, name: String, purpose: String, tips: [String], easier: String,
        harder: String? = nil, videoFile: String? = nil, counting: Counting, standing: Bool,
        hiddenFor: [BodyLimit] = [], easierFor: [BodyLimit] = [], source: String? = nil
    ) {
        self.id = id; self.kind = kind; self.name = name; self.purpose = purpose; self.tips = tips
        self.easier = easier; self.harder = harder; self.videoFile = videoFile; self.counting = counting
        self.standing = standing; self.hiddenFor = hiddenFor; self.easierFor = easierFor; self.source = source
    }
}

/// The chips on onboarding screen S06 "Anything we should go easy on?".
public enum BodyLimit: String, Codable, CaseIterable, Sendable {
    case knees, hips, lowerBack, shoulders, noFloor, standingIsHard, dizzy, jointReplacement, noJumping
}
