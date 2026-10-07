import Foundation
import Testing
@testable import GentleWalkCore

/// Voice against picture (review 06/10/2026, owner: "media sync audio video"): with the recorded line
/// lengths, a line pushed back by the one before it must not drift far from where the script put it,
/// and the coach's counts must land on their reps. Checked for every kind of planned day, in English
/// and Vietnamese (longer lines).
@Suite struct SessionSyncTests {
    static let vietnamese: ContentBundle = {
        let url = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("App/Resources/Content/content.vi.json")
        let texts = try! JSONDecoder().decode(ContentLocalization.self, from: Data(contentsOf: url))
        return TestSupport.appContent.localized(texts)
    }()

    struct Drift { var seconds: Double; var line: String }

    /// Each cue's start in the built timeline minus where the script placed it.
    static func drifts(_ plan: SessionPlan, lines: [VoiceLine]) -> [Drift] {
        let timeline = SessionTimeline.make(plan: plan, voice: lines)
        var planned: [(at: Double, line: String)] = []
        var t = 0.0
        let segments = plan.segments
        let lastCue = segments.indices.last { !segments[$0].cues.isEmpty }.map { ($0, segments[$0].cues.count - 1) }
        for (i, segment) in segments.enumerated() {
            let bellHere = i > 0 && SessionTimeline.pacedKinds.contains(segment.kind)
            for (j, cue) in segment.cues.enumerated() {
                var at = t + Double(cue.at)
                if bellHere && cue.at == 0 { at += SessionTimeline.bellLead }
                if let lastCue, lastCue == (i, j) { at += SessionTimeline.bellLead }
                planned.append((at, cue.line))
            }
            t += Double(segment.seconds)
        }
        planned.sort { $0.at < $1.at }
        return zip(planned, timeline.voice).map { Drift(seconds: $1.start - $0.at, line: $1.lineID) }
    }

    static var plans: [(String, SessionPlan)] {
        var out: [(String, SessionPlan)] = []
        let content = TestSupport.appContent
        let limitSets: [Set<BodyLimit>] = [[], [.knees], [.unsteady], [.dizzy, .jointReplacement], [.standingIsHard]]
        let days: [(String, PlannedDay.Main, Int, Bool)] = [("walk", .walk, 1, false), ("walk+cool", .walk, 2, true),
                                                            ("chair", .chair, 0, true), ("stretch", .stretch, 0, false),
                                                            ("long", .longWalk, 0, true)]
        for (name, main, moves, cooldown) in days {
            for intensity in Intensity.allCases {
                for level in [WalkLevel.seated, .inPlace] {
                    for limits in limitSets {
                        for rotation in 0..<2 {
                            let day = PlannedDay(main: main, chairMoves: moves, cooldown: cooldown, steadySet: .matchingIntensity)
                            if let plan = try? SessionBuilder.build(kind: day, level: level, intensity: intensity, limits: limits,
                                                                     rotationIndex: rotation, content: content) {
                                out.append(("\(name) \(intensity) \(level) \(limits.map(\.rawValue).sorted()) r\(rotation)", plan))
                            }
                        }
                    }
                }
            }
        }
        for intensity in Intensity.allCases {
            let balance = PlannedDay(main: .chair, chairMoves: 0, cooldown: false)
            for limits in limitSets {
                if let plan = try? SessionBuilder.build(kind: balance, level: .inPlace, intensity: intensity, limits: limits,
                                                         rotationIndex: 0, content: content, variant: SessionBuilder.Variant.balance) {
                    out.append(("balance \(intensity) \(limits.map(\.rawValue).sorted())", plan))
                }
            }
        }
        return out
    }

    @Test(arguments: ["en", "vi"])
    func voiceStaysWithThePicture(_ language: String) {
        let lines = language == "en" ? TestSupport.appContent.voiceLines : Self.vietnamese.voiceLines
        var worst = Drift(seconds: 0, line: "")
        var worstCount = Drift(seconds: 0, line: "")
        var worstName = "", worstCountName = ""
        for (name, plan) in Self.plans {
            for drift in Self.drifts(plan, lines: lines) {
                if drift.seconds > worst.seconds { worst = drift; worstName = name }
                if drift.line.hasPrefix("a5.n."), drift.seconds > worstCount.seconds { worstCount = drift; worstCountName = name }
            }
        }
        print("[\(language)] \(Self.plans.count) plans · worst drift \(worst.seconds) s (\(worst.line), \(worstName)) · worst count \(worstCount.seconds) s (\(worstCount.line), \(worstCountName))")
        #expect(worst.seconds <= 3.5, "\(language): \(worst.line) \(worst.seconds) s in \(worstName)")
        #expect(worstCount.seconds <= 1.0, "\(language): count \(worstCount.line) \(worstCount.seconds) s in \(worstCountName)")
    }
}
