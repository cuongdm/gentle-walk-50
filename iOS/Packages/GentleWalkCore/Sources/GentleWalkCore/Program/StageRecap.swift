import Foundation

/// One finished session as a stage recap counts it (`WorkoutRecord`).
public struct RecapSession: Equatable, Sendable {
    public var date: Date
    public var activeSeconds: Int
    /// Journey miles it earned (`ActivityDistance.miles`): active minutes indoors, the measured miles outdoors.
    public var journeyMiles: Double
    /// Measured miles of an outdoor walk; nil indoors.
    public var outdoorMiles: Double?

    public init(date: Date, activeSeconds: Int, journeyMiles: Double, outdoorMiles: Double?) {
        self.date = date; self.activeSeconds = activeSeconds; self.journeyMiles = journeyMiles; self.outdoorMiles = outdoorMiles
    }
}

/// A postcard she reached (`PostcardUnlock`): on which route, which stop, and when.
public struct ReachedStop: Equatable, Sendable {
    public var journeyID: String
    public var stopID: String
    public var date: Date

    public init(journeyID: String, stopID: String, date: Date) {
        self.journeyID = journeyID; self.stopID = stopID; self.date = date
    }
}

/// What she did in one stage of the 12 weeks (docs/plans/2026-10-09-plan-journey-link.md): only what is there.
/// No session means no numbers to show; a check is compared only with her own first check done the same way.
public struct StageRecap: Equatable, Sendable {
    public enum Status: Equatable, Sendable {
        case done
        /// The stage she is in now: "so far".
        case soFar
    }

    public struct Stop: Equatable, Identifiable, Sendable {
        public var id: String { stopID }
        public var journeyID: String
        public var stopID: String
        public var name: String
        public var date: Date

        public init(journeyID: String, stopID: String, name: String, date: Date) {
            self.journeyID = journeyID; self.stopID = stopID; self.name = name; self.date = date
        }
    }

    /// Her latest 2-week check in the stage.
    public struct Check: Equatable, Sendable {
        public var count: Int
        public var usedHands: Bool
        /// Change since her first check done the same way; nil when there is none to compare with.
        public var sinceFirst: Int?

        public init(count: Int, usedHands: Bool, sinceFirst: Int?) {
            self.count = count; self.usedHands = usedHands; self.sinceFirst = sinceFirst
        }
    }

    public var stage: ProgramStage
    public var status: Status
    public var activeDays: Int
    public var activeSeconds: Int
    /// Indoor and outdoor together: the miles her journeys moved, never capped by the free leg.
    public var journeyMiles: Double
    /// The part of `journeyMiles` walked outdoors (measured).
    public var outdoorMiles: Double
    /// In the order she reached them.
    public var stops: [Stop]
    public var check: Check?

    public init(stage: ProgramStage, status: Status, activeDays: Int, activeSeconds: Int, journeyMiles: Double,
                outdoorMiles: Double, stops: [Stop], check: Check?) {
        self.stage = stage; self.status = status; self.activeDays = activeDays; self.activeSeconds = activeSeconds
        self.journeyMiles = journeyMiles; self.outdoorMiles = outdoorMiles; self.stops = stops; self.check = check
    }

    public var activeMinutes: Int { Int((Double(activeSeconds) / 60).rounded()) }
    /// At least one session in the stage: otherwise there is nothing to recap.
    public var hasActivity: Bool { activeDays > 0 }
}

/// The whole round, for the end of the 12 weeks: "Your whole route".
public struct RoundRecap: Equatable, Sendable {
    public var activeDays: Int
    public var activeSeconds: Int
    public var journeyMiles: Double
    public var outdoorMiles: Double
    public var stops: [StageRecap.Stop]

    public init(activeDays: Int, activeSeconds: Int, journeyMiles: Double, outdoorMiles: Double, stops: [StageRecap.Stop]) {
        self.activeDays = activeDays; self.activeSeconds = activeSeconds; self.journeyMiles = journeyMiles
        self.outdoorMiles = outdoorMiles; self.stops = stops
    }

    public var first: StageRecap.Stop? { stops.first }
    public var last: StageRecap.Stop? { stops.last }
}

/// Where she is on her current route, as Journey says it: on a paid route without Pro the next stop past the
/// free leg is never named (never promise a stop she cannot reach on her plan).
public struct RoutePosition: Equatable, Sendable {
    public var lastStop: String?
    public var nextStop: String?
    public var milesToNext: Double?
    /// The next stop is past the free leg.
    public var nextNeedsPro: Bool
    public var isComplete: Bool

    public init(lastStop: String?, nextStop: String?, milesToNext: Double?, nextNeedsPro: Bool, isComplete: Bool) {
        self.lastStop = lastStop; self.nextStop = nextStop; self.milesToNext = milesToNext
        self.nextNeedsPro = nextNeedsPro; self.isComplete = isComplete
    }
}

/// The stops of one route reached in one stage (Journey: "Your 12 weeks").
public struct StageStops: Equatable, Identifiable, Sendable {
    public var id: Int { stage.rawValue }
    public var stage: ProgramStage
    public var stops: [StageRecap.Stop]

    public init(stage: ProgramStage, stops: [StageRecap.Stop]) {
        self.stage = stage; self.stops = stops
    }
}

/// Today's "Stage N is done" card, tapped away: one per round and stage.
public struct StageMark: Codable, Equatable, Sendable {
    public var round: Int
    public var stage: Int

    public init(round: Int, stage: Int) {
        self.round = round; self.stage = stage
    }
}

/// Everything a recap reads, with the clock and calendar injected.
public struct StageRecapInput: Sendable {
    public var round: ProgramRound
    public var pauses: [ProgramPause]
    public var sessions: [RecapSession]
    public var reached: [ReachedStop]
    public var journeys: [Journey]
    /// Every check she has done (the first one done the same way may be from an earlier round).
    public var checks: [SelfCheckResult]
    public var now: Date
    public var calendar: Calendar

    public init(round: ProgramRound, pauses: [ProgramPause], sessions: [RecapSession], reached: [ReachedStop],
                journeys: [Journey], checks: [SelfCheckResult], now: Date, calendar: Calendar) {
        self.round = round; self.pauses = pauses; self.sessions = sessions; self.reached = reached
        self.journeys = journeys; self.checks = checks; self.now = now; self.calendar = calendar
    }
}
