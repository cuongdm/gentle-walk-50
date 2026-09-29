import Foundation
import Testing
@testable import GentleWalk

@Suite struct MusicLibraryTests {
    @Test func bundledLibraryStartsEmpty() throws {
        let library = try MusicLibrary.load(bundle: .main)
        #expect(library.styles.isEmpty)
        #expect(!library.showsMusicButton)
        #expect(library.defaultStyle == nil)
    }

    @Test func oneTrackMakesTheDefaultStyleAvailable() throws {
        let json = """
        {"schemaVersion": 1, "tracks": [{"id": "m1", "style": "feelGood", "file": "m1.m4a"}]}
        """
        let library = try MusicLibrary(data: Data(json.utf8))
        #expect(library.showsMusicButton)
        #expect(library.defaultStyle?.id == "feelGood")
        #expect(library.defaultStyle?.name == "Feel-good 70s and 80s")
    }
}
