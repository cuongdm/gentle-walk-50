import Testing
@testable import GentleWalkCore

@Suite struct TimelineEditingTests {
    let content = TestSupport.appContent

    func chairDay() throws -> SessionTimeline {
        let plan = try SessionBuilder.build(kind: PlannedDay(main: .chair, chairMoves: 0, cooldown: true), level: .seated,
                                            intensity: .gentle, limits: [], rotationIndex: 0, content: content)
        return SessionTimeline.make(plan: plan, voice: content.voiceLines)
    }

    func firstWalk() throws -> SessionTimeline {
        let template = try #require(content.sessions.first { $0.id == "ses.firstWalk" })
        return SessionTimeline.make(plan: SessionPlan(template: template), voice: content.voiceLines)
    }

    @Test func easierVersionReplacesTheRestOfThatExerciseAndKeepsTheOthers() throws {
        let timeline = try chairDay()
        let move = try #require(timeline.phases.first { $0.kind == .move })
        let at = move.start + 20
        let edited = TimelineEditing.apply(.easierVersion(exerciseID: move.exerciseID!), to: timeline, at: at)
        let parts = edited.phases.filter { $0.exerciseID == move.exerciseID }
        #expect(parts.map(\.isEasier) == [false, true])
        #expect(parts.last?.start == at)
        #expect(parts.last?.end == move.end)
        #expect(edited.total == timeline.total)
        // Later exercises are untouched.
        #expect(Array(edited.phases.drop { $0.end <= move.end }) == Array(timeline.phases.drop { $0.end <= move.end }))
        #expect(edited.voice.contains { $0.lineID == "a7.hurt.easier" && $0.start == at })
        #expect(!edited.voice.contains { $0.start > at && $0.start < move.end && $0.lineID.hasPrefix("a4.") })
    }

    /// The Skip control is silent (quick taps piled "We'll skip that one" up, owner 01/10): no edit
    /// line, and the next part's lines keep their place. This hurts -> Skip still speaks.
    @Test func silentSkipAddsNoLine() throws {
        let timeline = try chairDay()
        let move = try #require(timeline.phases.first { $0.kind == .move })
        let at = move.start + 5
        let silent = TimelineEditing.apply(.skip(spoken: false), to: timeline, at: at)
        #expect(!silent.voice.contains { $0.lineID == "a7.hurt.skip" })
        #expect(silent.total == timeline.total - (move.end - at))
        let spoken = TimelineEditing.apply(.skip(), to: timeline, at: at)
        #expect(spoken.voice.contains { $0.lineID == "a7.hurt.skip" && $0.start == at })
        #expect(spoken.phases == silent.phases)
    }

    @Test func skipDropsTheRestOfTheCurrentPartAndPullsTheRestForward() throws {
        let timeline = try firstWalk()
        let edited = TimelineEditing.apply(.skip(), to: timeline, at: 190)  // 3:10, second brisk (3:00–3:30)
        #expect(edited.total == 280)
        #expect(edited.phases.map(\.kind) == timeline.phases.map(\.kind))
        try #require(edited.phases.count == 7)
        #expect(edited.phases[4].end == 190)
        #expect(edited.phases[5].start == 190)
        #expect(edited.bells.map(\.at) == [27, 120, 150, 180, 190, 220, 274])
        #expect(edited.voice.contains { $0.lineID == "a7.hurt.skip" && $0.start == 190 })
    }

    @Test func walkHomeGentlyTurnsTheRestIntoAnEasyWalkUntilEnd() throws {
        let timeline = try firstWalk()
        let edited = TimelineEditing.apply(.walkHomeGently, to: timeline, at: 190)
        #expect(edited.isOpenEnded)
        let last = try #require(edited.phases.last)
        #expect(last.kind == .easy)
        #expect(last.start == 190)
        #expect(!edited.voice.contains { $0.start > 190 && $0.lineID != "a3.home.1" })
        #expect(edited.voice.contains { $0.lineID == "a3.home.1" && $0.start == 190 })
        #expect(edited.bells.allSatisfy { $0.at <= 190 })
    }
}

/// Walking home is open-ended: Skip and a second "Walk home" leave it as it is (review 02/10/2026).
@Suite struct OpenEndedEditTests {
    @Test func skipAndWalkHomeAgainLeaveAnOpenEndedWalkAlone() throws {
        let content = TestSupport.appContent
        let template = try #require(content.sessions.first { $0.id == "ses.firstWalk" })
        let walk = SessionTimeline.make(plan: SessionPlan(template: template), voice: content.voiceLines)
        let home = TimelineEditing.apply(.walkHomeGently, to: walk, at: 60)
        #expect(home.isOpenEnded)
        #expect(TimelineEditing.apply(.skip(), to: home, at: 90) == home)
        #expect(TimelineEditing.apply(.walkHomeGently, to: home, at: 90) == home)
    }
}
