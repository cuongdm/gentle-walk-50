import SwiftUI
import Foundation
import GentleWalkCore

/// Onboarding words from the spec (S01–S07) and docs/scripts/D-min-texts.md (D2, D3).
enum OnboardingCopy {
    static func title(_ goal: Goal) -> LocalizedStringResource {
        switch goal {
        case .lessPain: "Move with less pain"
        case .steadier: "Feel steadier on my feet"
        case .loseWeight: "Lose some weight"
        case .moreEnergy: "Have more energy"
        case .chairs: "Get up from chairs more easily"
        case .grandkids: "Keep up with the grandkids"
        case .notSure: "Not sure yet, I just want to start"
        }
    }

    static func symbol(_ goal: Goal) -> String {
        switch goal {
        case .lessPain: "heart"
        case .steadier: "figure.stand"
        case .loseWeight: "figure.walk"
        case .moreEnergy: "sun.max"
        case .chairs: "chair"
        case .grandkids: "figure.2.and.child.holdinghands"
        case .notSure: "sparkles"
        }
    }

    /// A different soft colour per goal, like a set of illustrated icons.
    static func tint(_ goal: Goal) -> Color {
        switch goal {
        case .lessPain: Palette.dangerSoft
        case .steadier, .notSure: Palette.sky
        case .moreEnergy, .grandkids: Palette.accent
        case .loseWeight, .chairs: Palette.secondary
        }
    }

    static func title(_ barrier: Barrier) -> LocalizedStringResource {
        switch barrier {
        case .joints: "My joints hurt"
        case .tooFast: "Videos go too fast"
        case .busy: "I'm busy looking after others"
        case .bored: "I got bored after a few weeks"
        case .charged: "I was charged when I didn't expect it"
        case .notSure: "I'm not sure where to start"
        }
    }

    /// D2: S04 title and two lines by the first barrier picked.
    static func understanding(_ barrier: Barrier) -> (title: LocalizedStringResource, body: LocalizedStringResource) {
        switch barrier {
        case .joints: ("Sore knees don't mean you can't move.",
                       "Every move has a seated version. If something hurts, one tap swaps it for an easier one.")
        case .tooFast: ("You set the pace here.",
                        "A calm voice guides each step, and you can pause anytime. No one is racing you.")
        case .busy: ("You look after everyone. This is for you.",
                     "Five minutes is enough to start. Pick a moment in your day, and we'll keep it there.")
        case .bored: ("Something new every week.",
                      "Walks, chair moves and gentle stretches take turns, and every minute takes you somewhere new.")
        case .charged: ("No surprises with money.",
                        "We'll always show the exact date before you're billed, and remind you before it. You can cancel from Me in a few taps.")
        case .notSure: ("You don't need a plan. We'll bring one.",
                        "Tell us a little about you, and we'll start you somewhere comfortable.")
        }
    }

    /// D3: "Why this will work for you" lines.
    static func why(_ key: WhyKey) -> LocalizedStringResource {
        switch key {
        case .barrier(.joints): "Everything starts seated, and moves are filtered for your joints."
        case .barrier(.tooFast): "Videos went too fast? Here a calm voice sets the pace, and you can pause anytime."
        case .barrier(.busy): "Sessions are 5 to 10 minutes, at the moment of the day you choose."
        case .barrier(.bored): "Your week mixes walks, chair moves and stretches, and your journey keeps moving."
        case .barrier(.charged): "You'll see your billing date today, get a reminder before it, and can cancel anytime from Me."
        case .barrier(.notSure): "We start you at the right level and adjust after every session."
        case .pocket: "You can do it with your phone in your pocket. Just follow the voice."
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

    /// S06 chip labels.
    static func chip(_ limit: BodyLimit) -> LocalizedStringResource {
        switch limit {
        case .knees: "Knees"
        case .hips: "Hips"
        case .lowerBack: "Lower back"
        case .shoulders: "Shoulders"
        case .noFloor: "I can't get down on the floor"
        case .standingIsHard: "Standing for long is hard"
        case .dizzy: "I get dizzy easily"
        case .unsteady: "I feel unsteady on my feet"
        case .jointReplacement: "Joint replacement"
        case .noJumping: "No jumping"
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

    // The coach's short reply under each answer (redesign 03/10/2026): warm, plain, never a promise
    // about health. One line, so it never pushes Continue far down.

    /// After a goal is picked (the last one tapped).
    static func note(_ goal: Goal) -> LocalizedStringResource {
        switch goal {
        case .lessPain: "Got it. Every move starts seated, and one tap swaps anything that hurts."
        case .steadier: "Steadier it is. Balance moves always come with a chair beside you."
        case .loseWeight: "Noted. Short daily walks add up, at your pace."
        case .moreEnergy: "Nice. Even 5 minutes a day is a good start."
        case .chairs: "Good one. Sit-to-stands start with your hands on the chair."
        case .grandkids: "Love that. We build steady stamina, one walk at a time."
        case .notSure: "That works. We start gentle, and you can change anything later."
        }
    }

    /// After the first barrier is picked.
    static func note(_ barrier: Barrier) -> LocalizedStringResource {
        switch barrier {
        case .joints: "Thanks for telling us. Every move has a seated version."
        case .tooFast: "We hear you. Here a calm voice sets the pace."
        case .busy: "Sessions fit around your day, from 5 minutes."
        case .bored: "Your walks move you along real places, so there's always somewhere new."
        case .charged: "We'll always show the exact date before any charge."
        case .notSure: "That's what we're here for. We pick each day for you."
        }
    }

    static let activityNote: LocalizedStringResource = "Thanks. We start you at a comfortable level and grow from there."
    static let chairNote: LocalizedStringResource = "Noted. We'll start you somewhere comfortable."

}
