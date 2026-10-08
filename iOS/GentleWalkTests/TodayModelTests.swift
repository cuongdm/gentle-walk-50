import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

@MainActor @Suite struct TodayModelTests {
    let calendar = { var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(identifier: "America/New_York")!; return c }()

    func at(_ day: Int, _ month: Int = 9, hour: Int = 9) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour))!
    }

    /// Monday Sep 28 2026 at 9 AM, pro, walked the four weekdays before (and not today).
    func input(now: Date? = nil, entitlement: Entitlement = .subscribed, workouts: [TodayInput.Workout]? = nil,
               pains: [PainReportSnapshot] = [], healthConnected: Bool = true, fewerReminders: Bool = false,
               name: String? = "Margaret", trialEnds: Date? = nil) -> TodayInput {
        let history = workouts ?? [22, 23, 24, 25].map { TodayInput.Workout(date: at($0), feeling: .justRight, breakCount: 0, level: .seated) }
        return TodayInput(now: now ?? at(28), calendar: calendar, name: name, restDays: [.saturday, .sunday], limits: [.knees],
                          level: .seated, entitlement: entitlement, trialEnds: trialEnds, workouts: history, pains: pains,
                          healthConnected: healthConnected, suggestFewerReminders: fewerReminders,
                          journeyID: "jr.ny", journeyMiles: 1.8)
    }

    func model(_ input: TodayInput) -> TodayModel { TodayModel(input: input, content: TestFixtures.content) }

    @Test func notWalkedYetShowsCheckInAndAchyPicksGentle() {
        let model = model(input())
        #expect(model.greeting == "Good morning, Margaret")
        #expect(model.showsCheckIn)
        #expect(model.session.kind == .planned)
        model.checkIn(.achy)
        #expect(model.intensity == .gentle)
        #expect(model.session.title.hasPrefix("Gentle walk · "))
    }

    @Test func doneTodayShowsDoneAndExtras() {
        var history = [22, 23, 24, 25].map { TodayInput.Workout(date: at($0), feeling: .justRight, breakCount: 0, level: .seated) }
        history.append(.init(date: at(28, hour: 8), feeling: nil, breakCount: 0, level: .seated))
        let model = model(input(workouts: history))
        #expect(!model.showsCheckIn)
        #expect(model.session.kind == .done)
        #expect(model.session.title == "Done for today")
        #expect(!model.extras.isEmpty && model.extras.count <= 3)
    }

    /// "Not yet" on the First Walk's Up next: Today offers the First Walk, even on a rest day, with no
    /// check-in (it is set: gentle, seated) — owner 01/10/2026.
    @Test func noSessionYetOffersTheFirstWalk() {
        for now in [at(28), at(26)] {
            let model = model(input(now: now, workouts: []))
            #expect(model.session.kind == .planned)
            #expect(model.session.title.hasPrefix("Your first walk · "))
            #expect(model.request?.isFirstWalk == true)
            #expect(!model.showsCheckIn)
            #expect(model.isSeatedWalk)
        }
    }

    @Test func treeRingFillsTowardsTheNextLevel() {
        let history = [22, 23, 24, 25, 28].map { TodayInput.Workout(date: at($0), feeling: .justRight, breakCount: 0, level: .seated) }
        let model = model(input(workouts: history))
        #expect(model.activeDays == 5)
        #expect(abs(model.treeProgress - 5.0 / 7.0) < 0.001)
    }

    // MARK: Try something else (10.5)

    @Test func walkDayOffersChairStretchAndFiveMinutes() {
        let options = model(input()).swapOptions
        #expect(options.map(\.id) == ["chair.gentle", "stretch.seated.gentle", SessionCatalog.justFiveMinutesID])
        #expect(options.last?.title.hasPrefix("Just ") == true)
        #expect(options.first?.title.hasPrefix("Gentle chair moves · ") == true)
        #expect(options.allSatisfy { $0.request.limits.contains(.knees) && $0.request.presetID == $0.id })
    }

    @Test func noSwapOnARestDayOrOnceDone() {
        #expect(model(input(now: at(26))).swapOptions.isEmpty)
        let done = [22, 23, 24, 25, 28].map { TodayInput.Workout(date: at($0), feeling: .justRight, breakCount: 0, level: .seated) }
        #expect(model(input(workouts: done)).swapOptions.isEmpty)
    }

    @Test func freePlanSwapsAreNeverLocked() {
        let options = model(input(entitlement: .free)).swapOptions
        #expect(!options.isEmpty)
        #expect(options.allSatisfy { !$0.isLocked })
    }

    @Test func endedTrialKeepsAFreeWalkAndOffersPlans() {
        let model = model(input(entitlement: .free, trialEnds: at(20)))
        #expect(model.session.title.hasPrefix("Free walk of the day"))
        #expect(model.trialEnded)
        // The note on the card stays a week, then goes (it showed on every open for ever).
        #expect(!model.showsTrialEndedNote)
        #expect(self.model(input(entitlement: .free, trialEnds: at(25))).showsTrialEndedNote)
    }

    @Test func twoMissedDaysOfferAGentleRestart() {
        let history = [22, 23].map { TodayInput.Workout(date: at($0), feeling: .justRight, breakCount: 0, level: .seated) }
        let model = model(input(now: at(28), workouts: history))  // missed Thu, Fri (Sat/Sun rest)
        #expect(model.session.kind == .gentleRestart)
        #expect(model.session.title == "Gentle restart · 5 min")
        #expect(model.welcomeBack == "Welcome back, Margaret. Your journey is right where you left it.")
    }

    @Test func oneSpecialCardAtATimeInPriorityOrder() {
        let pains = [26.0, 27, 28].map { PainReportSnapshot(date: at(Int($0), hour: 7), area: .knees, exerciseID: nil) }
        let brokenBreaks = [22, 23, 24, 25].map { TodayInput.Workout(date: at($0), feeling: .justRight, breakCount: $0 == 25 ? 2 : 0, level: .seated) }
        #expect(model(input(workouts: brokenBreaks, pains: pains, healthConnected: false)).specialCard == .pain(area: .knees))
        #expect(model(input(workouts: brokenBreaks, healthConnected: false)).specialCard == .shorter)
        let tooHard = [23, 24, 25].map { TodayInput.Workout(date: at($0), feeling: .tooHard, breakCount: 0, level: .inPlace) }
        var inPlace = input(workouts: tooHard, healthConnected: false)
        inPlace.level = .inPlace
        #expect(model(inPlace).specialCard == .movedDown(to: .seated))
        #expect(model(input(healthConnected: false)).specialCard == .connectHealth)
        #expect(model(input(fewerReminders: true)).specialCard == .fewerReminders)
        #expect(model(input()).specialCard == nil)
    }

    @Test func showsTrialEndingCardFromDayTen() {
        let ends = at(11, 10, hour: 19)
        #expect(model(input(now: at(6, 10), entitlement: .trial(ends: ends), trialEnds: ends)).trialEndingDate == nil)
        let day10 = model(input(now: at(7, 10), entitlement: .trial(ends: ends), trialEnds: ends))
        #expect(day10.trialEndingDate != nil)
        // The trial card sits on top and does not replace a special card.
        #expect(model(input(now: at(7, 10), entitlement: .trial(ends: ends), healthConnected: false, trialEnds: ends)).specialCard == .connectHealth)
    }

    @Test func noNameMeansNoNameInCopy() {
        let model = model(input(name: nil))
        #expect(model.greeting == "Good morning")
    }

    @Test func weekAndJourneyLines() {
        let model = model(input())
        #expect(model.weekLine == "0 active days this week · 2 rest days are part of the plan")
        // One pattern everywhere (clarity review D17): walked of total, then the next stop.
        #expect(model.journeyLine == "1.8 of 5 mi · 0.4 mi to Times Square")
        #expect(model.journeyTitle == "New York City")
        #expect(model.week.count == 7)
    }

    /// Owner S3 (02/10/2026): once a day is done, "x of y so far"; more than planned counts up.
    @Test func weekLineIsASoftTarget() {
        let monday = [28].map { TodayInput.Workout(date: at($0, hour: 8), feeling: .justRight, breakCount: 0, level: .seated) }
        #expect(model(input(workouts: monday)).weekLine == "1 of 5 active days so far · 2 rest days are part of the plan")
        let everyDay = [27, 28, 29, 30].map { TodayInput.Workout(date: at($0, hour: 8), feeling: .justRight, breakCount: 0, level: .seated) }
            + [1, 2, 3].map { TodayInput.Workout(date: at($0, 10, hour: 8), feeling: .justRight, breakCount: 0, level: .seated) }
        let late = input(now: at(3, 10, hour: 18), workouts: everyDay)
        #expect(model(late).weekLine == "7 active days this week · 2 rest days are part of the plan")
    }

    // MARK: Steady program (task 4.2)

    /// Started Sep 14: Monday Sep 28 is week 3, stage 1.
    @Test func programStripShowsWeekAndStage() {
        var value = input()
        #expect(model(value).programStrip == nil)
        value.program = ProgramRound(start: at(14, hour: 0))
        let strip = model(value).programStrip
        #expect(strip?.kind == .week(3, .base))
        #expect(strip?.title == "Week 3 of 12")
        #expect(strip?.detail == "Stage 1 · Steady base")
        #expect(strip?.pickUpWeek == nil)
        value.programFinishedAt = at(27)
        #expect(model(value).programStrip?.kind == .routine)
    }

    /// Two weeks or more without a session: "Pick up at week N", the week she stopped in.
    @Test func longBreakOffersToPickUp() {
        var value = input(now: at(12, 10), workouts: [TodayInput.Workout(date: at(22), feeling: nil, breakCount: 0, level: .seated)])
        value.program = ProgramRound(start: at(14, hour: 0))
        #expect(model(value).programStrip?.pickUpWeek == 2)
    }

    @Test func checkCardFollowsSchedule() {
        var value = input()
        // After the first session, before any check: the week-0 invite.
        #expect(model(value).checkCard == .invite)
        value.selfChecks = [at(19)]
        let soon = model(value)
        #expect(soon.checkCard == .dueIn(days: 5))
        #expect(soon.checkTitle == "Your 2-week check is in 5 days")
        value.selfChecks = [at(14)]
        #expect(model(value).checkCard == .due)
        // "Later" on the invite: nothing for two days.
        value.selfChecks = []
        value.selfCheckDismissedAt = at(28, hour: 8)
        #expect(model(value).checkCard == nil)
        // No session yet: nothing.
        #expect(model(input(workouts: [])).checkCard == nil)
    }
}

