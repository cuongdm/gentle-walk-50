import Foundation
import Testing
@testable import GentleWalkCore

/// A language overlay swaps texts by id and leaves everything else English (i18n, 01/10/2026).
@Suite struct ContentLocalizationTests {
    let english = ContentBundle(
        exercises: [Exercise(id: "mv.sit-to-stand", kind: .move, name: "Sit-to-stand", purpose: "For getting up from chairs",
                             tips: ["Feet flat", "Lean forward"], easier: "Use your hands", harder: "Slower down",
                             counting: .reps, standing: false,
                             limitNotes: [.init(limit: .knees, text: "Keep your knees comfortable")]),
                    Exercise(id: "wk.march", kind: .walk, name: "March", purpose: "For family walks", tips: ["Tall"],
                             easier: "Smaller steps", counting: .timed, standing: false)],
        journeys: [Journey(id: "jr.ny", title: "New York City", isFree: true,
                           stops: [.init(id: "s1", name: "Central Park Zoo", mile: 0, back: "A zoo.", coachLine: "Hello zoo")],
                           subtitle: "Central Park to Brooklyn Bridge")],
        voiceLines: [VoiceLine(id: "a1.01", text: "Hi.", file: "a1.01.m4a", duration: 1, words: [.init(word: "Hi.", start: 0, end: 1)]),
                     VoiceLine(id: "a1.02", text: "Sit tall.", file: "a1.02.m4a", duration: 1)])

    @Test func translatedFieldsReplaceEnglishByID() {
        let vi = ContentLocalization(
            language: "vi",
            exercises: ["mv.sit-to-stand": .init(name: "Ngồi xuống đứng lên", tips: ["Bàn chân phẳng", "Nghiêng người"],
                                                 limitNotes: ["knees": "Giữ gối thoải mái"])],
            journeys: ["jr.ny": .init(subtitle: "Từ Central Park tới cầu Brooklyn", stops: ["s1": .init(back: "Một sở thú.")])],
            voiceLines: ["a1.01": .init(text: "Chào bạn.", file: "a1.01.vi.m4a", duration: 1.2)])
        let out = english.localized(vi)
        let sit = out.exercises[0]
        #expect(sit.name == "Ngồi xuống đứng lên")
        #expect(sit.purpose == "For getting up from chairs")
        #expect(sit.tips == ["Bàn chân phẳng", "Nghiêng người"])
        #expect(sit.note(for: [.knees]) == "Giữ gối thoải mái")
        #expect(out.exercises[1] == english.exercises[1])
        #expect(out.journeys[0].title == "New York City")
        #expect(out.journeys[0].subtitle == "Từ Central Park tới cầu Brooklyn")
        #expect(out.journeys[0].stops[0].name == "Central Park Zoo")
        #expect(out.journeys[0].stops[0].back == "Một sở thú.")
        #expect(out.voiceLines[0].text == "Chào bạn.")
        #expect(out.voiceLines[0].file == "a1.01.vi.m4a")
        #expect(out.voiceLines[0].words == nil)
        #expect(out.voiceLines[1] == english.voiceLines[1])
    }

    /// A translated line without its recording never plays the English audio under the new words.
    @Test func aTranslatedLineWithoutRecordingDropsTheEnglishFile() {
        let vi = ContentLocalization(language: "vi", voiceLines: ["a1.02": .init(text: "Ngồi thẳng lưng.")])
        let line = english.localized(vi).voiceLines[1]
        #expect(line.text == "Ngồi thẳng lưng.")
        #expect(line.file == nil)
        #expect(line.duration == nil)
    }

    /// A tips list of another length is ignored (the screen numbers tips by position).
    @Test func mismatchedTipsKeepTheEnglish() {
        let vi = ContentLocalization(language: "vi", exercises: ["wk.march": .init(tips: ["Một", "Hai"])])
        #expect(english.localized(vi).exercises[1].tips == ["Tall"])
    }

    @Test func decodesTheOverlayFile() throws {
        let json = #"{"schemaVersion":1,"language":"vi","exercises":{},"journeys":{},"voiceLines":{"a1.01":{"text":"Chào bạn."}},"notifications":{"nt.1":"Xin chào"},"wins":{}}"#
        let decoded = try JSONDecoder().decode(ContentLocalization.self, from: Data(json.utf8))
        #expect(decoded.voiceLines["a1.01"]?.text == "Chào bạn.")
        #expect(decoded.notifications["nt.1"] == "Xin chào")
    }
}
