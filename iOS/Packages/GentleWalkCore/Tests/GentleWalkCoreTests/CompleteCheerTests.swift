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
