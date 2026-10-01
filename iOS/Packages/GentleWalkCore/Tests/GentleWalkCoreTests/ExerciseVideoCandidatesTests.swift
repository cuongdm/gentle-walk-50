import Testing
@testable import GentleWalkCore

/// Which clip shows a move (content plan 30/09/2026 §3): the app plays the first file it has.
@Suite struct ExerciseVideoCandidatesTests {
    @Test func walkMovesPickTheClipForLevelAndPace() {
        let march = TestSupport.exercise("wk.march")
        #expect(march.videoCandidates(level: .seated, pace: .easy) == ["W1-1-easy.mp4", "W1-1.mp4"])
        #expect(march.videoCandidates(level: .inPlace, pace: .quicker) == ["W2-1-quick.mp4", "W2-1.mp4"])
        #expect(march.videoCandidates(level: .inPlace) == ["W2-1.mp4"])
        // The walking pad has no filmed coach yet: its painting shows.
        #expect(march.videoCandidates(level: .pad, pace: .easy).isEmpty)
        // Seated heel to back was never filmed.
        #expect(TestSupport.exercise("wk.heel-back").videoCandidates(level: .seated, pace: .easy).isEmpty)
    }

    @Test func otherExercisesFallBackToTheirMainClip() {
        let chest = TestSupport.exercise("st.chest")
        #expect(chest.videoCandidates(holding: true) == ["S5-hold.mp4", "S5.mp4"])
        #expect(chest.videoCandidates() == ["S5.mp4"])
        let sideLeg = TestSupport.exercise("mv.side-leg")
        #expect(sideLeg.videoCandidates(easier: true) == ["V8-1-easy.mp4", "V8-1.mp4"])
        let heelToe = TestSupport.exercise("mv.heel-toe")
        #expect(heelToe.videoCandidates(alternate: true) == ["V4-alt.mp4", "V4-1.mp4"])
        // Sideways walking has no clip of its own: the side step illustrates it (owner 30/09/2026).
        #expect(TestSupport.exercise("bl.side-walk").videoCandidates() == ["W2-2.mp4"])
    }

    @Test func everyExerciseUsedInASessionNamesItsClips() {
        let content = TestSupport.appContent
        let used = Set(content.sessions.flatMap { $0.segments.compactMap(\.exerciseID) })
        for exercise in content.exercises where used.contains(exercise.id) && exercise.id != "wk.arms" {
            #expect(!exercise.namedVideos.isEmpty, "\(exercise.id)")
        }
        // Every batch B clip is made (01/10/2026): the main clips are all required; the extras
        // (easier, hold) stay optional.
        let required = content.exercises.flatMap(\.namedVideos).filter(\.required).map(\.file)
        #expect(content.exercises.allSatisfy { ($0.videoLater ?? []).isEmpty })
        #expect(required.contains("W2-5.mp4"))
        #expect(required.contains("W1-2.mp4"))
        #expect(!required.contains("S5-hold.mp4"))
        #expect(content.exercises.filter { $0.kind == .stretch }.allSatisfy { $0.videoHold != nil })
    }

    @Test func variantNamesKeepTheExtension() {
        #expect(Exercise.variant("W2-1.mp4", "easy") == "W2-1-easy.mp4")
        #expect(Exercise.variant("clip", "quick") == "clip-quick")
    }
}

@Suite struct VoiceRotationTests {
    @Test func rotationStaysWithinTheLinesForHerLevelAndLimits() {
        let table = VoiceRotation.Table(lines: TestSupport.appContent.voiceLines)
        for day in 0..<8 {
            #expect(table.rotate("a2.brisk.again.1", by: day, level: .seated, limits: []) != "a2.brisk.again.2")
            #expect(table.rotate("a2.brisk.inplace.2", by: day, level: .inPlace, limits: [.jointReplacement]) != "a2.brisk.inplace.1")
        }
        #expect(table.rotate("a2.brisk.again.1", by: 1, level: .inPlace, limits: []) == "a2.brisk.again.2")
        // Lines that are not variants never change.
        #expect(table.rotate("a1.04", by: 3, level: .seated, limits: []) == "a1.04")
    }

    @Test func twoCuesOfOneFamilyStayDifferent() {
        let table = VoiceRotation.Table(lines: TestSupport.appContent.voiceLines)
        for day in 0..<6 {
            #expect(table.rotate("a4.demo.1", by: day, level: nil, limits: []) != table.rotate("a4.demo.2", by: day, level: nil, limits: []))
        }
    }
}
