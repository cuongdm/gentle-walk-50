import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

/// Every shipped language covers the whole app (i18n, 01/10/2026): its content file names every
/// exercise, journey, stop, coach line, notification and win, and its screen words exist.
@MainActor @Suite struct LocalizationTests {
    /// The English source, whatever language the test run uses.
    let english = (try? ContentStore.load(bundle: .main)) ?? ContentBundle()

    @Test(arguments: AppLanguage.allCases.filter { $0 != .english })
    func contentFileCoversEveryID(language: AppLanguage) throws {
        let texts = try #require(language.contentTexts(), "content.\(language.rawValue).json is missing")
        #expect(texts.language == language.rawValue)
        for exercise in english.exercises {
            let t = try #require(texts.exercises[exercise.id], "exercise \(exercise.id)")
            #expect(t.name?.isEmpty == false)
            #expect(t.tips?.count == exercise.tips.count, "tips of \(exercise.id)")
        }
        for journey in english.journeys {
            let t = try #require(texts.journeys[journey.id], "journey \(journey.id)")
            for stop in journey.stops where stop.back != nil {
                #expect(t.stops?[stop.id]?.back?.isEmpty == false, "postcard \(stop.id)")
            }
        }
        let missingLines = english.voiceLines.map(\.id).filter { texts.voiceLines[$0] == nil }
        #expect(missingLines.isEmpty, "coach lines without \(language.rawValue): \(missingLines.prefix(10))")
        let phrases = try PhraseBank.load(bundle: .main, texts: [:]).phrases.map(\.id)
        #expect(phrases.allSatisfy { texts.notifications[$0] != nil }, "notifications")
        #expect(texts.wins.count >= 8)
    }

    /// The String Catalog compiled a table for each language, and a few everyday words differ from English.
    @Test(arguments: AppLanguage.allCases.filter { $0 != .english })
    func screenWordsAreTranslated(language: AppLanguage) throws {
        let path = try #require(Bundle.main.path(forResource: language.rawValue, ofType: "lproj"))
        let bundle = try #require(Bundle(path: path))
        for key in ["Start", "Continue", "This hurts", "Break", "Today", "Language"] {
            let text = bundle.localizedString(forKey: key, value: "∅", table: nil)
            #expect(text != "∅" && text != key, "\(key) in \(language.rawValue)")
        }
        // The body area keeps its own key, apart from the Back button.
        #expect(bundle.localizedString(forKey: "body.back", value: nil, table: nil)
                != bundle.localizedString(forKey: "Back", value: nil, table: nil))
    }

    /// A pick is written where iOS reads it at the next launch (the iPhone's language is the default,
    /// English when the app does not have it; owner 02/10/2026).
    @Test func aChoiceIsWrittenForTheNextLaunch() throws {
        let defaults = try #require(UserDefaults(suiteName: "LocalizationTests"))
        defaults.removePersistentDomain(forName: "LocalizationTests")
        AppLanguage.choose(.vietnamese, defaults: defaults)
        #expect(defaults.persistentDomain(forName: "LocalizationTests")?["AppleLanguages"] as? [String] == ["vi"])
        #expect(defaults.string(forKey: AppLanguage.choiceKey) == "vi")
    }
}
