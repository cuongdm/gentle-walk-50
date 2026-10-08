import Testing
@testable import GentleWalkCore

@Suite struct OnboardingProfileTests {
    func answers(goals: [Goal] = [], activity: ActivityAnswer? = .shortWalks, chair: ChairAnswer = .hard,
                 barriers: [Barrier] = [], name: String? = "Margaret", limits: Set<BodyLimit> = []) -> OnboardingAnswers {
        OnboardingAnswers(goals: goals, barriers: barriers, name: name, activity: activity, stairs: .littleTired,
                          chair: chair, limits: limits)
    }

    /// Plan 08/10/2026 task 2.1: one main goal; with none picked, "Not sure yet".
    @Test func primaryGoalIsTheOnlyGoal() {
        #expect(OnboardingProfile.make(answers: answers(goals: [.steadier])).primaryGoal == .steadier)
        #expect(OnboardingProfile.make(answers: answers(goals: [])).primaryGoal == .notSure)
        // Older profiles saved two goals: the first one picked stays the main one.
        #expect(OnboardingProfile.make(answers: answers(goals: [.chairs, .moreEnergy])).primaryGoal == .chairs)
    }

    /// "How active are you now?" is used (owner 08/10/2026): "I mostly sit" starts gentle and shorter.
    @Test func mostlySitStartsGentleAndShorter() {
        let sitter = OnboardingProfile.make(answers: answers(activity: .mostlySit))
        #expect(sitter.startIntensity == .gentle)
        #expect(sitter.startsShorter)
        for activity in [ActivityAnswer.shortWalks, .walkMostDays, .exerciseRegularly] {
            let profile = OnboardingProfile.make(answers: answers(activity: activity))
            #expect(profile.startIntensity == .steady)
            #expect(!profile.startsShorter)
        }
        // No answer (older profiles): the usual steady start.
        #expect(OnboardingProfile.make(answers: answers(activity: nil)).startIntensity == .steady)
        #expect(OnboardingProfile.startIntensity(for: .mostlySit) == .gentle)
        #expect(OnboardingProfile.startsShorter(for: .walkMostDays) == false)
    }

    @Test func activeEasyChairStandingStartsInPlace() {
        #expect(OnboardingProfile.make(answers: answers(activity: .walkMostDays, chair: .easy)).startLevel == .inPlace)
        #expect(OnboardingProfile.make(answers: answers(activity: .walkMostDays, chair: .easy, limits: [.unsteady])).startLevel == .seated)
    }

    @Test func mostlySittingOrNoChairStandStartsSeated() {
        #expect(OnboardingProfile.make(answers: answers(activity: .mostlySit, chair: .easy)).startLevel == .seated)
        #expect(OnboardingProfile.make(answers: answers(activity: .walkMostDays, chair: .notPossible)).startLevel == .seated)
    }

    @Test func walkingMostDaysAndEasyChairStandStartsInPlace() {
        #expect(OnboardingProfile.make(answers: answers(activity: .walkMostDays, chair: .easy)).startLevel == .inPlace)
        #expect(OnboardingProfile.make(answers: answers(activity: .exerciseRegularly, chair: .easy)).startLevel == .inPlace)
        // Standing being hard always keeps the seated start.
        #expect(OnboardingProfile.make(answers: answers(activity: .walkMostDays, chair: .easy, limits: [.standingIsHard])).startLevel == .seated)
        // "I feel unsteady on my feet" starts seated too (review 06/10/2026 Q3).
        #expect(OnboardingProfile.make(answers: answers(activity: .walkMostDays, chair: .easy, limits: [.unsteady])).startLevel == .seated)
        #expect(OnboardingProfile.make(answers: answers(activity: .shortWalks, chair: .easy)).startLevel == .seated)
    }

    @Test func firstBarrierPicksTheUnderstandingScreen() {
        let profile = OnboardingProfile.make(answers: answers(barriers: [.charged, .joints]))
        #expect(profile.understandingKey == .charged)
        #expect(OnboardingProfile.make(answers: answers(barriers: [])).understandingKey == .notSure)
    }

    /// Two "why" lines on the compact plan screen (task 2.10): barriers first, then the pocket line.
    @Test func whyLinesFollowBarriersThenPocket() {
        #expect(OnboardingProfile.make(answers: answers(barriers: [.tooFast, .busy])).whyKeys == [.barrier(.tooFast), .barrier(.busy)])
        #expect(OnboardingProfile.make(answers: answers(barriers: [.joints, .tooFast, .busy, .bored])).whyKeys
                == [.barrier(.joints), .barrier(.tooFast)])
        // Fewer than two picks: add the default line.
        #expect(OnboardingProfile.make(answers: answers(barriers: [.joints])).whyKeys == [.barrier(.joints), .pocket])
        #expect(OnboardingProfile.make(answers: answers(barriers: [])).whyKeys == [.barrier(.notSure), .pocket])
    }

    @Test func emptyNameMeansNoNameInCopy() {
        #expect(OnboardingProfile.make(answers: answers(name: "  ")).displayName == nil)
        #expect(OnboardingProfile.make(answers: answers(name: nil)).displayName == nil)
        #expect(OnboardingProfile.make(answers: answers(name: " Margaret ")).displayName == "Margaret")
    }
}
