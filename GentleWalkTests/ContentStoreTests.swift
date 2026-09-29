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
}
