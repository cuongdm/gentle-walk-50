import Foundation
import GentleWalkCore

/// What the stage recaps show (docs/plans/2026-10-09-plan-journey-link.md), worked out once per reload from the
/// store: the plan and the journey read as one story. Recognition only: nothing here unlocks or gates anything.
struct ProgramRecapSnapshot: Equatable {
    var round = 0
    /// Stages done and the one she is in now, oldest first; empty before the first session.
    var stages: [StageRecap] = []
    /// The whole round (the end of the 12 weeks: "Your whole route").
    var whole: RoundRecap?
    /// Her current route: last stop, and the next one she can reach on her plan.
    var route: RoutePosition?
    /// This route's stops by the stage she was in when she reached them (Journey: "Your 12 weeks").
    var journeyStages: [StageStops] = []
    /// Today's "Stage N is done" card, until she taps it away or a week has gone.
    var turn: StageRecap?

    static let empty = ProgramRecapSnapshot()

    init() {}

    init(input: StageRecapInput, journey: JourneySnapshot, entitlement: Entitlement, dismissed: StageMark?) {
        round = input.round.round
        stages = StageRecaps.stages(input)
        whole = StageRecaps.round(input)
        journeyStages = StageRecaps.journeyStages(journeyID: journey.journeyID, input)
        turn = StageRecaps.turnCard(input, dismissed: dismissed)
        route = journey.journey.map {
            StageRecaps.route(journey: $0, totalMiles: journey.totalMiles, reached: journey.unlocked, entitlement: entitlement)
        }
    }

    /// The recap of one stage, when there is something to say (at least one session).
    func recap(of stage: ProgramStage) -> StageRecap? {
        stages.first { $0.stage == stage && $0.hasActivity }
    }
}

extension AppModel {
    var programMemory: ProgramMemoryStore { ProgramMemoryStore(defaults: defaults) }

    /// The recaps of the current round; empty before the first session.
    func makeProgramRecap(program: ProgramState?, records: [WorkoutRecord], unlocks: [PostcardUnlock],
                          checks: [SelfCheckRecord]) -> ProgramRecapSnapshot {
        guard let program else { return .empty }
        let memory = programMemory
        let input = StageRecapInput(
            round: program.programRound, pauses: memory.pauses,
            sessions: records.map {
                RecapSession(date: $0.date, activeSeconds: $0.activeSeconds, journeyMiles: $0.journeyMiles, outdoorMiles: $0.outdoorMiles)
            },
            reached: unlocks.map { ReachedStop(journeyID: $0.journeyID, stopID: $0.stopID, date: $0.unlockedAt) },
            journeys: content.journeys, checks: checks.map(\.result), now: now(), calendar: calendar)
        return ProgramRecapSnapshot(input: input, journey: journey, entitlement: entitlement, dismissed: memory.dismissedStage)
    }

    /// "Got it" on Today's stage card: never shown again for this stage of this round.
    func dismissStageRecap() {
        guard let stage = programRecap.turn?.stage else { return }
        programMemory.dismissStage(StageMark(round: programRecap.round, stage: stage.rawValue))
        reload()
    }

    /// "See my plan" on the stage card: the card has done its job; the plan shows the same recap.
    func openPlanFromStageRecap() {
        dismissStageRecap()
        todayPath.append(.program)
    }
}
