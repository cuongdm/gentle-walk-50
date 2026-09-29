import Foundation
import Testing
@testable import GentleWalkCore

@Suite struct ContentDecodingTests {
    private func miniBundleData() throws -> Data {
        let url = try #require(Bundle.module.url(forResource: "content-mini", withExtension: "json", subdirectory: "Fixtures"))
        return try Data(contentsOf: url)
    }

    @Test func decodesMiniBundle() throws {
        let bundle = try ContentBundle.decode(from: miniBundleData())

        #expect(bundle.schemaVersion == 1)
        #expect(bundle.exercises.count == 2)
        #expect(bundle.journeys.count == 1)
        #expect(bundle.journeys[0].stops.count == 6)
        #expect(bundle.voiceLines.count == 3)
        #expect(bundle.sessions.count == 1)

        let stretch = try #require(bundle.exercises.first { $0.id == "st.thigh" })
        #expect(stretch.kind == .stretch)
        #expect(stretch.counting == .hold)
        #expect(stretch.hiddenFor == [.jointReplacement])
        #expect(stretch.harder == nil)

        let move = try #require(bundle.exercises.first { $0.id == "mv.sit-to-stand" })
        #expect(move.kind == .move)
        #expect(move.videoFile == "V1-1.mp4")

        let timed = try #require(bundle.voiceLines.first { $0.id == "a2.brisk.seated.1" })
        #expect(timed.words?.count == 2)
        #expect(bundle.sessions[0].segments[2].exerciseID == "st.thigh")
        #expect(bundle.sessions[0].segments[1].kind == .brisk)
    }
}
