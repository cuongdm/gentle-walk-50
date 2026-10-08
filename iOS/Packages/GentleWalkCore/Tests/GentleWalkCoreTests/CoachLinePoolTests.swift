import Foundation
import Testing
@testable import GentleWalkCore

/// Coach line pools (plan 3.9, anti-boredom #1): interchangeable lines rotate by day so the next
/// sessions sound different; lines with a fixed role (an opener, "almost there") never rotate.
@Suite struct CoachLinePoolTests {
    let table = VoiceRotation.Table(lines: TestSupport.appContent.voiceLines)

    func days(_ id: String, _ count: Int = 5, level: WalkLevel? = .inPlace) -> [String] {
        (0..<count).map { table.rotate(id, by: $0, level: level, limits: []) }
    }

    /// Warm-up cues after the opener rotate: five sessions in a row, five different lines.
    @Test func warmUpDoesNotRepeatInFiveSessions() {
        #expect(Set(days("a2.warm.4")).count == 5)
        // The opener "Easy steps to start." keeps its place.
        #expect(Set(days("a2.warm.1")) == ["a2.warm.1"])
        // Seated: only the lines written for every level ("chỉ In place / Pad" lines are left out).
        let seated = days("a2.warm.4", 8, level: .seated)
        #expect(seated.allSatisfy { !["a2.warm.2", "a2.warm.6", "a2.warm.8"].contains($0) })
        #expect(Set(seated).count == 4)
    }

    /// One session never says the same warm-up line twice (the rotation is a shift, not a draw).
    @Test func aSessionNeverRepeatsALine() {
        let sequence = ["a2.warm.2", "a2.warm.6", "a2.warm.3", "a2.warm.5", "a2.warm.4", "a2.warm.7"]
        for day in 0..<10 {
            let rotated = sequence.map { table.rotate($0, by: day, level: .inPlace, limits: []) }
            #expect(Set(rotated).count == sequence.count, "day \(day): \(rotated)")
        }
    }

    /// Encouragement lines rotate, but never the ones that are only true sometimes.
    @Test func encouragementPoolLeavesOutSituationalLines() {
        let lines = Set(days("a6.1", 12))
        #expect(lines.count == 8)
        #expect(!lines.contains("a6.6"))  // "a little stronger than last time"
        #expect(!lines.contains("a6.9"))  // "almost there"
        #expect(Set(days("a6.9")) == ["a6.9"])
    }

    /// Small pools alternate day by day: Break comfort, the outdoor opener, welcome back.
    @Test func twoLinePoolsAlternate() {
        for id in ["a7.break.1", "a3.open.1", "a9.back.1"] {
            let two = days(id, 2)
            #expect(Set(two).count == 2, "\(id): \(two)")
        }
    }

    /// Content checks see every line a pooled cue can become.
    @Test func alternativesListThePool() {
        #expect(Set(table.alternatives(of: "a2.warm.3", level: .inPlace)).count == 7)
        #expect(table.alternatives(of: "a2.warm.1", level: .inPlace) == ["a2.warm.1"])
    }
}
