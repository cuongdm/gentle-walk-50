import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

/// Word budgets of the new onboarding (plan 08/10/2026 task 2.3): titles at most 8 words, the coach's
/// hints at most 15 and replies at most 14 (two lines in the fixed slot on an iPhone SE), short answer
/// labels, and none of the banned words or medical claims.
@MainActor @Suite struct OnboardingCopyBudgetTests {
    private func words(_ text: LocalizedStringResource) -> Int {
        String(localized: text).split(whereSeparator: \.isWhitespace).count
    }

    @Test func titlesAtMostEightWords() {
        for step in OnboardingStep.questions {
            let title = OnboardingCopy.title(step)
            #expect(words(title) <= 8, "\(String(localized: title))")
            #expect(words(title) > 0)
        }
    }

    @Test func hintsAtMostFifteen() {
        for hint in OnboardingCopy.allHints {
            #expect(words(hint) <= 15, "\(String(localized: hint))")
            #expect(words(hint) > 0)
        }
    }

    /// At most 14 words, and short enough (60 characters) for two lines beside the coach's face on an SE.
    @Test func repliesAtMostFourteen() {
        for reply in OnboardingCopy.allReplies {
            #expect(words(reply) <= 14, "\(String(localized: reply))")
            #expect(String(localized: reply).count <= 60, "\(String(localized: reply))")
        }
    }

    /// Notebook rows keep one line on an SE; body cards at most four short words (two lines in a half card).
    @Test func optionLabelsStayShort() {
        for barrier in Barrier.allCases { #expect(words(OnboardingCopy.title(barrier)) <= 5) }
        for answer in ActivityAnswer.allCases { #expect(words(OnboardingCopy.title(answer)) <= 4) }
        for answer in ChairAnswer.allCases { #expect(words(OnboardingCopy.title(answer)) <= 4) }
        for limit in BodyLimit.allCases { #expect(words(OnboardingCopy.chip(limit)) <= 4, "\(limit)") }
        // Goals keep their full words (Claude Design "Main goal"): at most 6, the way out ("Not sure yet,
        // I just want to start") at most 8.
        for goal in Goal.allCases { #expect(words(OnboardingCopy.title(goal)) <= (goal == .notSure ? 8 : 6), "\(goal)") }
    }

    /// The banned words of app-context.md and the medical claims of tools/lint/copy_lint.py.
    @Test func noBannedWords() throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let context = try String(contentsOf: root.appendingPathComponent("app-context.md"), encoding: .utf8)
        let line = try #require(context.split(separator: "\n").first { $0.hasPrefix("- Banned:") })
        let banned = line.dropFirst("- Banned:".count).split(separator: ";")[0].split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }.filter { !$0.isEmpty }
        let claims = ["cure", "treat", "prevent", "fall risk", "arthritis", "pain relief", "relieve", "bone density"]
        let texts = OnboardingCopy.allHints + OnboardingCopy.allReplies + OnboardingStep.questions.map(OnboardingCopy.title)
            + Goal.allCases.map(OnboardingCopy.planLine) + Goal.allCases.map(PaywallModel.goalTitle)
        for text in texts.map({ String(localized: $0).lowercased() }) {
            for term in banned + claims {
                let pattern = "\\b" + NSRegularExpression.escapedPattern(for: term) + "(s|es|ed|ing)?\\b"
                #expect(text.range(of: pattern, options: .regularExpression) == nil, "\(term) in \(text)")
            }
        }
    }
}
