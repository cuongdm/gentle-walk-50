import Foundation
import GentleWalkCore

/// The bundled content, loaded once on first use. A broken bundle is a build error (content tests
/// and the release check guard it), so a failure here falls back to empty content instead of crashing.
enum AppContent {
    static let bundle: ContentBundle = (try? ContentStore.load(bundle: .main)) ?? ContentBundle()
}
