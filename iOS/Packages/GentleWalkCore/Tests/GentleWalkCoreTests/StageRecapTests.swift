import Foundation
import Testing
@testable import GentleWalkCore

/// Stage recaps link the 12-week plan with the journey (docs/plans/2026-10-09-plan-journey-link.md): what she
/// did in each stage, which stops she reached then, her latest check against her first one done the same way.
@Suite struct StageRecapTests {
    let ny = TestSupport.newYork
    let journeys = [TestSupport.newYorkJourney, TestSupport.paidJourney]

    /// Monday 5 October 2026: stage 1 is 5–25 Oct, stage 2 26 Oct–15 Nov, stage 3 16 Nov–6 Dec, stage 4 7–27 Dec.
    var round: ProgramRound { ProgramRound(start: day(10, 5, hour: 0)) }

    func day(_ month: Int, _ day: Int, hour: Int = 9, year: Int = 2026) -> Date {
        TestSupport.local(ny, year, month, day, hour)
    }

    func session(_ month: Int, _ day: Int, minutes: Int, hour: Int = 9, outdoorMiles: Double? = nil) -> RecapSession {
        RecapSession(date: self.day(month, day, hour: hour), activeSeconds: minutes * 60,
                     journeyMiles: ActivityDistance.miles(activeMinutes: Double(minutes), outdoorMiles: outdoorMiles),
                     outdoorMiles: outdoorMiles)
    }

    func input(round: ProgramRound? = nil, pauses: [ProgramPause] = [], sessions: [RecapSession], reached: [ReachedStop] = [],
               checks: [SelfCheckResult] = [], now: Date) -> StageRecapInput {
        StageRecapInput(round: round ?? self.round, pauses: pauses, sessions: sessions, reached: reached, journeys: journeys,
                        checks: checks, now: now, calendar: ny)
    }

    @Test func countsEachStagesOwnSessions() {
        let sessions = [session(10, 5, minutes: 8), session(10, 7, minutes: 8), session(10, 20, minutes: 10),
                        session(10, 26, minutes: 12), session(10, 27, minutes: 12), session(10, 27, minutes: 5, hour: 18)]
        let recaps = StageRecaps.stages(input(sessions: sessions, now: day(10, 28, hour: 10)))
        #expect(recaps.map(\.stage) == [.base, .build])
        #expect(recaps.map(\.status) == [.done, .soFar])
        #expect(recaps[0].activeDays == 3)
        #expect(recaps[0].activeSeconds == 26 * 60)
        #expect(recaps[0].activeMinutes == 26)
        #expect(abs(recaps[0].journeyMiles - 1.3) < 1e-9)
        #expect(recaps[1].activeDays == 2)
        #expect(recaps[1].activeSeconds == 29 * 60)
        #expect(abs(recaps[1].journeyMiles - 1.45) < 1e-9)
        #expect(recaps.allSatisfy { $0.outdoorMiles == 0 })
    }

    /// Outdoor walks bring their measured miles, as on Complete ("0.9 mi walked").
    @Test func outdoorWalksCountTheirMeasuredMiles() {
        let recap = StageRecaps.stages(input(sessions: [session(10, 6, minutes: 8), session(10, 8, minutes: 20, outdoorMiles: 0.9)],
                                             now: day(10, 9)))
        #expect(recap.count == 1)
        #expect(abs(recap[0].journeyMiles - 1.3) < 1e-9)
        #expect(abs(recap[0].outdoorMiles - 0.9) < 1e-9)
    }

    @Test func stopsReachedDuringEachStage() {
        let reached = [ReachedStop(journeyID: "jr.ny", stopID: "pc.ny.bethesda", date: day(10, 12)),
                       ReachedStop(journeyID: "jr.ny", stopID: "pc.ny.zoo", date: day(10, 5)),
                       // One session reached two stops: they keep the route's order.
                       ReachedStop(journeyID: "jr.ny", stopID: "pc.ny.bryant", date: day(10, 27)),
                       ReachedStop(journeyID: "jr.ny", stopID: "pc.ny.times", date: day(10, 27))]
        let recaps = StageRecaps.stages(input(sessions: [session(10, 5, minutes: 8), session(10, 27, minutes: 12)],
                                              reached: reached, now: day(10, 28)))
        #expect(recaps[0].stops.map(\.name) == ["Central Park Zoo", "Bethesda Fountain"])
        #expect(recaps[1].stops.map(\.name) == ["Times Square", "Bryant Park"])
        #expect(recaps[1].stops.map(\.journeyID) == ["jr.ny", "jr.ny"])
    }

    /// Only against her own earlier checks done the same way (hands or not); never a norm.
    @Test func latestCheckComparedWithHerFirstDoneTheSameWay() {
        let checks = [SelfCheckResult(date: day(10, 5, hour: 10), count: 7, usedHands: true),
                      SelfCheckResult(date: day(10, 19), count: 8, usedHands: true),
                      SelfCheckResult(date: day(11, 2), count: 9, usedHands: false)]
        let recaps = StageRecaps.stages(input(sessions: [session(10, 5, minutes: 8), session(11, 2, minutes: 8)], checks: checks,
                                              now: day(11, 3)))
        #expect(recaps[0].check == StageRecap.Check(count: 8, usedHands: true, sinceFirst: 1))
        // The first check without hands starts its own line: nothing to compare with.
        #expect(recaps[1].check == StageRecap.Check(count: 9, usedHands: false, sinceFirst: nil))
    }

    /// No session, no stop, no check in a stage: the recap has nothing to say, and stages ahead have no recap.
    @Test func saysNothingItDoesNotKnow() {
        let recaps = StageRecaps.stages(input(sessions: [session(10, 28, minutes: 8)], now: day(10, 29)))
        #expect(recaps.map(\.stage) == [.base, .build])
        #expect(recaps[0].activeDays == 0)
        #expect(recaps[0].journeyMiles == 0)
        #expect(recaps[0].stops.isEmpty)
        #expect(recaps[0].check == nil)
        #expect(!recaps[0].hasActivity)
        #expect(recaps[1].hasActivity)
    }

    /// "Pick up at week 4" after three weeks away: the sessions before the break keep their stage, and the
    /// program week of today is the one `position` shows.
    @Test func aPickedUpBreakKeepsEarlierSessionsInTheirStage() {
        let lastBefore = day(10, 28)
        let pickedUpOn = day(11, 20, hour: 8)
        let pause = ProgramCalendar.pickUpPause(lastWorkout: lastBefore, now: pickedUpOn, calendar: ny)
        #expect(pause == ProgramPause(after: lastBefore, days: 23))
        let picked = ProgramCalendar.pickUp(round, lastWorkout: lastBefore, now: pickedUpOn, calendar: ny)
        let sessions = [session(10, 26, minutes: 10), session(10, 28, minutes: 10), session(11, 20, minutes: 8),
                        session(11, 23, minutes: 8)]
        let now = day(11, 24)
        #expect(ProgramCalendar.week(picked, pauses: [pause], on: now, calendar: ny) == 4)
        guard case .week(4, .build) = ProgramCalendar.position(picked, on: now, calendar: ny) else {
            Issue.record("position should be week 4")
            return
        }
        // Days away do not count: the program day stands still from her last session to the pick-up.
        #expect(ProgramCalendar.programDay(picked, pauses: [pause], on: day(10, 28), calendar: ny) == 23)
        #expect(ProgramCalendar.programDay(picked, pauses: [pause], on: day(11, 10), calendar: ny) == 23)
        #expect(ProgramCalendar.programDay(picked, pauses: [pause], on: day(11, 20), calendar: ny) == 23)

        let recaps = StageRecaps.stages(input(round: picked, pauses: [pause], sessions: sessions, now: now))
        #expect(recaps.map(\.activeDays) == [0, 4])
    }

    /// Paused days with no record (a store from before pauses were kept) shift every date, as `position` does.
    @Test func unrecordedPausedDaysApplyToEveryDate() {
        var picked = round
        picked.pausedDays = 23
        let sessions = [session(10, 26, minutes: 10), session(10, 28, minutes: 10), session(11, 20, minutes: 8)]
        let recaps = StageRecaps.stages(input(round: picked, sessions: sessions, now: day(11, 24)))
        #expect(recaps.map(\.activeDays) == [2, 1])
    }

    /// A new round counts from its own first day; earlier sessions, stops and checks belong to the last round.
    @Test func aNewRoundStartsFresh() {
        let again = ProgramCalendar.restart(round, on: day(1, 4, year: 2027), calendar: ny)
        let sessions = [session(12, 20, minutes: 12), session(12, 22, minutes: 12),
                        RecapSession(date: day(1, 4, year: 2027), activeSeconds: 600, journeyMiles: 0.5, outdoorMiles: nil)]
        let reached = [ReachedStop(journeyID: "jr.smoky", stopID: "pc.smoky.3", date: day(12, 20))]
        let checks = [SelfCheckResult(date: day(12, 21), count: 10, usedHands: true)]
        let recaps = StageRecaps.stages(input(round: again, sessions: sessions, reached: reached, checks: checks,
                                              now: day(1, 6, year: 2027)))
        #expect(recaps.count == 1)
        #expect(recaps[0].status == .soFar)
        #expect(recaps[0].activeDays == 1)
        #expect(recaps[0].stops.isEmpty)
        #expect(recaps[0].check == nil)
    }

    @Test func aFinishedRoundRecapsFourStagesAndTheWholeRoute() {
        let sessions = [session(10, 5, minutes: 8), session(10, 27, minutes: 10), session(11, 17, minutes: 12),
                        session(12, 8, minutes: 12), session(12, 9, minutes: 30, outdoorMiles: 1.1),
                        // After week 12 she kept going: not part of the 12 weeks.
                        session(12, 29, minutes: 12)]
        let reached = [ReachedStop(journeyID: "jr.ny", stopID: "pc.ny.zoo", date: day(10, 5)),
                       ReachedStop(journeyID: "jr.ny", stopID: "pc.ny.bridge", date: day(11, 17)),
                       ReachedStop(journeyID: "jr.smoky", stopID: "pc.smoky.1", date: day(12, 8)),
                       ReachedStop(journeyID: "jr.smoky", stopID: "pc.smoky.2", date: day(12, 29))]
        let value = input(sessions: sessions, reached: reached, now: day(12, 30))
        let recaps = StageRecaps.stages(value)
        #expect(recaps.map(\.stage) == ProgramStage.allCases)
        #expect(recaps.allSatisfy { $0.status == .done })

        let whole = StageRecaps.round(value)
        #expect(whole.activeDays == 5)
        #expect(whole.activeSeconds == (8 + 10 + 12 + 12 + 30) * 60)
        #expect(abs(whole.journeyMiles - (0.4 + 0.5 + 0.6 + 0.6 + 1.1)) < 1e-9)
        #expect(abs(whole.outdoorMiles - 1.1) < 1e-9)
        #expect(whole.stops.map(\.name) == ["Central Park Zoo", "Brooklyn Bridge", "Cades Cove"])
        #expect(whole.first?.name == "Central Park Zoo")
        #expect(whole.last?.name == "Cades Cove")
    }

    /// Never promise a stop she cannot reach on her plan; a finished route has no next stop.
    @Test func routeNeverNamesAStopPastTheFreeLeg() {
        let reached: Set<String> = ["pc.smoky.1", "pc.smoky.2"]
        let free = StageRecaps.route(journey: TestSupport.paidJourney, totalMiles: 3.0, reached: reached, entitlement: .free)
        #expect(free.lastStop == "Laurel Falls")
        #expect(free.nextStop == nil)
        #expect(free.milesToNext == nil)
        #expect(free.nextNeedsPro)

        let pro = StageRecaps.route(journey: TestSupport.paidJourney, totalMiles: 3.0, reached: reached, entitlement: .subscribed)
        #expect(pro.nextStop == "Clingmans Dome")
        #expect(abs((pro.milesToNext ?? 0) - 1.8) < 1e-9)
        #expect(!pro.nextNeedsPro)

        let all = Set(TestSupport.newYorkJourney.stops.map(\.id))
        let done = StageRecaps.route(journey: TestSupport.newYorkJourney, totalMiles: 5.2, reached: all, entitlement: .free)
        #expect(done.isComplete)
        #expect(done.nextStop == nil)
        #expect(done.lastStop == "Brooklyn Bridge")
    }

    /// Today's "Stage N is done" card: the stage that just ended, for a week, until she taps it away. Stage 4
    /// ends the 12 weeks (the finish screen speaks then); a stage with no session has nothing to recognise.
    @Test func turnCardShowsForAWeekAfterAStageEnds() {
        let both = [session(10, 5, minutes: 8), session(10, 14, minutes: 8), session(10, 28, minutes: 8)]
        func card(_ now: Date, round: ProgramRound? = nil, dismissed: StageMark? = nil,
                  sessions: [RecapSession]? = nil) -> StageRecap? {
            StageRecaps.turnCard(input(round: round, sessions: sessions ?? both, now: now), dismissed: dismissed)
        }
        #expect(card(day(10, 25)) == nil)
        #expect(card(day(10, 26))?.stage == .base)
        #expect(card(day(11, 1, hour: 21))?.stage == .base)
        #expect(card(day(11, 2)) == nil)
        #expect(card(day(10, 27), dismissed: StageMark(round: 1, stage: 1)) == nil)
        // A mark from the last round does not hide this round's card.
        var second = round
        second.round = 2
        #expect(card(day(10, 27), round: second, dismissed: StageMark(round: 1, stage: 1))?.stage == .base)
        #expect(card(day(11, 17))?.stage == .build)
        #expect(card(day(12, 28)) == nil)
        #expect(card(day(10, 27), sessions: [session(10, 26, minutes: 8)]) == nil)
    }

    @Test func journeyStagesGroupThisRoutesStopsByStage() {
        let reached = [ReachedStop(journeyID: "jr.ny", stopID: "pc.ny.bridge", date: day(10, 20)),
                       ReachedStop(journeyID: "jr.smoky", stopID: "pc.smoky.1", date: day(10, 21)),
                       ReachedStop(journeyID: "jr.smoky", stopID: "pc.smoky.2", date: day(11, 6)),
                       ReachedStop(journeyID: "jr.smoky", stopID: "pc.smoky.3", date: day(11, 18))]
        let value = input(sessions: [session(10, 20, minutes: 8), session(11, 18, minutes: 8)], reached: reached, now: day(11, 19))
        let groups = StageRecaps.journeyStages(journeyID: "jr.smoky", value)
        #expect(groups.map(\.stage) == [.base, .build, .challenge])
        #expect(groups.map { $0.stops.map(\.name) } == [["Cades Cove"], ["Laurel Falls"], ["Clingmans Dome"]])
        #expect(StageRecaps.journeyStages(journeyID: "jr.ny", value).map(\.stage) == [.base])
    }
}
