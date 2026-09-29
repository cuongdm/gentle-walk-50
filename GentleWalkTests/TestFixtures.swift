import Foundation
import GentleWalkCore
@testable import GentleWalk

/// Shared helpers for app tests: fixture URLs in the test bundle and the bundled content.
enum TestFixtures {
    private final class Marker {}
    static let bundle = Bundle(for: Marker.self)

    static func url(_ name: String, _ ext: String) -> URL {
        bundle.url(forResource: name, withExtension: ext)!
    }

    static let content: ContentBundle = try! ContentStore.load(bundle: .main)

    static func firstWalkTimeline() -> SessionTimeline {
        let template = content.sessions.first { $0.id == "ses.firstWalk" }!
        return SessionTimeline.make(plan: SessionPlan(template: template), voice: content.voiceLines)
    }

    /// A 30-second timeline: three one-second lines and two bells.
    static func shortTimeline() -> SessionTimeline {
        let template = SessionTemplate(id: "t", kind: .walk, segments: [
            .init(kind: .warmup, seconds: 10, cues: [.init(at: 1, line: "v1")]),
            .init(kind: .brisk, seconds: 10, cues: [.init(at: 0, line: "v2")]),
            .init(kind: .easy, seconds: 10, cues: [.init(at: 4, line: "v3")]),
        ])
        let lines = ["v1", "v2", "v3"].map { VoiceLine(id: $0, text: "Line \($0).", duration: 1) }
        return SessionTimeline.make(plan: SessionPlan(template: template), voice: lines)
    }
}
