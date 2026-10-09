import Foundation

/// Links the 12-week plan with the journey (owner 09/10/2026, docs/plans/2026-10-09-plan-journey-link.md): per
/// stage, the sessions, journey miles and stops of that stage. A stage turning is recognition only: nothing
/// unlocks, nothing is gated, reps and support still move only when she is ready.
public enum StageRecaps {
    /// Days after a stage ends during which Today shows its card (program days: days away do not count).
    public static let cardDays = 7

    /// The stages done and the one she is in now ("so far"), oldest first; none for stages ahead. After week 12
    /// all four are done.
    public static func stages(_ input: StageRecapInput) -> [StageRecap] {
        let current = currentStage(input)
        let shown = ProgramStage.allCases.filter { stage in current.map { stage.rawValue <= $0.rawValue } ?? true }
        let sessions = input.sessions.filter { inRound($0.date, input) }
        let checks = input.checks.filter { inRound($0.date, input) }.sorted { $0.date < $1.date }
        let stops = reachedStops(input)
        return shown.map { stage in
            let mine = sessions.filter { self.stage(of: $0.date, input) == stage }
            let check = checks.last { self.stage(of: $0.date, input) == stage }.map { latest in
                StageRecap.Check(count: latest.count, usedHands: latest.usedHands,
                                 sinceFirst: SelfCheckComparison.delta(latest: latest, history: input.checks).sinceFirst)
            }
            return StageRecap(
                stage: stage, status: stage == current ? .soFar : .done,
                activeDays: Set(mine.map { input.calendar.startOfDay(for: $0.date) }).count,
                activeSeconds: mine.reduce(0) { $0 + max(0, $1.activeSeconds) },
                journeyMiles: mine.reduce(0) { $0 + max(0, $1.journeyMiles) },
                outdoorMiles: mine.reduce(0) { $0 + max(0, $1.outdoorMiles ?? 0) },
                stops: stops.filter { $0.stage == stage }.map(\.stop),
                check: check)
        }
    }

    /// The whole round: the four stages added up ("Your whole route" at the end of the 12 weeks).
    public static func round(_ input: StageRecapInput) -> RoundRecap {
        let stages = stages(input)
        return RoundRecap(activeDays: stages.reduce(0) { $0 + $1.activeDays },
                          activeSeconds: stages.reduce(0) { $0 + $1.activeSeconds },
                          journeyMiles: stages.reduce(0) { $0 + $1.journeyMiles },
                          outdoorMiles: stages.reduce(0) { $0 + $1.outdoorMiles },
                          stops: stages.flatMap(\.stops))
    }

    /// The stops of one route reached in this round, by the stage she was in when she reached them.
    public static func journeyStages(journeyID: String, _ input: StageRecapInput) -> [StageStops] {
        stages(input).compactMap { recap in
            let mine = recap.stops.filter { $0.journeyID == journeyID }
            return mine.isEmpty ? nil : StageStops(stage: recap.stage, stops: mine)
        }
    }

    /// Her last stop and the next one she can reach on her plan, with the miles to it (capped at the free leg,
    /// as the Journey map shows them).
    public static func route(journey: Journey, totalMiles: Double, reached: Set<String>, entitlement: Entitlement) -> RoutePosition {
        let limit = JourneyAccess.limitMile(for: journey, entitlement: entitlement)
        let shown = JourneyAccess.routeMiles(total: totalMiles, limit: limit)
        let next = journey.stops.first { !reached.contains($0.id) }
        let reachable = next.flatMap { stop in (limit.map { stop.mile <= $0 + 1e-9 } ?? true) ? stop : nil }
        return RoutePosition(lastStop: journey.stops.last { reached.contains($0.id) }?.name,
                             nextStop: reachable?.name,
                             milesToNext: reachable.map { max(0, $0.mile - shown) },
                             nextNeedsPro: next != nil && reachable == nil,
                             isComplete: next == nil && !journey.stops.isEmpty)
    }

    /// The stage whose "Stage N is done" card Today shows: the one that ended less than `cardDays` program days
    /// ago, with at least one session in it, unless she tapped it away. Stage 4 ends the 12 weeks: the finish
    /// screen speaks then. Being away across several stages shows at most the latest one, never a stack.
    public static func turnCard(_ input: StageRecapInput, dismissed: StageMark?) -> StageRecap? {
        guard let current = currentStage(input), let ended = ProgramStage(rawValue: current.rawValue - 1) else { return nil }
        let day = ProgramCalendar.programDay(input.round, pauses: input.pauses, on: input.now, calendar: input.calendar)
        let turnedOn = (current.weeks.lowerBound - 1) * 7
        guard day - turnedOn < cardDays, dismissed != StageMark(round: input.round.round, stage: ended.rawValue) else { return nil }
        return stages(input).first { $0.stage == ended && $0.hasActivity }
    }

    // MARK: Windows

    /// The stage she is in now; nil once the 12 weeks are over.
    static func currentStage(_ input: StageRecapInput) -> ProgramStage? {
        let week = ProgramCalendar.week(input.round, pauses: input.pauses, on: input.now, calendar: input.calendar)
        return week <= ProgramCalendar.weeks ? .of(week: week) : nil
    }

    /// The stage a date belongs to; nil past week 12.
    static func stage(of date: Date, _ input: StageRecapInput) -> ProgramStage? {
        let week = ProgramCalendar.week(input.round, pauses: input.pauses, on: date, calendar: input.calendar)
        return week <= ProgramCalendar.weeks ? .of(week: week) : nil
    }

    /// From the round's first day up to now: an earlier round's sessions are not this one's.
    static func inRound(_ date: Date, _ input: StageRecapInput) -> Bool {
        date >= input.calendar.startOfDay(for: input.round.start) && date <= input.now
    }

    /// Stops reached in this round, by date and then in the route's order, with their names from the content.
    static func reachedStops(_ input: StageRecapInput) -> [(stage: ProgramStage, stop: StageRecap.Stop)] {
        input.reached.filter { inRound($0.date, input) }
            .compactMap { reached -> (stage: ProgramStage, stop: StageRecap.Stop, order: Int)? in
                guard let journey = input.journeys.first(where: { $0.id == reached.journeyID }),
                      let index = journey.stops.firstIndex(where: { $0.id == reached.stopID }),
                      let stage = stage(of: reached.date, input) else { return nil }
                let stop = StageRecap.Stop(journeyID: journey.id, stopID: reached.stopID, name: journey.stops[index].name,
                                           date: reached.date)
                return (stage, stop, index)
            }
            .sorted { ($0.stop.date, $0.order) < ($1.stop.date, $1.order) }
            .map { ($0.stage, $0.stop) }
    }
}

extension ProgramStage {
    /// Weeks 1–3, 4–6, 7–9, 10–12.
    public var weeks: ClosedRange<Int> {
        let first = (rawValue - 1) * 3 + 1
        return first...(first + 2)
    }
}
