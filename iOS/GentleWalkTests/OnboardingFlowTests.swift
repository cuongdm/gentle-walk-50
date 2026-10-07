import Foundation
import SwiftData
import Testing
import GentleWalkCore
@testable import GentleWalk

@MainActor @Suite(.serialized) struct OnboardingFlowTests {
    let container = try! ModelContainerFactory.make(inMemory: true)

    /// Walks forward, answering whatever each screen needs.
    func walkToEnd(_ flow: OnboardingFlow) -> [OnboardingStep] {
        var seen = [flow.step]
        // Bounded: a flow that stops advancing must fail the test, not hang it.
        for _ in 0..<OnboardingStep.allCases.count where flow.step != .paywall {
            switch flow.step {
            case .goal: flow.toggleGoal(.steadier)
            case .activity: flow.answers.activity = .shortWalks
            case .chair: flow.answers.chair = .hard
            default: break
            }
            flow.next()
            seen.append(flow.step)
        }
        return seen
    }

    /// Owner 01/10/2026: no part intros, no stairs question.
    @Test func screensComeInTheSpecOrder() {
        let flow = OnboardingFlow()
        #expect(walkToEnd(flow) == [.welcome, .goal, .barriers, .understanding, .name, .activity, .chair, .body,
                                    .plan, .paywall])
    }

    /// Review M6 (02/10/2026): the bar never starts at 0 and grows to full on the plan.
    @Test func progressNeverStartsAtZero() {
        let flow = OnboardingFlow()
        var values: [Double] = []
        for step in [OnboardingStep.goal, .barriers, .understanding, .name, .activity, .chair, .body, .plan] {
            flow.jump(to: step)
            values.append(flow.progress)
        }
        #expect(values.first! > 0)
        #expect(values.last == 1)
        #expect(values == values.sorted())
    }

    @Test func progressLabelNamesThePartAndStep() {
        let flow = OnboardingFlow()
        flow.jump(to: .name)
        #expect(flow.progressLabel == "Part 2 of 3 · About you")
        flow.jump(to: .goal)
        #expect(flow.progressLabel == "Part 1 of 3 · Your goal")
        flow.jump(to: .body)
        #expect(flow.progressLabel == "Part 3 of 3 · Your body")
        flow.jump(to: .plan)
        #expect(flow.progressLabel == nil)
    }

    @Test func backReturnsToThePreviousScreen() {
        let flow = OnboardingFlow()
        flow.jump(to: .barriers)
        flow.back()
        #expect(flow.step == .goal)
        flow.jump(to: .welcome)
        flow.back()
        #expect(flow.step == .welcome)
    }

    /// Owner 30/09/2026: typed times keep their minutes; + and − go to the next :00, :15, :30, :45.
    @Test func reminderStepsSnapToQuarterHours() {
        #expect(ReminderTime.step(8 * 60 + 30, by: 1) == 8 * 60 + 45)
        #expect(ReminderTime.step(8 * 60 + 37, by: 1) == 8 * 60 + 45)
        #expect(ReminderTime.step(8 * 60 + 37, by: -1) == 8 * 60 + 30)
        #expect(ReminderTime.step(8 * 60 + 45, by: 1) == 9 * 60)
        #expect(ReminderTime.step(9 * 60, by: -1) == 8 * 60 + 45)
        #expect(ReminderTime.step(23 * 60 + 50, by: 1) == 23 * 60 + 50)
        #expect(ReminderTime.step(5, by: -1) == 0)
    }

    @Test func goalsAreLimitedToTwo() {
        let flow = OnboardingFlow()
        flow.toggleGoal(.lessPain)
        flow.toggleGoal(.steadier)
        #expect(!flow.showsGoalLimit)
        flow.toggleGoal(.moreEnergy)
        #expect(flow.answers.goals == [.lessPain, .steadier])
        // A third tap says why nothing changed (clarity review D23).
        #expect(flow.showsGoalLimit)
        flow.toggleGoal(.lessPain)
        #expect(!flow.showsGoalLimit)
        #expect(flow.answers.goals == [.steadier])
    }

    /// Review M7 (02/10/2026): "Not sure yet" is the way out and stands alone.
    @Test func notSureStandsAlone() {
        let flow = OnboardingFlow()
        flow.toggleGoal(.lessPain)
        flow.toggleGoal(.notSure)
        #expect(flow.answers.goals == [.notSure])
        flow.toggleGoal(.steadier)
        #expect(flow.answers.goals == [.steadier])
    }

    @Test func continueWithoutAGoalAsksForOne() {
        let flow = OnboardingFlow()
        flow.jump(to: .goal)
        flow.next()
        #expect(flow.step == .goal)
        #expect(flow.hint == "Pick at least one.")
        flow.toggleGoal(.chairs)
        #expect(flow.hint == nil)
        flow.next()
        #expect(flow.step == .barriers)
    }

    @Test func noneOfTheseClearsBodyLimits() {
        let flow = OnboardingFlow()
        flow.toggleLimit(.knees)
        flow.toggleLimit(.noFloor)
        flow.chooseNoLimits()
        #expect(flow.answers.limits.isEmpty)
        #expect(flow.noLimitsChosen)
        flow.toggleLimit(.hips)
        #expect(!flow.noLimitsChosen)
    }

    @Test func finishingSavesTheProfile() throws {
        let flow = OnboardingFlow()
        flow.toggleGoal(.steadier)
        flow.toggleBarrier(.charged)
        flow.toggleBarrier(.joints)
        flow.nameText = " Margaret "
        flow.answers.activity = .walkMostDays
        flow.answers.chair = .easy
        flow.toggleLimit(.knees)
        let profile = try flow.finish(into: container.mainContext, now: Date(timeIntervalSince1970: 1_790_000_000))
        #expect(profile.name == "Margaret")
        #expect(profile.goals == ["steadier"])
        #expect(profile.barriers == ["charged", "joints"])
        #expect(profile.startLevel == "inplace")
        #expect(profile.bodyLimits == ["knees"])
        // The moment is picked on S16; onboarding saves "after my morning coffee", 8:30 AM.
        #expect(profile.reminderMoment == "coffee")
        #expect(profile.reminderMinutes == 8 * 60 + 30)
        #expect(profile.stairsAnswer == "")
        #expect(profile.restDays == [7, 1])
        #expect(profile.onboardingCompleted)
        #expect(try container.mainContext.fetch(FetchDescriptor<UserProfile>()).count == 1)
        #expect(flow.profile.understandingKey == .charged)
    }

    /// The two groups on S06 and in Me hold every body limit exactly once (owner 01/10 layout).
    @Test func bodyLimitGroupsCoverEveryLimitOnce() {
        let grouped = BodyLimitChips.joints + BodyLimitChips.everyday
        #expect(Set(grouped) == Set(OnboardingCopy.limitOrder))
        #expect(grouped.count == OnboardingCopy.limitOrder.count)
    }
}
