import Foundation
import GentleWalkCore

/// The words of the week themes (plan 08/10/2026 tasks 3.5, 3.10). The core's `title` and `line` are the
/// English source; here they are literals so Xcode puts them in the String Catalog (Vietnamese in
/// docs/i18n/vi/ui-extra-10.json and ui-extra-11.json). `TodayCopyTests` keeps them equal to the core.
extension WeekTheme {
    var localizedTitle: LocalizedStringResource {
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

    var localizedLine: LocalizedStringResource {
        switch self {
        case .firstSteps: "Short, easy sessions to learn the moves. Seated is always fine."
        case .findingYourRhythm: "The same moves as last week. Notice when they start to feel familiar."
        case .standingTall: "Sit and stand tall between moves. Look ahead, not down."
        case .aLittleMore: "Stage two starts. A little more, only when the last sessions felt easy."
        case .upFromTheChair: "Sit-to-stands this week: slow down, slow up, hands on the chair if you like."
        case .steadyFeet: "Balance moves: keep your chair close and look at one spot."
        case .tryingTheNextStep: "Stage three starts. Try the harder version once, if it feels right."
        case .turningWithEase: "Turn slowly, in small steps, with your chair or counter in reach."
        case .heelAndToe: "Heel and toe raises: small and easy is perfect."
        case .yourOwnRoutine: "Stage four starts. Keep the days and times that suit you."
        case .keepingItGoing: "Your routine, your pace. Rest days are part of the plan."
        case .lookingBack: "Your last week of the 12. Look back at your checks on Progress."
        }
    }

    /// "Week 3 · Standing tall": the small line over the week card on Today and Program.
    var kicker: String { String(localized: "Week \(week) · \(String(localized: localizedTitle))") }

    /// What really is new this week, or nil (the card then shows the week's focus instead; honest).
    var newsLine: String? {
        switch newThisWeek {
        case .programStarts?: String(localized: "Your 12 weeks start today.")
        case .stageStarts(let stage)?: String(localized: "Stage \(stage.rawValue) starts this week: \(String(localized: stage.title)).")
        case .lastWeek?: String(localized: "Your last week of the 12. Look how far you've come.")
        case nil: nil
        }
    }
}
