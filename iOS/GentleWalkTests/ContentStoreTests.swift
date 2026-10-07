import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

@Suite struct ContentStoreTests {
    @Test func bundledContentHasNoErrors() throws {
        let bundle = try ContentStore.load(bundle: .main)
        let issues = ContentValidator.validate(bundle, mode: .development, bundledFiles: Self.bundledFiles())

        #expect(!issues.contains { $0.severity == .error }, "errors: \(issues.filter { $0.severity == .error })")
        // Content plan 30/09/2026: 8 walk moves, 12 chair moves, 12 stretches, 3 balance exercises; 06/10/2026
        // (review 58–75): + Standing back extension and three Otago balance exercises.
        #expect(bundle.exercises.filter { $0.kind == .walk }.count == 8)
        #expect(bundle.exercises.filter { $0.kind == .move }.count == 12)
        #expect(bundle.exercises.filter { $0.kind == .stretch }.count == 13)
        #expect(bundle.exercises.filter { $0.kind == .balance }.count == 6)
        #expect(bundle.journeys.count == 5)
        #expect(bundle.sessions.contains { $0.id == "ses.firstWalk" })
        #expect(bundle.voiceLines.count >= 590)
        // Voice files arrive with task 1.6; until then every line is a development warning.
        let warnings = issues.filter { $0.code == .missingVoiceFile }.count
        print("content warnings (missing voice files): \(warnings)")
    }

    /// Clip names in exercises.json against the files in the app (Resources/Media/Video). Lists every
    /// missing clip; fails only for a clip that must ship now (batch B clips are listed in `videoLater`,
    /// easier and hold clips are optional). A clip dropped in later needs no code change.
    @Test func requiredClipsAreBundled() throws {
        let bundle = try ContentStore.load(bundle: .main)
        let files = Self.bundledFiles()
        var missingRequired: [String] = []
        var missingLater: [String] = []
        for exercise in bundle.exercises {
            for (file, required) in exercise.namedVideos where !files.contains(file) {
                if required { missingRequired.append("\(exercise.id) → \(file)") } else { missingLater.append(file) }
            }
        }
        print("clips still to come (not required yet): \(Set(missingLater).sorted())")
        #expect(missingRequired.isEmpty, "required clips missing from the app: \(missingRequired)")
    }

    /// Every clip in the app is used by some exercise (directly or as its -easy / -quick version).
    @Test func everyBundledClipIsUsed() throws {
        let bundle = try ContentStore.load(bundle: .main)
        var named = Set<String>()
        for exercise in bundle.exercises {
            for (file, _) in exercise.namedVideos {
                named.formUnion([file, Exercise.variant(file, "easy"), Exercise.variant(file, "quick")])
            }
        }
        let unused = Self.bundledFiles().filter { $0.hasSuffix(".mp4") && !named.contains($0) && !SceneVideo.all.contains($0) }
        #expect(unused.isEmpty, "clips no exercise uses: \(unused.sorted())")
    }

    /// File names of the clips in the app bundle.
    static func bundledFiles() -> Set<String> {
        let urls = Bundle.main.urls(forResourcesWithExtension: "mp4", subdirectory: nil) ?? []
        return Set(urls.map(\.lastPathComponent))
    }
}
