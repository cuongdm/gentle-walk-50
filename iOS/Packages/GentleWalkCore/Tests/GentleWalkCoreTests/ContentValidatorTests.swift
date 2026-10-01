import Testing
@testable import GentleWalkCore

@Suite struct ContentValidatorTests {
    /// A small bundle that is valid in release mode; each case below breaks exactly one rule.
    static func validBundle() -> ContentBundle {
        let stops = (0..<6).map { Journey.Stop(id: "pc.ny.\($0)", name: "Stop \($0)", mile: Double($0)) }
        return ContentBundle(
            exercises: [
                Exercise(id: "mv.a", kind: .move, name: "A", purpose: "p", tips: [], easier: "e", counting: .timed, standing: false),
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
        // Session rules of the exercise standards §7.
        Case(name: "brisk before two minutes of warm-up", mutate: { bundle in
            bundle.sessions.append(SessionTemplate(id: "ses.w", kind: .walk, segments: [
                .init(kind: .warmup, seconds: 60), .init(kind: .brisk, seconds: 30), .init(kind: .cooldown, seconds: 60),
            ]))
        }, expected: .briskBeforeWarmUp),
        Case(name: "seated walk hears brisk", mutate: { bundle in
            bundle.voiceLines.append(VoiceLine(id: "a2.x", text: "Brisk again.", file: "x.m4a"))
            bundle.sessions.append(SessionTemplate(id: "ses.s", kind: .walk, segments: [
                .init(kind: .warmup, seconds: 120, cues: [.init(at: 0, line: "a2.x")]),
            ], level: .seated))
        }, expected: .briskWhileSeated),
        Case(name: "seated walk uses a standing line", mutate: { bundle in
            bundle.voiceLines.append(VoiceLine(id: "a2.y", text: "Soft knees.", file: "y.m4a", levels: [.inPlace, .pad]))
            bundle.sessions.append(SessionTemplate(id: "ses.s", kind: .walk, segments: [
                .init(kind: .warmup, seconds: 120, cues: [.init(at: 0, line: "a2.y")]),
            ], level: .seated))
        }, expected: .briskWhileSeated),
        Case(name: "counted move with too few reps", mutate: { bundle in
            bundle.exercises[0].counting = .reps
            bundle.sessions[0].segments[0].reps = 4
        }, expected: .repsOutOfRange),
        Case(name: "hold over thirty seconds", mutate: { $0.sessions[0].segments[0].hold = 40 }, expected: .holdTooLong),
        Case(name: "balance exercise without hands", mutate: { bundle in
            bundle.sessions.append(SessionTemplate(id: "ses.b", kind: .balance, segments: [
                .init(kind: .move, seconds: 40, exerciseID: "mv.a", cues: [.init(at: 0, line: "a1.01")]),
            ]))
        }, expected: .balanceWithoutHands),
        Case(name: "eyes closed", mutate: { bundle in
            bundle.voiceLines.append(VoiceLine(id: "a11.z", text: "Now close your eyes.", file: "z.m4a"))
        }, expected: .balanceWithoutHands),
        Case(name: "eight-minute walk with a short cool-down", mutate: { bundle in
            bundle.sessions.append(SessionTemplate(id: "ses.c", kind: .walk, segments: [
                .init(kind: .warmup, seconds: 120), .init(kind: .easy, seconds: 300), .init(kind: .cooldown, seconds: 60),
            ]))
        }, expected: .cooldownTooShort),
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

    @Test func countedMoveWithEveryRepCountedPasses() {
        var bundle = Self.validBundle()
        bundle.exercises[0].counting = .reps
        bundle.voiceLines += (1...6).map { VoiceLine(id: "a5.n.\($0)", text: "\($0).", file: "n\($0).m4a") }
        bundle.sessions[0].segments[0].reps = 6
        bundle.sessions[0].segments[0].cues += (1...6).map { .init(at: 5 * $0, line: "a5.n.\($0)") }
        #expect(ContentValidator.validate(bundle, mode: .release).isEmpty)
    }

    @Test func missingClipIsAnErrorInReleaseOnlyWhenItMustShipNow() {
        var bundle = Self.validBundle()
        bundle.exercises[0].videoFile = "V1-1.mp4"
        bundle.exercises[0].videoEasy = "V1-alt.mp4"
        let complete = ContentValidator.validate(bundle, mode: .release, bundledFiles: ["V1-1.mp4"])
        // The easier clip is optional: missing it is only a warning.
        #expect(complete.filter { $0.code == .missingVideoFile }.map(\.severity) == [.warning])
        let missing = ContentValidator.validate(bundle, mode: .release, bundledFiles: [])
        #expect(missing.contains { $0.code == .missingVideoFile && $0.severity == .error && $0.detail == "mv.a → V1-1.mp4" })
        bundle.exercises[0].videoLater = ["V1-1.mp4"]
        let later = ContentValidator.validate(bundle, mode: .release, bundledFiles: [])
        #expect(!later.contains { $0.severity == .error })
        // Without the bundle listing nothing is checked.
        #expect(!ContentValidator.validate(bundle, mode: .release).contains { $0.code == .missingVideoFile })
    }

    @Test func appContentPassesEveryRule() {
        let issues = ContentValidator.validate(TestSupport.appContent, mode: .development)
        #expect(!issues.contains { $0.severity == .error }, "\(issues.filter { $0.severity == .error }.prefix(8))")
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
