import Foundation
import GentleWalkCore

/// The bundled content, loaded once on first use. A broken bundle is a build error (content tests
/// and the release check guard it), so a failure here falls back to empty content instead of crashing.
/// In another language than English, its texts (`content.<code>.json`) replace the English ones.
enum AppContent {
    /// This language's texts, nil in English. In a release build a language picked in iOS Settings
    /// before its coach is recorded keeps the English coach (heard), not silent lines.
    static let texts: ContentLocalization? = {
        guard let texts = AppLanguage.current.contentTexts() else { return nil }
        #if DEBUG
        return texts
        #else
        return texts.hasAllRecordings ? texts : texts.withoutCoachLines
        #endif
    }()

    static let bundle: ContentBundle = {
        let english = (try? ContentStore.load(bundle: .main)) ?? ContentBundle()
        return texts.map(english.localized) ?? english
    }()
}
