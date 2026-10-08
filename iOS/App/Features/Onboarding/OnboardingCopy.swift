import SwiftUI
import Foundation
import GentleWalkCore

/// Onboarding words from the spec (S01–S07), docs/scripts/D-min-texts.md (D3) and the plan of 08/10/2026
/// (task 2.3: titles of at most 8 words, short labels, the coach's hints and replies).
enum OnboardingCopy {
    static func title(_ goal: Goal) -> LocalizedStringResource {
        switch goal {
        case .lessPain: "Move with less pain"
        case .steadier: "Feel steadier on my feet"
        case .loseWeight: "Lose some weight"
        case .moreEnergy: "Have more energy"
        case .chairs: "Get up from chairs easily"
        case .grandkids: "Keep up with the grandkids"
        case .notSure: "Not sure yet, just start"
        }
    }

    /// Icons from the shared vocabulary (`AppIcon`, icons-manifest.json): one meaning, one picture.
    static func icon(_ goal: Goal) -> AppIcon {
        switch goal {
        case .lessPain: .lessPain
        case .steadier: .balance
        case .loseWeight: .walk
        case .moreEnergy: .energy
        case .chairs: .chair
        case .grandkids: .grandkids
        case .notSure: .new
        }
    }

    /// The order on the goal step (Claude Design "Main goal", owner 08/10/2026).
    static let goalOrder: [Goal] = [.lessPain, .steadier, .chairs, .moreEnergy, .grandkids, .loseWeight, .notSure]

    /// Short labels, one line in the notebook list on an iPhone SE (plan 08/10/2026 task 2.3).
    static func title(_ barrier: Barrier) -> LocalizedStringResource {
        switch barrier {
        case .joints: "My joints hurt"
        case .tooFast: "Videos go too fast"
        case .busy: "No time for me"
        case .bored: "I got bored"
        case .charged: "Surprise charges"
        case .notSure: "Didn't know where to start"
        }
    }

    static func icon(_ barrier: Barrier) -> AppIcon {
        switch barrier {
        case .joints: .jointsHurt
        case .tooFast: .videosFast
        case .busy: .busy
        case .bored: .bored
        case .charged: .payment
        case .notSure: .help
        }
    }

    /// D3: the two "why" lines on Your plan, one line each on an iPhone SE (Claude Design "Your plan",
    /// plan 08/10/2026 task 2.10).
    static func why(_ key: WhyKey) -> LocalizedStringResource {
        switch key {
        case .barrier(.joints): "Sore joints? Everything starts seated."
        case .barrier(.tooFast): "A calm voice sets the pace. Pause anytime."
        case .barrier(.busy): "5 to 10 minutes, at a moment you choose."
        case .barrier(.bored): "Every walk moves you along a real journey."
        case .barrier(.charged): "You'll see the billing date before any charge."
        case .barrier(.notSure): "We start gently and adjust after each session."
        case .pocket: "Phone in your pocket? Just follow the voice."
        }
    }

    static func title(_ answer: ActivityAnswer) -> LocalizedStringResource {
        switch answer {
        case .mostlySit: "I mostly sit"
        case .shortWalks: "Short walks sometimes"
        case .walkMostDays: "I walk most days"
        case .exerciseRegularly: "I exercise regularly"
        }
    }

    static func title(_ answer: StairsAnswer) -> LocalizedStringResource {
        switch answer {
        case .outOfBreath: "Too out of breath to talk"
        case .littleTired: "A little tired, but I can talk"
        case .fine: "Fine"
        case .severalFlights: "I can do several flights"
        }
    }

    static func title(_ answer: ChairAnswer) -> LocalizedStringResource {
        switch answer {
        case .notPossible: "Not possible right now"
        case .hard: "Hard, but I can"
        case .easy: "Easy"
        }
    }

    /// Body cards on Sore spots and Anything else (and in Me): two short lines at most in a half-width
    /// card on an iPhone SE (plan 08/10/2026 task 2.9).
    static func chip(_ limit: BodyLimit) -> LocalizedStringResource {
        switch limit {
        case .knees: "Knees"
        case .hips: "Hips"
        case .lowerBack: "Lower back"
        case .shoulders: "Shoulders"
        case .jointReplacement: "Joint replacement"
        case .noFloor: "Floor is hard"
        case .standingIsHard: "Standing tires me"
        case .dizzy: "I get dizzy"
        case .unsteady: "Unsteady on my feet"
        case .noJumping: "No jumping"
        }
    }

    /// Two-tone body icons (`LayeredIcon`), drawn for these cards.
    static func icon(_ limit: BodyLimit) -> AppIcon {
        switch limit {
        case .knees: .bodyKnees
        case .hips: .bodyHips
        case .lowerBack: .bodyLowerBack
        case .shoulders: .bodyShoulders
        case .jointReplacement: .bodyJointReplacement
        case .noFloor: .limitFloor
        case .standingIsHard: .limitStandingLong
        case .dizzy: .limitDizzy
        case .unsteady: .limitUnsteady
        case .noJumping: .limitNoJumping
        }
    }

    /// S07 and S20 grey chips: "Easy on knees", "No floor moves".
    static func summary(_ limit: BodyLimit) -> LocalizedStringResource {
        switch limit {
        case .knees: "Easy on knees"
        case .hips: "Easy on hips"
        case .lowerBack: "Easy on lower back"
        case .shoulders: "Easy on shoulders"
        case .noFloor: "No floor moves"
        case .standingIsHard: "Short standing parts"
        case .dizzy: "Steady, no quick turns"
        case .unsteady: "Both hands on the chair"
        case .jointReplacement: "Gentle on replaced joints"
        case .noJumping: "No jumping"
        }
    }

    static let limitOrder: [BodyLimit] = [.knees, .hips, .lowerBack, .shoulders, .noFloor, .standingIsHard, .dizzy,
                                         .unsteady, .jointReplacement, .noJumping]

    static func title(_ moment: DailyMoment) -> LocalizedStringResource {
        switch moment {
        case .coffee: "After my morning coffee"
        case .lunch: "After lunch"
        case .tv: "During evening TV"
        case .custom: "Pick a time"
        }
    }


    // The coach's fixed slot (plan 08/10/2026 tasks 2.3–2.4): a hint of at most 15 words before she
    // answers, then a reply of at most 14 words (two lines on an iPhone SE): warm, plain, never a promise
    // about health. `OnboardingCopyBudgetTests` keeps the budgets.

    static func title(_ step: OnboardingStep) -> LocalizedStringResource {
        switch step {
        case .goal: "What matters most?"
        case .barriers: "What got in the way before?"
        case .name: "What should we call you?"
        case .activity: "How active are you now?"
        case .chair: "Standing up without your hands is…"
        case .soreSpots: "Any sore spots?"
        case .anythingElse: "Anything else we should know?"
        // Not questions: never shown (no empty key in the catalog).
        case .welcome, .plan, .paywall: title(.goal)
        }
    }

    static func hint(_ step: OnboardingStep) -> LocalizedStringResource {
        switch step {
        case .goal: "Pick one. You can change it later in Me."
        case .barriers: "Pick any that fit. No judgment."
        case .name: "Only to say hello. It stays on this phone."
        case .activity: "So the first week fits you."
        case .chair: "It helps us pick where you start."
        case .soreSpots: "Tap all that apply. We'll go easy there."
        case .anythingElse: "Tap all that apply, or None of these."
        case .welcome, .plan, .paywall: hint(.goal)
        }
    }

    /// After the goal is picked.
    static func reply(_ goal: Goal) -> LocalizedStringResource {
        switch goal {
        case .lessPain: "Got it. Every move has a seated version."
        case .steadier: "Steadier it is. Balance moves keep a chair beside you."
        case .loseWeight: "Noted. Short daily walks add up, at your pace."
        case .moreEnergy: "Nice. Even 5 minutes a day is a good start."
        case .chairs: "Good one. Sit-to-stands start with hands on the chair."
        case .grandkids: "Love that. We build stamina one walk at a time."
        case .notSure: "That works. We start gentle; change anything later."
        }
    }

    /// After the first barrier is picked (the old "You're not alone" lines, shortened).
    static func reply(_ barrier: Barrier) -> LocalizedStringResource {
        switch barrier {
        case .joints: "Thanks for telling us. Every move has a seated version."
        case .tooFast: "We hear you. Here a calm voice sets the pace."
        case .busy: "Sessions fit around your day, from 5 minutes."
        case .bored: "Your walks travel real places, always somewhere new."
        case .charged: "We'll always show the date before any charge."
        case .notSure: "That's what we're here for. We plan each day."
        }
    }

    static func reply(_ answer: ActivityAnswer) -> LocalizedStringResource {
        switch answer {
        case .mostlySit: "A gentle, shorter start. Build up at your pace."
        case .shortWalks: "Good. We'll build on those walks, gently."
        case .walkMostDays: "Nice. We'll start where you are and grow."
        case .exerciseRegularly: "Great. Start steady, and go stronger anytime."
        }
    }

    /// "Noted." — no score, no comparison (review D24), in the coach's voice.
    static let chairReply: LocalizedStringResource = "Noted. We'll start you somewhere comfortable."

    /// After the last body card tapped on.
    static func reply(_ limit: BodyLimit) -> LocalizedStringResource {
        switch limit {
        case .knees: "Got it. Moves that are hard on knees stay out."
        case .hips: "Got it. Moves that are hard on hips stay out."
        case .lowerBack: "Got it. Moves that strain the lower back stay out."
        case .shoulders: "Got it. Moves that strain shoulders stay out."
        case .jointReplacement: "Thanks. We'll keep every move gentle on that joint."
        case .noFloor: "Noted. Nothing here needs the floor."
        case .standingIsHard: "Noted. Standing parts stay short, with a seat close by."
        case .dizzy: "Noted. No quick turns, and a steady pace."
        case .unsteady: "Thanks. Balance moves will keep both hands on the chair."
        case .noJumping: "Noted. No session has any jumping."
        }
    }

    static let noSoreSpotsReply: LocalizedStringResource = "Good to hear. You can change this in Me anytime."
    static let noOtherLimitsReply: LocalizedStringResource = "Thanks. Tell us in Me if anything changes."

    /// Under "Your plan, Margaret": her main goal in one line (plan 08/10/2026 task 2.10).
    static func planLine(_ goal: Goal) -> LocalizedStringResource {
        switch goal {
        case .steadier: "For steadier feet, at your own pace."
        case .chairs: "For getting up from chairs more easily."
        case .lessPain: "Gentle moves, each with a seated version."
        case .moreEnergy: "For more energy, one walk at a time."
        case .grandkids: "For keeping up with the grandkids."
        case .loseWeight: "Short daily walks that add up."
        case .notSure: "A gentle start. Change anything later."
        }
    }

    /// Every hint and reply, for the word budgets.
    static var allHints: [LocalizedStringResource] { OnboardingStep.questions.map(hint) }
    static var allReplies: [LocalizedStringResource] {
        Goal.allCases.map(reply) + Barrier.allCases.map(reply) + ActivityAnswer.allCases.map(reply)
            + BodyLimit.allCases.map(reply) + [chairReply, noSoreSpotsReply, noOtherLimitsReply]
    }
}
