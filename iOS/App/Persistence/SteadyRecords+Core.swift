import Foundation
import GentleWalkCore

/// Stored program and self-check rows as GentleWalkCore values (the rules live in the package).
extension ProgramState {
    var programRound: ProgramRound { ProgramRound(start: start, round: round, pausedDays: pausedDays) }

    func apply(_ value: ProgramRound) {
        start = value.start; round = value.round; pausedDays = value.pausedDays
    }
}

extension SelfCheckRecord {
    var result: SelfCheckResult { SelfCheckResult(date: date, count: count, usedHands: usedHands) }
}
