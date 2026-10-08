import Foundation
import Testing
@testable import GentleWalkCore

/// P7 (plan 4.13): the A13 lines the coach uses to recall her history.
@Suite struct CoachHistoryTests {
    /// All 41 lines are in the content, in English and Vietnamese, as whole sentences with the number in words.
    @Test func coachHistoryLinesExist() {
        let ids = CoachHistory.allLineIDs
        #expect(ids.count == 41)
        #expect(Set(ids).count == 41)
        let english = Dictionary(TestSupport.appContent.voiceLines.map { ($0.id, $0.text) }, uniquingKeysWith: { a, _ in a })
        let vietnamese = Dictionary(SessionSyncTests.vietnamese.voiceLines.map { ($0.id, $0.text) }, uniquingKeysWith: { a, _ in a })
        for id in ids {
            #expect(english[id]?.isEmpty == false, "EN \(id)")
            #expect(vietnamese[id]?.isEmpty == false && vietnamese[id] != english[id], "VI \(id)")
            #expect(english[id].map { !$0.contains(where: \.isNumber) } ?? false, "EN \(id) says the number in words")
        }
        #expect(english["a13.check.n.8"] == "Last check, you stood up eight times. Let's see today.")
        #expect(english["a13.week.12"] == "Week twelve of twelve. At your own pace.")
    }

    @Test func linesFollowTheNumbersAndStaySilentOutOfRange() {
        #expect(CoachHistory.checkLine(previousCount: 8) == "a13.check.n.8")
        #expect(CoachHistory.checkLine(previousCount: 2) == nil && CoachHistory.checkLine(previousCount: 21) == nil)
        #expect(CoachHistory.weekLine(week: 1) == "a13.week.1" && CoachHistory.weekLine(week: 13) == nil)
        #expect(CoachHistory.daysLine(activeDays: 7) == "a13.days.7" && CoachHistory.daysLine(activeDays: 0) == nil)
        #expect(CoachHistory.walkLine(walkNumber: 1) == nil && CoachHistory.walkLine(walkNumber: 5) == "a13.walk.5")
    }

    /// Nothing that sounds clinical or compares her with others (steady-claims).
    @Test func linesAreClaimFree() {
        let english = Dictionary(TestSupport.appContent.voiceLines.map { ($0.id, $0.text.lowercased()) }, uniquingKeysWith: { a, _ in a })
        for id in CoachHistory.allLineIDs {
            for banned in ["test", "score", "risk", "fall", "normal", "average", "than others"] {
                #expect(!(english[id] ?? "").contains(banned), "\(id): \(banned)")
            }
        }
    }
}
