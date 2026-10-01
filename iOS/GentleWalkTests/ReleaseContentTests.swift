import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

/// Release gate (task 9.2): every voice line recorded, every clip that must ship (all but the
/// batch B clips in `videoLater`) is in the app. RED is expected until the real assets arrive; it
/// must be GREEN before submitting.
/// Run with:  TEST_RUNNER_RELEASE_CHECK=1 xcodebuild test … -only-testing:GentleWalkTests/ReleaseContentTests
@Suite(.enabled(if: ProcessInfo.processInfo.environment["RELEASE_CHECK"] == "1", "set RELEASE_CHECK=1 to run the release gate"))
struct ReleaseContentTests {
    @Test func releaseContentIsComplete() throws {
        let content = try ContentStore.load(bundle: .main)
        let errors = ContentValidator.validate(content, mode: .release, bundledFiles: ContentStoreTests.bundledFiles())
            .filter { $0.severity == .error }
        #expect(errors.isEmpty, "\(errors.count) content errors, first: \(errors.prefix(5).map(\.detail))")
    }
}
