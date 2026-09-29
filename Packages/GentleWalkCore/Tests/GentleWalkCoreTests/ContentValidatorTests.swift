import Testing
@testable import GentleWalkCore

@Suite struct ContentValidatorTests {
    /// A small bundle that is valid in release mode; each case below breaks exactly one rule.
    static func validBundle() -> ContentBundle {
        let stops = (0..<6).map { Journey.Stop(id: "pc.ny.\($0)", name: "Stop \($0)", mile: Double($0)) }
        return ContentBundle(
            exercises: [
                Exercise(id: "mv.a", kind: .move, name: "A", purpose: "p", tips: [], easier: "e", counting: .reps, standing: false),
            ],
            journeys: [Journey(id: "jr.ny", title: "New York", isFree: true, stops: stops)],
            voiceLines: [VoiceLine(id: "a1.01", text: "Hi.", file: "a1.01.m4a", duration: 1)],
            sessions: [
                SessionTemplate(id: "ses.1", kind: .chair, segments: [
                    .init(kind: .move, seconds: 40, exerciseID: "mv.a", cues: [.init(at: 0, line: "a1.01")]),
                ]),
            ]
        )
    }

    struct Case: Sendable, CustomTestStringConvertible {
        let name: String
        let mutate: @Sendable (inout ContentBundle) -> Void
        let expected: ContentIssue.Code
        var testDescription: String { name }
    }

    static let cases: [Case] = [
        Case(name: "duplicate id", mutate: { $0.exercises.append($0.exercises[0]) }, expected: .duplicateID),
        Case(name: "stops not increasing", mutate: { $0.journeys[0].stops[3].mile = 0.5 }, expected: .stopsNotIncreasing),
        Case(name: "journey without 6 stops", mutate: { $0.journeys[0].stops.removeLast() }, expected: .wrongStopCount),
        Case(name: "session references missing exercise", mutate: { $0.sessions[0].segments[0].exerciseID = "mv.nope" }, expected: .missingExercise),
        Case(name: "cue references missing voice line", mutate: { $0.sessions[0].segments[0].cues[0].line = "a9.nope" }, expected: .missingVoiceLine),
        Case(name: "no free journey", mutate: { $0.journeys[0].isFree = false }, expected: .noFreeJourney),
    ]

    @Test func validBundleHasNoIssues() {
        #expect(ContentValidator.validate(Self.validBundle(), mode: .release).isEmpty)
    }

    @Test(arguments: cases)
    func reportsBrokenRuleAsError(_ testCase: Case) {
        var bundle = Self.validBundle()
        testCase.mutate(&bundle)
        let issues = ContentValidator.validate(bundle, mode: .release)
        #expect(issues.contains { $0.code == testCase.expected && $0.severity == .error })
    }

    @Test func missingVoiceFileIsWarningInDevelopmentAndErrorInRelease() {
        var bundle = Self.validBundle()
        bundle.voiceLines[0].file = nil
        let dev = ContentValidator.validate(bundle, mode: .development)
        let rel = ContentValidator.validate(bundle, mode: .release)
        #expect(dev.contains { $0.code == .missingVoiceFile && $0.severity == .warning })
        #expect(!dev.contains { $0.severity == .error })
        #expect(rel.contains { $0.code == .missingVoiceFile && $0.severity == .error })
    }
}
