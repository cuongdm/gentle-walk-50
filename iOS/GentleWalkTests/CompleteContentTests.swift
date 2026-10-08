import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

/// Complete (S15) words and pictures (plan 08/10/2026 task 3.6, 3.7): the cheer of the session, the
/// session number, and every everyday win with its own icon.
@MainActor @Suite struct CompleteContentTests {
    let walkDay = PlannedDay(main: .walk, chairMoves: 0, cooldown: false)

    func request(place: WorkoutPlace = .indoors, firstWalk: Bool = false) -> WorkoutRequest {
        var request = WorkoutRequest(day: walkDay, level: .seated, intensity: .steady, place: place, limits: [], rotationIndex: 0)
        request.isFirstWalk = firstWalk
        return request
    }

    func result(_ context: CheerContext, index: Int = 0, number: Int = 13) -> CompletionResult {
        var result = CompletionResult(sessionMiles: 0.6, activeDays: 13)
        result.cheerContext = context
        result.cheer = CompleteCheer.pick(context, sessionIndex: index, lastID: nil)
        result.sessionNumber = number
        return result
    }

    /// A special moment says its own words; the line under the title always comes from the cheer.
    @Test func specialMomentUsesTheCheer() {
        let result = result(.weekDone)
        let content = CompleteContent(result: result, request: request(), minutes: 12, name: "Margaret", content: TestFixtures.content)
        #expect(content.title == result.cheer?.title)
        #expect(content.subtitle == result.cheer?.line)
        #expect(content.sessionLine == "Session 13 · done")
    }

    /// An ordinary session keeps her name in the title; the line still turns.
    @Test func ordinaryKeepsHerName() {
        let lines = (0..<3).map { index in
            CompleteContent(result: result(.ordinary, index: index), request: request(), minutes: 12, name: "Margaret",
                            content: TestFixtures.content)
        }
        #expect(lines.allSatisfy { $0.title == "You did it, Margaret!" })
        #expect(Set(lines.compactMap(\.subtitle)).count == 3)
        // Without a name, the cheer's own title.
        let nameless = CompleteContent(result: result(.ordinary), request: request(), minutes: 12, name: nil, content: TestFixtures.content)
        #expect(nameless.title == CompleteCheer.pick(.ordinary, sessionIndex: 0, lastID: nil).title)
    }

    /// Stopping for pain keeps its calm words: no cheer.
    @Test func stoppedForPainHasNoCheer() {
        let content = CompleteContent(result: result(.personalBest), request: request(), minutes: 4, name: "Margaret",
                                      content: TestFixtures.content, stoppedForPain: true)
        #expect(content.title == "Good call to stop.")
        #expect(content.variant == .stoppedForPain)
    }

    /// Every cheer is in the String Catalog in every shipped language.
    @Test(arguments: AppLanguage.allCases.filter { $0 != .english })
    func cheersAreTranslated(language: AppLanguage) throws {
        let path = try #require(Bundle.main.path(forResource: language.rawValue, ofType: "lproj"))
        let bundle = try #require(Bundle(path: path))
        for cheer in CheerContext.allCases.flatMap(CompleteCheer.pool) {
            for key in [cheer.title, cheer.line] {
                let text = bundle.localizedString(forKey: key, value: "∅", table: nil)
                #expect(text != "∅" && text != key, "\(cheer.id): \(key)")
            }
        }
    }

    /// Each win has its own picture (one symbol, one meaning), and every win in the content has one.
    @Test func everyWinHasItsOwnIcon() throws {
        struct File: Decodable { var wins: [EverydayWinItem] }
        let url = try #require(Bundle.main.url(forResource: "wins", withExtension: "json"))
        let wins = try JSONDecoder().decode(File.self, from: Data(contentsOf: url)).wins
        #expect(wins.count == 8)
        let icons = wins.map(\.icon)
        #expect(Set(icons).count == wins.count)
        #expect(!icons.contains(.everydayWins))
    }
}
