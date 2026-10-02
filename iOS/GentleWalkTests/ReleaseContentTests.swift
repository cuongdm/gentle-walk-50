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

    /// A language whose coach is being recorded ships all of it: Release never speaks with the system
    /// voice. A language with no recordings at all keeps the English coach (AppContent.texts) and is
    /// not offered in Me, so it does not block an English release (i18n, 02/10/2026). Record with
    /// tools/voice/render_lines.py --voice bella-v4-vi, attach with tools/i18n/build_content_overlay.py.
    @Test(arguments: AppLanguage.allCases.filter { $0 != .english })
    func everyLanguageHasItsRecordings(language: AppLanguage) throws {
        let english = try ContentStore.load(bundle: .main)
        let texts = try #require(language.contentTexts())
        // Offered (and its coach heard) only once every line is recorded; until then Release keeps the
        // English coach, so a partly recorded language does not block an English release.
        guard texts.hasAllRecordings else { return }
        let localized = english.localized(texts)
        let errors = ContentValidator.validate(localized, mode: .release, bundledFiles: ContentStoreTests.bundledFiles())
            .filter { $0.severity == .error }
        #expect(errors.isEmpty, "\(language.rawValue): \(errors.count) content errors, first: \(errors.prefix(5).map(\.detail))")
    }
}
