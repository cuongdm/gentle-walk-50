import Foundation
import Testing
@testable import GentleWalk

@Suite struct MusicLibraryTests {
    @Test func emptyLibraryHidesMusic() throws {
        let library = try MusicLibrary(data: Data(#"{"schemaVersion": 1, "tracks": []}"#.utf8))
        #expect(library.styles.isEmpty)
        #expect(!library.showsMusicButton)
        #expect(library.defaultStyle == nil)
    }

    @Test func oneTrackMakesTheDefaultStyleAvailable() throws {
        let json = """
        {"schemaVersion": 1, "tracks": [{"id": "m1", "style": "feelGood", "kind": "walk", "file": "m1.m4a"}]}
        """
        let library = try MusicLibrary(data: Data(json.utf8))
        #expect(library.showsMusicButton)
        #expect(library.defaultStyle?.id == "feelGood")
        #expect(library.defaultStyle?.name == "Feel-good 70s and 80s")
    }

    @Test func eachSessionGetsItsOwnTrackAndFallsBackToTheFirst() throws {
        let json = """
        {"schemaVersion": 1, "tracks": [
          {"id": "w", "style": "feelGood", "kind": "walk", "file": "walk.m4a"},
          {"id": "s", "style": "feelGood", "kind": "stretch", "file": "stretch.m4a"}]}
        """
        let library = try MusicLibrary(data: Data(json.utf8))
        #expect(library.file(for: .walk) == "walk.m4a")
        #expect(library.file(for: .stretch) == "stretch.m4a")
        #expect(library.file(for: .chair) == "walk.m4a")
    }

    @Test func bundledTestTracksCoverEverySessionAndAreInTheApp() throws {
        let library = try MusicLibrary.load(bundle: .main)
        #expect(library.showsMusicButton)
        for kind in MusicKind.allCases {
            let file = try #require(library.file(for: kind), "no track for \(kind)")
            #expect(Bundle.main.url(forResource: (file as NSString).deletingPathExtension, withExtension: "m4a") != nil, "\(file) missing")
        }
    }
}
