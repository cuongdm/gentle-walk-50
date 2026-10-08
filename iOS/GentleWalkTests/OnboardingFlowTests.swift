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
            case .goal: flow.chooseGoal(.steadier)
            case .activity: flow.answers.activity = .shortWalks
            case .chair: flow.answers.chair = .hard
            default: break
            }
            flow.next()
            seen.append(flow.step)
        }
        return seen
    }

    /// Plan 08/10/2026 task 2.2: seven questions, no "You're not alone", two body screens.
    @Test func screensComeInTheSpecOrder() {
        let flow = OnboardingFlow()
        #expect(walkToEnd(flow) == [.welcome, .goal, .barriers, .name, .activity, .chair, .soreSpots, .anythingElse,
                                    .plan, .paywall])
    }

    /// Review M6 (02/10/2026): the garden never starts empty and is full on the plan.
    @Test func progressNeverStartsAtZero() {
        let flow = OnboardingFlow()
        var values: [Double] = []
        for step in [OnboardingStep.goal, .barriers, .name, .activity, .chair, .soreSpots, .anythingElse, .plan] {
            flow.jump(to: step)
            values.append(flow.progress)
        }
        #expect(values.first! > 0)
        #expect(values.last == 1)
        #expect(values == values.sorted())
    }

    @Test func stepLabelCountsSeven() {
        let flow = OnboardingFlow()
        flow.jump(to: .goal)
        #expect(flow.stepLabel == "Step 1 of 7")
        #expect(flow.gardenStep == 1)
        flow.jump(to: .name)
        #expect(flow.stepLabel == "Step 3 of 7")
        flow.jump(to: .anythingElse)
        #expect(flow.stepLabel == "Step 7 of 7")
        flow.jump(to: .plan)
        #expect(flow.stepLabel == nil)
        #expect(flow.gardenStep == 7)
        flow.jump(to: .welcome)
        #expect(flow.stepLabel == nil)
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

    /// One main goal (owner 08/10/2026): the new pick replaces the old one.
    @Test func goalIsSingle() {
        let flow = OnboardingFlow()
        flow.chooseGoal(.lessPain)
        flow.chooseGoal(.steadier)
        #expect(flow.answers.goals == [.steadier])
        flow.chooseGoal(.steadier)
        #expect(flow.answers.goals == [.steadier])
        #expect(OnboardingFlow.maxGoals == 1)
    }

    /// Continue says why it can't go on (control states): goal, activity and chair need an answer.
    @Test func continueWithoutAnAnswerSaysWhy() {
        let flow = OnboardingFlow()
        for step in [OnboardingStep.goal, .activity, .chair] {
            flow.jump(to: step)
            flow.next()
            #expect(flow.step == step)
            #expect(flow.continueBlockedReason == "Pick one to continue")
        }
        flow.jump(to: .goal)
        flow.chooseGoal(.chairs)
        #expect(flow.continueBlockedReason == nil)
        flow.next()
        #expect(flow.step == .barriers)
        // Barriers, name and the body screens can be passed without an answer.
        #expect(flow.continueBlockedReason == nil)
    }

    /// "None of these" on each body screen clears only that screen's choices.
    @Test func noneOfTheseOnEachBodyScreen() {
        let flow = OnboardingFlow()
        flow.toggleLimit(.knees)
        flow.toggleLimit(.noFloor)
        flow.chooseNoSoreSpots()
        #expect(flow.answers.limits == [.noFloor])
        #expect(flow.noSoreSpots)
        #expect(!flow.noOtherLimits)
        flow.chooseNoOtherLimits()
        #expect(flow.answers.limits.isEmpty)
        #expect(flow.noOtherLimits)
        flow.toggleLimit(.hips)
        #expect(!flow.noSoreSpots)
        #expect(flow.noOtherLimits)
    }

    /// The coach's slot: a hint first, then a reply to the answer (the first barrier, the last body card).
    @Test func coachHintsThenReplies() {
        let flow = OnboardingFlow()
        flow.jump(to: .barriers)
        #expect(flow.coachLine == .hint(OnboardingCopy.hint(.barriers)))
        flow.toggleBarrier(.charged)
        flow.toggleBarrier(.joints)
        #expect(flow.coachLine == .reply(OnboardingCopy.reply(Barrier.charged)))
        flow.jump(to: .anythingElse)
        flow.toggleLimit(.knees)
        // A sore spot does not answer on Anything else.
        #expect(flow.coachLine?.isReply == false)
        flow.toggleLimit(.unsteady)
        #expect(String(localized: flow.coachLine!.text) == "Thanks. Balance moves will keep both hands on the chair.")
        flow.jump(to: .name)
        flow.nameText = " Margaret "
        #expect(String(localized: flow.coachLine!.text) == "Nice to meet you, Margaret.")
    }

    @Test func finishSavesSingleGoalAndActivity() throws {
        let flow = OnboardingFlow()
        flow.chooseGoal(.lessPain)
        flow.chooseGoal(.steadier)
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
        #expect(profile.activityLevel == "walkMostDays")
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

    /// The two body screens (and Me) hold every body limit exactly once.
    @Test func bodyLimitGroupsCoverEveryLimitOnce() {
        let grouped = BodyLimitChips.soreSpots + BodyLimitChips.everyday
        #expect(Set(grouped) == Set(OnboardingCopy.limitOrder))
        #expect(grouped.count == OnboardingCopy.limitOrder.count)
    }
}
