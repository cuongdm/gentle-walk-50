import Foundation
import GentleWalkCore

/// The app's language (i18n, owner 01/10/2026): English by default, Vietnamese next. The String
/// Catalog gives the screen words; `content.<code>.json` gives exercises, journeys, coach lines,
/// notifications and wins; voice recordings come per language. Adding a language: a catalog
/// column, one content file, its recordings, and a case here.
enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case english = "en"
    case vietnamese = "vi"

    var id: String { rawValue }

    /// Shown in its own language, so anyone can find theirs.
    var nativeName: String {
        switch self {
        case .english: "English"
        case .vietnamese: "Tiếng Việt"
        }
    }

    /// "Close and open again" in this language itself: whoever picks it can read it.
    var reopenHint: String {
        switch self {
        case .english: "To see it in English, close \(AppBrand.name) and open it again: swipe up from the bottom edge, then swipe \(AppBrand.name) up to close it."
        case .vietnamese: "Để xem bằng tiếng Việt, hãy đóng hẳn \(AppBrand.name) rồi mở lại: vuốt lên từ cạnh dưới màn hình, rồi vuốt \(AppBrand.name) lên để đóng."
        }
    }

    /// Voice for lines that have no recording yet (development only).
    var speechCode: String {
        switch self {
        case .english: "en-US"
        case .vietnamese: "vi-VN"
        }
    }

    /// What the app is showing now (the bundle resolves it at launch).
    static var current: AppLanguage {
        let code = Bundle.main.preferredLocalizations.first ?? "en"
        return AppLanguage(rawValue: String(code.prefix(2))) ?? .english
    }

    static let choiceKey = "appLanguage"

    /// The iPhone's language when the app has it, English otherwise (owner 02/10/2026; iOS resolves it
    /// from the app's localizations at launch). A pick in Me or in the app's page in iOS Settings wins.
    /// What Me shows as chosen: a pick waiting for the next launch (Me or iOS Settings write the
    /// app's own AppleLanguages), else what shows now.
    static func picked(defaults: UserDefaults = .standard) -> AppLanguage {
        let domain = defaults.persistentDomain(forName: Bundle.main.bundleIdentifier ?? "")
        let pick = (domain?["AppleLanguages"] as? [String])?.first.map { String($0.prefix(2)) }
        return pick.flatMap(AppLanguage.init) ?? current
    }

    /// Picked in Me; the app shows it from its next launch. Same preference as the app's page in
    /// iOS Settings → Language (that page shows only when the iPhone has two languages or more, so the
    /// app offers it too).
    static func choose(_ language: AppLanguage, defaults: UserDefaults = .standard) {
        defaults.set(language.rawValue, forKey: choiceKey)
        defaults.set([language.rawValue], forKey: "AppleLanguages")
    }

    /// Languages Me offers: English, and each other one once its coach is recorded (Release never
    /// speaks with the system voice, so an unrecorded language would guide in silence). Development
    /// builds offer every language, to test them.
    static var selectable: [AppLanguage] {
        #if DEBUG
        allCases
        #else
        allCases.filter { $0 == .english || $0.contentTexts()?.hasAllRecordings == true }
        #endif
    }

    /// The content texts of this language, or nil for English (the source).
    func contentTexts(bundle: Bundle = .main) -> ContentLocalization? {
        guard self != .english, let url = bundle.url(forResource: "content.\(rawValue)", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(ContentLocalization.self, from: data)
    }
}
