import Foundation
import Testing
@testable import GentleWalkCore

/// Complete-screen variety (plan 3.6, anti-boredom #4): a title and a line per context, rotating, never
/// the same twice in a row, compared only with herself.
@Suite struct CompleteCheerTests {
    /// The most specific context wins: first > stage done > personal best > week done > came back > ordinary.
    @Test func contextPriority() {
        func context(first: Bool = false, gap: Int = 1, best: Bool = false, week: Bool = false, stage: Bool = false) -> CheerContext {
            CompleteCheer.context(isFirstSession: first, daysSinceLastSession: gap, personalBest: best, weekDone: week,
                                  stageDone: stage)
        }
        #expect(context(first: true, gap: 9, best: true, week: true, stage: true) == .firstSession)
        #expect(context(gap: 9, best: true, week: true, stage: true) == .stageDone)
        #expect(context(gap: 9, best: true, week: true) == .personalBest)
        #expect(context(gap: 9, week: true) == .weekDone)
        #expect(context(gap: 3) == .cameBack)
        #expect(context(gap: 2) == .ordinary)
        #expect(context() == .ordinary)
    }

    /// Every context has a pool; lines are unique and every one has a Vietnamese translation.
    @Test func poolsAreFullUniqueAndTranslated() throws {
        for context in CheerContext.allCases {
            #expect(CompleteCheer.pool(context).count >= (context == .ordinary ? 6 : 3), "\(context)")
        }
        let all = CheerContext.allCases.flatMap(CompleteCheer.pool)
        #expect(Set(all.map(\.id)).count == all.count)
        #expect(Set(all.map(\.title)).count == all.count)
        let vietnamese = try TestSupport.vietnameseUI()
        for cheer in all {
            #expect(vietnamese[cheer.title]?.isEmpty == false, "VI title \(cheer.id)")
            #expect(vietnamese[cheer.line]?.isEmpty == false, "VI line \(cheer.id)")
        }
    }

    /// Rotates with her sessions, never the same line twice in a row, even when the context changes back.
    @Test func neverTheSameTwiceInARow() {
        var last: String?
        for session in 0..<40 {
            let context: CheerContext = session % 7 == 0 ? .weekDone : .ordinary
            let cheer = CompleteCheer.pick(context, sessionIndex: session, lastID: last)
            #expect(cheer.id != last, "session \(session)")
            last = cheer.id
        }
        // A one-line repeat is avoided even when the rotation lands on it.
        let first = CompleteCheer.pick(.ordinary, sessionIndex: 0, lastID: nil)
        #expect(CompleteCheer.pick(.ordinary, sessionIndex: CompleteCheer.pool(.ordinary).count, lastID: first.id).id != first.id)
        // Deterministic: same inputs, same line.
        #expect(CompleteCheer.pick(.cameBack, sessionIndex: 5, lastID: nil) == CompleteCheer.pick(.cameBack, sessionIndex: 5, lastID: nil))
    }

    /// No guilt, no claims, no comparing with others (steady-claims, Tone & copy rules).
    @Test func copyIsKind() {
        for cheer in CheerContext.allCases.flatMap(CompleteCheer.pool) {
            let text = (cheer.title + " " + cheer.line).lowercased()
            for banned in ["fall", "risk", "pain", "streak", "missed", "lazy", "others", "average", "burn", "weight", "!!"] {
                #expect(!text.contains(banned), "\(cheer.id): \(banned)")
            }
        }
    }
}

/// Which cheer a finished session gets, worked out from her own sessions (plan 3.6): the app passes the
/// saved sessions, her rest days and the program week; nothing here compares her with anyone else.
@Suite struct CompleteCheerFactsTests {
    let calendar = TestSupport.newYork
    /// Saturday and Sunday off: five planned days, Monday to Friday.
    let restDays: Set<Weekday> = [.saturday, .sunday]

    func at(_ day: Int, _ hour: Int = 10) -> Date { TestSupport.local(calendar, 2026, 10, day, hour) }

    func walk(_ day: Int, minutes: Int = 10, unbroken: Bool = true, hour: Int = 10) -> CheerSession {
        CheerSession(date: at(day, hour), seconds: minutes * 60, isUnbrokenWalk: unbroken)
    }

    func context(_ session: CheerSession, after previous: [CheerSession], week: Int? = 2) -> CheerContext {
        CompleteCheer.context(session: session, previous: previous, restDays: restDays, programWeek: week, calendar: calendar)
    }

    @Test func firstSessionAndOrdinary() {
        #expect(context(walk(5), after: []) == .firstSession)
        #expect(context(walk(6), after: [walk(5)]) == .ordinary)
    }

    /// Three calendar days or more since her last session (not 72 hours: an evening then a morning).
    @Test func cameBackAfterThreeDays() {
        #expect(context(walk(5, hour: 8), after: [walk(2, hour: 20)]) == .cameBack)
        #expect(context(walk(5), after: [walk(3)]) == .ordinary)
    }

    /// Her longest unbroken walk by a whole minute or more, once she has two walks to beat.
    @Test func personalBestNeedsTwoWalksAndAWholeMinute() {
        #expect(context(walk(7, minutes: 14), after: [walk(5, minutes: 10)]) == .ordinary)
        #expect(context(walk(7, minutes: 14), after: [walk(5, minutes: 10), walk(6, minutes: 12)]) == .personalBest)
        #expect(context(walk(7, minutes: 12), after: [walk(5, minutes: 10), walk(6, minutes: 12)]) == .ordinary)
        // A walk with a break, or a chair session, is never a best walk.
        #expect(context(walk(7, minutes: 20, unbroken: false), after: [walk(5), walk(6)]) == .ordinary)
        // Long sessions that were not unbroken walks do not set the bar.
        #expect(context(walk(7, minutes: 12), after: [walk(5), walk(6), walk(2, minutes: 30, unbroken: false)]) == .personalBest)
    }

    /// The session that completes every planned day of this week (Mon–Fri here); a second session the
    /// same day does not finish it again.
    @Test func weekDoneOnTheDayItCompletes() {
        let monToThu = [walk(5), walk(6), walk(7), walk(8)]
        #expect(context(walk(9), after: monToThu) == .weekDone)
        #expect(context(walk(9, hour: 18), after: monToThu + [walk(9)]) == .ordinary)
        #expect(context(walk(9), after: [walk(5), walk(6), walk(7)]) == .ordinary)
    }

    /// Week 3, 6, 9 or 12 of the program done: the stage is behind her.
    @Test func stageDoneAtTheEndOfAStageWeek() {
        let monToThu = [walk(5), walk(6), walk(7), walk(8)]
        #expect(context(walk(9), after: monToThu, week: 3) == .stageDone)
        #expect(context(walk(9), after: monToThu, week: 4) == .weekDone)
        #expect(context(walk(9), after: monToThu, week: nil) == .weekDone)
    }
}
