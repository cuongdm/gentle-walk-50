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
        #expect(model.greeting == GreetingText.text(Greetings.pick(now: at(28), calendar: calendar), name: "Margaret"))
        #expect(model.greeting.contains("Margaret"))
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
        // The level changed when the feeling was saved (task 0.3): Today shows the stored card.
        var movedDown = input(healthConnected: false)
        movedDown.levelCard = .movedDown(to: .seated)
        #expect(model(movedDown).specialCard == .movedDown(to: .seated))
        var movedUp = input(healthConnected: false)
        movedUp.level = .inPlace
        movedUp.levelCard = .movedUp(to: .inPlace)
        #expect(model(movedUp).specialCard == .movedUp(to: .inPlace))
        movedUp.levelCard = .movedDown(to: .seated)
        #expect(model(movedUp).specialCard == .movedDown(to: .seated))
        #expect(model(input(healthConnected: false)).specialCard == .connectHealth)
        #expect(model(input(fewerReminders: true)).specialCard == .fewerReminders)
        #expect(model(input()).specialCard == nil)
    }

    /// Plan 08/10/2026 task 0.4: Today reads the current level and its card; it no longer works the
    /// level out from the history itself.
    @Test func movedUpCardShowsAfterAChange() {
        var value = input()
        value.level = .inPlace
        value.levelCard = .movedUp(to: .inPlace)
        let model = model(value)
        #expect(model.specialCard == .movedUp(to: .inPlace))
        #expect(model.request?.level == .inPlace)
    }

    @Test func levelDropsBackAfterTooHardAtTheNewLevel() {
        // The store moved her back down: three "Too hard" at In place are in the history, level is Seated.
        let tooHard = [23, 24, 25].map { TodayInput.Workout(date: at($0), feeling: .tooHard, breakCount: 0, level: .inPlace) }
        var value = input(workouts: tooHard)
        value.level = .seated
        value.levelCard = .movedDown(to: .seated)
        #expect(model(value).request?.level == .seated)
        // Old answers alone never move the level on Today (no card, same level).
        let tooEasy = [23, 24, 25].map { TodayInput.Workout(date: at($0), feeling: .tooEasy, breakCount: 0, level: .seated) }
        let plain = model(input(workouts: tooEasy))
        #expect(plain.request?.level == .seated)
        #expect(plain.specialCard == nil)
    }

    @Test func showsTrialEndingCardFromDayTen() {
        let ends = at(11, 10, hour: 19)
        #expect(model(input(now: at(6, 10), entitlement: .trial(ends: ends), trialEnds: ends)).trialEndingDate == nil)
        let day10 = model(input(now: at(7, 10), entitlement: .trial(ends: ends), trialEnds: ends))
        #expect(day10.trialEndingDate != nil)
        // The trial card sits on top and does not replace a special card.
        #expect(model(input(now: at(7, 10), entitlement: .trial(ends: ends), healthConnected: false, trialEnds: ends)).specialCard == .connectHealth)
    }

    /// Review I-1 leftover (08/10/2026): the banner gives four days' notice before billing whatever the
    /// trial length StoreKit offers (day 10 of a 2-week trial, day 3 of a week); a shorter trial shows it
    /// all along.
    @Test func trialEndingCardUsesStoreKitTrialLength() {
        let ends = at(11, 10, hour: 19)
        func card(now: Date, trialDays: Int?) -> Date? {
            var value = input(now: now, entitlement: .trial(ends: ends), trialEnds: ends)
            value.trialDays = trialDays
            return model(value).trialEndingDate
        }
        // A 3-week or a 1-week trial: from Oct 7, four days before billing.
        #expect(card(now: at(7, 10), trialDays: 21) == ends)
        #expect(card(now: at(6, 10), trialDays: 21) == nil)
        #expect(card(now: at(7, 10), trialDays: 7) == ends)
        #expect(card(now: at(6, 10), trialDays: 7) == nil)
        // A 3-day trial started Oct 8: shown from its first day.
        #expect(card(now: at(8, 10), trialDays: 3) == ends)
        // Products not loaded yet (or the offer gone): the 2-week trial the store sells.
        #expect(card(now: at(7, 10), trialDays: nil) == ends)
        #expect(card(now: at(6, 10), trialDays: nil) == nil)
    }

    @Test func noNameMeansNoNameInCopy() {
        let model = model(input(name: nil))
        #expect(model.greeting == Greetings.pick(now: at(28), calendar: calendar).text)
    }

    /// Plan 08/10/2026 task 3.11: a different greeting each morning of the week, by the part of the day.
    @Test func greetingRotates() {
        let mornings = (21...27).map { model(input(now: at($0))).greeting }
        #expect(Set(mornings).count == 7)
        #expect(mornings.allSatisfy { $0.contains("Margaret") })
        let evening = model(input(now: at(28, hour: 19))).greeting
        let evenings = Greetings.pool(.evening, season: .autumn).map { GreetingText.text($0, name: "Margaret") }
        #expect(evenings.contains(evening))
        #expect(!evenings.contains(model(input(now: at(28, hour: 9))).greeting))
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

    /// Plan 08/10/2026 tasks 3.5 and 3.10: the week's theme while the 12 weeks run, nothing before or after.
    @Test func weekThemeFollowsTheProgramWeek() {
        var value = input()
        #expect(model(value).weekTheme == nil)
        value.program = ProgramRound(start: at(14, hour: 0))
        #expect(model(value).weekTheme == .standingTall)
        value.program = ProgramRound(start: at(28, hour: 0))
        #expect(model(value).weekTheme == .firstSteps)
        #expect(model(value).weekTheme?.newThisWeek == .programStarts)
        value.programFinishedAt = at(27)
        #expect(model(value).weekTheme == nil)
    }

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

    /// "Stage 1 is done" (plan 09/10/2026): in the special-card slot after the level cards, before the rest; it
    /// waits while Welcome back, "Pick up at week N" or the trial card speaks, and replaces the week's theme.
    @Test func stageDoneCardSitsAfterLevelCardsAndNeverStacks() {
        let recap = StageRecap(stage: .base, status: .done, activeDays: 11, activeSeconds: 90 * 60, journeyMiles: 4.5,
                               outdoorMiles: 0, stops: [], check: nil)
        var value = input(healthConnected: false)
        // Started Monday Sep 7: Monday Sep 28 is week 4, stage 2.
        value.program = ProgramRound(start: at(7, hour: 0))
        value.stageDone = recap
        let shown = model(value)
        #expect(shown.specialCard == .stageDone(recap))
        #expect(shown.weekTheme == nil)

        var moved = value
        moved.level = .inPlace
        moved.levelCard = .movedUp(to: .inPlace)
        #expect(model(moved).specialCard == .movedUp(to: .inPlace))
        #expect(model(moved).weekTheme == .aLittleMore)

        // Away since Sep 21: Welcome back speaks; the stage card waits.
        var away = value
        away.workouts = [TodayInput.Workout(date: at(21), feeling: nil, breakCount: 0, level: .seated)]
        #expect(model(away).welcomeBack != nil)
        #expect(model(away).specialCard == .connectHealth)

        // Two weeks away: "Pick up at week N" first.
        var pickUp = value
        pickUp.workouts = [TodayInput.Workout(date: at(10), feeling: nil, breakCount: 0, level: .seated)]
        #expect(model(pickUp).programStrip?.pickUpWeek != nil)
        #expect(model(pickUp).specialCard != .stageDone(recap))

        // The trial's last days: its card speaks alone.
        var trial = value
        trial.entitlement = .trial(ends: at(30, hour: 19))
        trial.trialEnds = at(30, hour: 19)
        #expect(model(trial).trialEndingDate != nil)
        #expect(model(trial).specialCard == .connectHealth)
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

