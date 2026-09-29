import Foundation

/// A music style offered in the player and in Settings (S20).
struct MusicStyle: Equatable, Identifiable, Sendable {
    var id: String
    var name: String
    var files: [String]
}

/// Workout music from `App/Resources/Content/music.json` (task 3.12). The library may be empty
/// until licensed tracks arrive: then the player hides Music and Settings shows "Coming soon".
struct MusicLibrary: Equatable, Sendable {
    private struct File: Decodable {
        struct Track: Decodable { var id: String; var style: String; var file: String }
        var schemaVersion: Int
        var tracks: [Track]
    }

    /// Style ids in display order with their names; the first one that has tracks is the default.
    static let knownStyles: [(id: String, name: String)] = [
        ("feelGood", "Feel-good 70s and 80s"),
        ("calm", "Calm acoustic"),
        ("upbeat", "Upbeat pop"),
    ]

    private(set) var styles: [MusicStyle]

    init(data: Data) throws {
        let file = try JSONDecoder().decode(File.self, from: data)
        let byStyle = Dictionary(grouping: file.tracks, by: \.style)
        styles = Self.knownStyles.compactMap { style in
            guard let tracks = byStyle[style.id], !tracks.isEmpty else { return nil }
            return MusicStyle(id: style.id, name: style.name, files: tracks.map(\.file))
        }
    }

    static func load(bundle: Bundle) throws -> MusicLibrary {
        guard let url = bundle.url(forResource: "music", withExtension: "json") else {
            return try MusicLibrary(data: Data(#"{"schemaVersion": 1, "tracks": []}"#.utf8))
        }
        return try MusicLibrary(data: Data(contentsOf: url))
    }

    var showsMusicButton: Bool { !styles.isEmpty }
    var defaultStyle: MusicStyle? { styles.first }
}
