import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

/// Release gate (task 9.2): every voice line recorded, every stretch pose has a clip. RED is
/// expected until the real assets arrive; it must be GREEN before submitting.
/// Run with:  TEST_RUNNER_RELEASE_CHECK=1 xcodebuild test … -only-testing:GentleWalkTests/ReleaseContentTests
@Suite(.enabled(if: ProcessInfo.processInfo.environment["RELEASE_CHECK"] == "1", "set RELEASE_CHECK=1 to run the release gate"))
struct ReleaseContentTests {
    @Test func releaseContentIsComplete() throws {
        let content = try ContentStore.load(bundle: .main)
        let errors = ContentValidator.validate(content, mode: .release).filter { $0.severity == .error }
        #expect(errors.isEmpty, "\(errors.count) content errors, first: \(errors.prefix(5).map(\.detail))")
        let missingClips = content.exercises.filter { $0.videoFile == nil }.map(\.id)
        #expect(missingClips.isEmpty, "exercises without a clip: \(missingClips)")
    }
}
