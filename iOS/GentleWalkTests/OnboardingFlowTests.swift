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
            case .stairs: flow.answers.stairs = .littleTired
            case .chair: flow.answers.chair = .hard
            default: break
            }
            flow.next()
            seen.append(flow.step)
        }
        return seen
    }

    @Test func screensComeInTheSpecOrder() {
        let flow = OnboardingFlow()
        #expect(walkToEnd(flow) == [.welcome, .part1, .goal, .barriers, .understanding, .part2, .name, .activity,
                                    .stairs, .chair, .part3, .body, .plan, .paywall])
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
        flow.answers.stairs = .fine
        flow.answers.chair = .easy
        flow.toggleLimit(.knees)
        flow.chooseMoment(.lunch)
        let profile = try flow.finish(into: container.mainContext, now: Date(timeIntervalSince1970: 1_790_000_000))
        #expect(profile.name == "Margaret")
        #expect(profile.goals == ["steadier"])
        #expect(profile.barriers == ["charged", "joints"])
        #expect(profile.startLevel == "inplace")
        #expect(profile.bodyLimits == ["knees"])
        #expect(profile.reminderMoment == "lunch")
        #expect(profile.reminderMinutes == 13 * 60)
        #expect(profile.restDays == [7, 1])
        #expect(profile.onboardingCompleted)
        #expect(try container.mainContext.fetch(FetchDescriptor<UserProfile>()).count == 1)
        #expect(flow.profile.understandingKey == .charged)
    }
}
