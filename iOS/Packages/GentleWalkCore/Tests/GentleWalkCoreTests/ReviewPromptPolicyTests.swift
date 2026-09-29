import Testing
@testable import GentleWalkCore

@Suite struct ReviewPromptPolicyTests {
    func history(asked: Set<ReviewMilestone> = [], sessions: Int = 8) -> ReviewPromptHistory {
        ReviewPromptHistory(askedMilestones: asked, completedSessions: sessions)
    }

    let calmDay = ReviewPromptDay(reportedPain: false, saidTooHard: false)

    @Test(arguments: [ReviewMilestone.finishedNewYork, .sevenActiveDays])
    func asksAtAMilestone(_ milestone: ReviewMilestone) {
        #expect(ReviewPromptPolicy.shouldAsk(milestone: milestone, history: history(), today: calmDay))
    }

    @Test func onlyOncePerMilestone() {
        #expect(!ReviewPromptPolicy.shouldAsk(milestone: .sevenActiveDays, history: history(asked: [.sevenActiveDays]), today: calmDay))
        #expect(ReviewPromptPolicy.shouldAsk(milestone: .finishedNewYork, history: history(asked: [.sevenActiveDays]), today: calmDay))
    }

    @Test func neverOnAHardDay() {
        #expect(!ReviewPromptPolicy.shouldAsk(milestone: .sevenActiveDays, history: history(),
                                              today: ReviewPromptDay(reportedPain: true, saidTooHard: false)))
        #expect(!ReviewPromptPolicy.shouldAsk(milestone: .sevenActiveDays, history: history(),
                                              today: ReviewPromptDay(reportedPain: false, saidTooHard: true)))
    }

    @Test func neverAfterTheFirstSession() {
        #expect(!ReviewPromptPolicy.shouldAsk(milestone: .finishedNewYork, history: history(sessions: 1), today: calmDay))
    }
}
