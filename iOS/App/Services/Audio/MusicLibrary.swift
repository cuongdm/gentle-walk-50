import Foundation

/// Which part of the day a track is made for (walk pace, chair moves, stretching).
enum MusicKind: String, CaseIterable, Codable, Sendable { case walk, chair, stretch }

/// A music style offered in the player and in Settings (S20).
struct MusicStyle: Equatable, Identifiable, Sendable {
    var id: String
    var name: String
    /// File per session kind; kinds without their own track use the first one.
    var files: [MusicKind: String]
    var firstFile: String?
}

/// Workout music from `App/Resources/Content/music.json` (task 3.12). The library may be empty
/// until licensed tracks arrive: then the player hides Music and Settings shows "Coming soon".
struct MusicLibrary: Equatable, Sendable {
    private struct File: Decodable {
        struct Track: Decodable { var id: String; var style: String; var kind: MusicKind?; var file: String }
        var schemaVersion: Int
        var tracks: [Track]
    }

    /// Style ids in display order with their names; the first one that has tracks is the default.
    static let knownStyles: [(id: String, name: String)] = [
        ("feelGood", String(localized: "Feel-good 70s and 80s")),
        ("calm", String(localized: "Calm acoustic")),
        ("upbeat", String(localized: "Upbeat pop")),
    ]

    private(set) var styles: [MusicStyle]

    init(data: Data) throws {
        let file = try JSONDecoder().decode(File.self, from: data)
        let byStyle = Dictionary(grouping: file.tracks, by: \.style)
        styles = Self.knownStyles.compactMap { style in
            guard let tracks = byStyle[style.id], !tracks.isEmpty else { return nil }
            var files: [MusicKind: String] = [:]
            for track in tracks { if let kind = track.kind, files[kind] == nil { files[kind] = track.file } }
            return MusicStyle(id: style.id, name: style.name, files: files, firstFile: tracks.first?.file)
        }
    }

    static func load(bundle: Bundle) throws -> MusicLibrary {
        guard let url = bundle.url(forResource: "music", withExtension: "json") else {
            return try MusicLibrary(data: Data(#"{"schemaVersion": 1, "tracks": []}"#.utf8))
        }
        return try MusicLibrary(data: Data(contentsOf: url))
    }

    /// The default style's track for this kind of session.
    func file(for kind: MusicKind) -> String? {
        guard let style = defaultStyle else { return nil }
        return style.files[kind] ?? style.firstFile
    }

    func url(for kind: MusicKind, in bundle: Bundle = .main) -> URL? {
        guard let file = file(for: kind) else { return nil }
        return bundle.url(forResource: (file as NSString).deletingPathExtension, withExtension: (file as NSString).pathExtension)
    }

    var showsMusicButton: Bool { !styles.isEmpty }
    var defaultStyle: MusicStyle? { styles.first }
}
