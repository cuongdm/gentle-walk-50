import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

@Suite struct ContentStoreTests {
    @Test func bundledContentHasNoErrors() throws {
        let bundle = try ContentStore.load(bundle: .main)
        let issues = ContentValidator.validate(bundle, mode: .development)

        #expect(!issues.contains { $0.severity == .error }, "errors: \(issues.filter { $0.severity == .error })")
        #expect(bundle.exercises.count == 14)
        #expect(bundle.journeys.count == 5)
        #expect(bundle.sessions.contains { $0.id == "ses.firstWalk" })
        #expect(bundle.voiceLines.count >= 240)
        // Voice files arrive with task 1.6; until then every line is a development warning.
        let warnings = issues.filter { $0.code == .missingVoiceFile }.count
        print("content warnings (missing voice files): \(warnings)")
    }

    @Test func everyMoveVideoIsBundled() throws {
        let bundle = try ContentStore.load(bundle: .main)
        let moves = bundle.exercises.filter { $0.kind == .move }
        #expect(moves.count == 6)
        for move in moves {
            let file = try #require(move.videoFile, "\(move.id) has no video")
            let name = (file as NSString).deletingPathExtension
            #expect(Bundle.main.url(forResource: name, withExtension: "mp4") != nil, "\(file) not in bundle")
        }
        // Stretches have no clip yet: nil is allowed.
        #expect(bundle.exercises.filter { $0.kind == .stretch }.allSatisfy { $0.videoFile == nil })
    }
}
