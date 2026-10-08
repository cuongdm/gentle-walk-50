import Foundation
import Testing
@testable import GentleWalkCore

/// Everyday wins (D9): short labels for Progress (one line on the smallest iPhone), ids kept stable so a
/// win she already ticked stays ticked.
@Suite struct EverydayWinsContentTests {
    struct Win: Decodable { var id: String; var text: String; var hiddenFor: [String] }
    struct File: Decodable { var wins: [Win] }
    struct Overlay: Decodable { var wins: [String: String] }

    @Test func shortLabelsStableIdsAndVietnamese() throws {
        let folder = TestSupport.repositoryRoot.appendingPathComponent("iOS/App/Resources/Content")
        let wins = try JSONDecoder().decode(File.self, from: Data(contentsOf: folder.appendingPathComponent("wins.json"))).wins
        let vietnamese = try JSONDecoder().decode(Overlay.self, from: Data(contentsOf: folder.appendingPathComponent("content.vi.json"))).wins
        #expect(wins.map(\.id) == (1...8).map { "win.\($0)" })
        for win in wins {
            #expect(win.text.split(separator: " ").count <= 6, "\(win.id): \(win.text)")
            #expect(win.text.count <= 32, "\(win.id) fits one line")
            #expect(vietnamese[win.id]?.isEmpty == false, "VI \(win.id)")
        }
        // Only the floor win is hidden for "I can't get down on the floor".
        #expect(wins.filter { $0.hiddenFor == ["noFloor"] }.map(\.id) == ["win.5"])
    }
}
