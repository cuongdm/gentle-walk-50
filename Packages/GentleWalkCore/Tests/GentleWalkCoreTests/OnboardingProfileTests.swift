import Testing
@testable import GentleWalkCore

@Suite struct OnboardingProfileTests {
    func answers(activity: ActivityAnswer = .shortWalks, chair: ChairAnswer = .hard, barriers: [Barrier] = [],
                 name: String? = "Margaret", limits: Set<BodyLimit> = []) -> OnboardingAnswers {
        OnboardingAnswers(goals: [], barriers: barriers, name: name, activity: activity, stairs: .littleTired,
                          chair: chair, limits: limits)
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
        #expect(OnboardingProfile.make(answers: answers(activity: .shortWalks, chair: .easy)).startLevel == .seated)
    }

    @Test func firstBarrierPicksTheUnderstandingScreen() {
        let profile = OnboardingProfile.make(answers: answers(barriers: [.charged, .joints]))
        #expect(profile.understandingKey == .charged)
        #expect(OnboardingProfile.make(answers: answers(barriers: [])).understandingKey == .notSure)
    }

    @Test func whyLinesFollowTheBarriersTwoToThree() {
        #expect(OnboardingProfile.make(answers: answers(barriers: [.tooFast, .busy])).whyKeys == [.barrier(.tooFast), .barrier(.busy)])
        #expect(OnboardingProfile.make(answers: answers(barriers: [.joints, .tooFast, .busy, .bored])).whyKeys.count == 3)
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
