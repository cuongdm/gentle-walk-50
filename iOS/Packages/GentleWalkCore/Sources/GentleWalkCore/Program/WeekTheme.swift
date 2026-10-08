/// A theme for each week of the 12-week program (plan 3.10; docs/design/research-2026-10-08/
/// icon-va-chong-nham-chan.md §5 #3): a 2–4 word focus shown as a kicker ("WEEK 5 · UP FROM THE CHAIR")
/// and on the Program screen. The layout never changes; only the words do. `title` is the English
/// source: the app shows it through the String Catalog (Vietnamese in docs/i18n/vi/ui-extra-10.json).
public enum WeekTheme: String, CaseIterable, Codable, Sendable {
    case firstSteps, findingYourRhythm, standingTall
    case aLittleMore, upFromTheChair, steadyFeet
    case tryingTheNextStep, turningWithEase, heelAndToe
    case yourOwnRoutine, keepingItGoing, lookingBack

    /// Something that really is new that week; nil weeks show no "New this week" card (honest).
    public enum News: Equatable, Sendable {
        case programStarts
        case stageStarts(ProgramStage)
        case lastWeek
    }

    /// Week 1–12 (outside the range: the nearest end).
    public static func forWeek(_ week: Int) -> WeekTheme {
        allCases[min(max(week, 1), allCases.count) - 1]
    }

    /// The theme for where she is; nil once the 12 weeks are done.
    public static func of(_ position: ProgramPosition) -> WeekTheme? {
        guard case .week(let week, _) = position else { return nil }
        return forWeek(week)
    }

    public var week: Int { (Self.allCases.firstIndex(of: self) ?? 0) + 1 }
    public var stage: ProgramStage { .of(week: week) }

    public var title: String {
        switch self {
        case .firstSteps: "First steps"
        case .findingYourRhythm: "Finding your rhythm"
        case .standingTall: "Standing tall"
        case .aLittleMore: "A little more"
        case .upFromTheChair: "Up from the chair"
        case .steadyFeet: "Steady feet"
        case .tryingTheNextStep: "Trying the next step"
        case .turningWithEase: "Turning with ease"
        case .heelAndToe: "Heel and toe"
        case .yourOwnRoutine: "Your own routine"
        case .keepingItGoing: "Keeping it going"
        case .lookingBack: "Looking back"
        }
    }

    public var newThisWeek: News? {
        switch week {
        case 1: .programStarts
        case 12: .lastWeek
        // The first week of a stage (ProgramStage.of: weeks 1–3, 4–6, 7–9, 10–12).
        default: ProgramStage.of(week: week - 1) != stage ? .stageStarts(stage) : nil
        }
    }
}

