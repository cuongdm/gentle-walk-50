import Testing
@testable import GentleWalkCore

/// Sessions of the content plan 30/09/2026 (docs/plans/2026-09-30-content-4-groups.md §2), built
/// from the app's real generated content.
@Suite struct SessionBuilderTests {
    let content = TestSupport.appContent
    let walkOnly = PlannedDay(main: .walk, chairMoves: 0, cooldown: false)
    let chairDay = PlannedDay(main: .chair, chairMoves: 0, cooldown: true)
    let stretchDay = PlannedDay(main: .stretch, chairMoves: 0, cooldown: false)

    func build(_ day: PlannedDay, _ level: WalkLevel = .seated, _ intensity: Intensity, limits: Set<BodyLimit> = [],
               rotation: Int = 0, variant: String? = nil) throws -> SessionPlan {
        try SessionBuilder.build(kind: day, level: level, intensity: intensity, limits: limits, rotationIndex: rotation,
                                 content: content, variant: variant)
    }

    /// The walk's move blocks: each move once, in order (easy and quicker parts of a block share it).
    func walkMoves(_ plan: SessionPlan) -> [String] {
        var moves: [String] = []
        for segment in plan.segments where segment.kind == .easy || segment.kind == .brisk {
            if let id = segment.exerciseID, moves.last != id { moves.append(id) }
        }
        return moves
    }

    // MARK: Walks (plan §2.1)

    @Test(arguments: [
        (Intensity.gentle, 60, 60, 0, ["wk.march", "wk.heel-dig", "wk.side-step"]),
        (.steady, 120, 40, 20, ["wk.march", "wk.side-step", "wk.knee-lift", "wk.heel-dig"]),
        (.strong, 120, 30, 30, ["wk.march", "wk.side-step", "wk.knee-lift", "wk.heel-dig", "wk.toe-tap", "wk.heel-back"]),
    ])
    func walkFramesFollowThePlan(_ intensity: Intensity, _ warm: Int, _ easy: Int, _ quick: Int, _ moves: [String]) throws {
        let plan = try build(walkOnly, .inPlace, intensity)
        #expect(plan.segments.first?.kind == .warmup)
        #expect(plan.segments.first?.seconds == warm)
        #expect(walkMoves(plan) == moves)
        #expect(plan.segments.filter { $0.kind == .easy }.allSatisfy { $0.seconds == easy })
        #expect(plan.segments.filter { $0.kind == .brisk }.count == (quick > 0 ? moves.count : 0))
        #expect(plan.segments.filter { $0.kind == .brisk }.allSatisfy { $0.seconds == quick })
        let cooldown = plan.segments.filter { $0.kind == .cooldown }.reduce(0) { $0 + $1.seconds }
        #expect(cooldown >= (intensity == .gentle ? 60 : 120))
        // The cool-down ends with the chest stretch and a closing line.
        #expect(plan.segments.last?.exerciseID == "st.chest")
    }

    @Test func fiveMinuteWalksHaveNoQuickerPart() throws {
        for level in WalkLevel.allCases {
            #expect(!(try build(walkOnly, level, .gentle)).segments.contains { $0.kind == .brisk })
            let commercial = try build(walkOnly, level, .gentle, variant: SessionBuilder.Variant.commercial)
            #expect(!commercial.segments.contains { $0.kind == .brisk })
            #expect(commercial.lineIDs.contains("a11.break.open.1"))
        }
        let commercial = try build(walkOnly, .seated, .gentle, variant: SessionBuilder.Variant.commercial)
        #expect(walkMoves(commercial) == ["wk.march", "wk.heel-dig", "wk.shift"])
    }

    @Test func seatedWalksAreNeverCalledBrisk() throws {
        let texts = Dictionary(uniqueKeysWithValues: content.voiceLines.map { ($0.id, $0.text.lowercased()) })
        for intensity in Intensity.allCases {
            for rotation in 0..<6 {
                let plan = try build(walkOnly, .seated, intensity, rotation: rotation)
                for id in plan.lineIDs {
                    #expect(!(texts[id] ?? "").contains("brisk"), "\(id)")
                    #expect(!(texts[id] ?? "").contains("moderate"), "\(id)")
                }
            }
        }
    }

    @Test func walkingPadMarchesAndUsesItsArms() throws {
        let plan = try build(walkOnly, .pad, .steady)
        #expect(walkMoves(plan) == ["wk.march", "wk.arms", "wk.march", "wk.arms"])
        #expect(plan.lineIDs.contains("a7.pad.start"))
        #expect(plan.lineIDs.contains("a7.pad.off"))
        #expect(!plan.exerciseIDs.contains("wk.side-step"))
    }

    @Test func bodyLimitsSwapTheHarderLineForASaferOne() throws {
        let plain = try build(walkOnly, .inPlace, .strong)
        let joint = try build(walkOnly, .inPlace, .strong, limits: [.jointReplacement])
        #expect(plain.lineIDs.contains("a2.move.march.harder"))
        #expect(!joint.lineIDs.contains("a2.move.march.harder"))
        #expect(joint.lineIDs.contains("a2.move.march.joint"))
        // "Lift your knees" never reaches someone with a joint replacement, whatever the rotation.
        for rotation in 0..<8 {
            #expect(!(try build(walkOnly, .inPlace, .strong, limits: [.jointReplacement], rotation: rotation)).lineIDs
                .contains("a2.brisk.inplace.1"))
        }
    }

    @Test func standingIsHardCoolsDownWithAnklesNotCalves() throws {
        let plain = try build(walkOnly, .inPlace, .steady)
        #expect(plain.exerciseIDs.contains("st.calf"))
        #expect(!plain.exerciseIDs.contains("st.ankle"))
        let seated = try build(walkOnly, .inPlace, .steady, limits: [.standingIsHard])
        #expect(!seated.exerciseIDs.contains("st.calf"))
        #expect(seated.exerciseIDs.contains("st.ankle"))
    }

    @Test func longWalkIsFifteenMinutesOnSteadyAndStrongDays() throws {
        let long = try build(PlannedDay(main: .longWalk, chairMoves: 0, cooldown: false), .inPlace, .steady)
        #expect(long.segments.first?.seconds == 180)
        #expect(walkMoves(long).count == 6)
        #expect(long.segments.filter { $0.kind == .brisk }.allSatisfy { $0.seconds == 30 })
        let achy = try build(PlannedDay(main: .longWalk, chairMoves: 0, cooldown: false), .inPlace, .gentle)
        #expect(achy == (try build(walkOnly, .inPlace, .gentle)))
    }

    @Test func walkDayAddsChairMovesThenOneCooldown() throws {
        let plan = try build(PlannedDay(main: .walk, chairMoves: 2, cooldown: true), .seated, .gentle)
        #expect(plan.blocks.map(\.kind) == [.walk, .chair, .cooldown])
        #expect(plan.segments.filter { $0.kind == .move }.count == 2)
        // The walk keeps its slow walking; the stretches come once, after the moves.
        let walk = try #require(plan.blocks.first)
        #expect(!walk.segments.contains { $0.exerciseID?.hasPrefix("st.") == true })
        #expect(plan.blocks.last?.segments.contains { $0.exerciseID == "st.chest" } == true)
        // Without the cool-down, the walk keeps its own stretches.
        let noCooldown = try build(PlannedDay(main: .walk, chairMoves: 1, cooldown: false), .seated, .gentle)
        #expect(noCooldown.blocks.first?.segments.last?.exerciseID == "st.chest")
    }

    @Test func rotationVariesWalkVoiceLines() throws {
        let a = try build(walkOnly, .seated, .steady, rotation: 0)
        let b = try build(walkOnly, .seated, .steady, rotation: 1)
        #expect(a.lineIDs != b.lineIDs)
        let known = Set(content.voiceLines.map(\.id))
        #expect(Set(a.lineIDs + b.lineIDs).isSubset(of: known))
    }

    // MARK: Chair moves (plan §2.2, A4 §5)

    @Test(arguments: [(Intensity.gentle, 3), (.steady, 5), (.strong, 6)])
    func chairDayHasItsMovesRestsAndCooldown(_ intensity: Intensity, _ moves: Int) throws {
        let plan = try build(chairDay, .seated, intensity)
        #expect(plan.blocks.map(\.kind) == [.chair, .cooldown])
        let chair = try #require(plan.blocks.first)
        #expect(chair.segments.first?.kind == .warmup)
        #expect(chair.segments.first?.seconds == (intensity == .gentle ? 60 : 90))
        #expect(chair.segments.filter { $0.kind == .move }.count == moves)
        // Every move is followed by a rest (15 s; Stronger 10 s) or a 30-second sit ↔ stand change.
        let rest = intensity == .strong ? 10 : 15
        #expect(chair.segments.filter { $0.kind == .rest }.allSatisfy { $0.seconds == rest || $0.seconds == 30 })
        #expect(chair.segments.filter { $0.kind == .rest }.count == moves)
        let cooldown = try #require(plan.blocks.last)
        #expect(cooldown.seconds >= 50)
        #expect(cooldown.segments.first?.exerciseID == "st.chest")
    }

    @Test func gentleChairDayStaysSeatedAndRotatesThroughTheSeatedMoves() throws {
        var used = Set<String>()
        var previous: [String] = []
        for day in 0..<5 {
            let ids = try build(chairDay, .seated, .gentle, rotation: day).segments.filter { $0.kind == .move }.compactMap(\.exerciseID)
            #expect(ids.count == 3)
            #expect(ids.allSatisfy { !TestSupport.exercise($0).standing })
            #expect(Set(ids).intersection(previous).count <= 1)
            used.formUnion(ids)
            previous = ids
        }
        #expect(used == Set(ChairSessionPlanner.seatedPool))
    }

    @Test func standingMovesComeWithAChangeToStandAndBack() throws {
        let plan = try build(chairDay, .seated, .strong)
        let lines = plan.lineIDs
        #expect(lines.contains("a4.to-stand.sts"))
        #expect(lines.contains("a4.to-stand.behind"))
        #expect(lines.contains("a4.to-sit.1"))
        // The session ends seated: the last change before the cool-down is back to the chair.
        let chair = try #require(plan.blocks.first)
        #expect(chair.segments.last?.cues.first?.line == "a4.to-sit.1")
    }

    @Test func standingIsHardKeepsEveryChairDaySeated() throws {
        for intensity in Intensity.allCases {
            let plan = try build(chairDay, .seated, intensity, limits: [.standingIsHard])
            let ids = plan.segments.filter { $0.kind == .move }.compactMap(\.exerciseID)
            #expect(ids.allSatisfy { !TestSupport.exercise($0).standing }, "\(intensity): \(ids)")
            #expect(Set(ids).count == ids.count)
        }
    }

    @Test func consecutiveChairDaysDiffer() throws {
        for intensity in Intensity.allCases {
            let plans = try (0..<6).map { try build(chairDay, .seated, intensity, rotation: $0) }
            for (a, b) in zip(plans, plans.dropFirst()) {
                #expect(a.exerciseIDs != b.exerciseIDs)
            }
        }
    }

    /// 06/10/2026 (review Q1, Otago 10 / NIA 10–15): Gentle 8, Steady 10, Strong 12; sit-to-stand 6 / 8 /
    /// two sets of 8 with a minute's rest between them.
    @Test func countedMovesCountSixToTwelveRepsASet() throws {
        for intensity in Intensity.allCases {
            let plan = try build(chairDay, .inPlace, intensity)
            for segment in plan.segments where segment.kind == .move {
                let exercise = TestSupport.exercise(try #require(segment.exerciseID))
                guard exercise.counting == .reps else { continue }
                let reps = try #require(segment.reps)
                #expect((exercise.id == "mv.sit-to-stand" ? 5...12 : 6...12).contains(reps))
                #expect(segment.cues.filter { $0.line.hasPrefix("a5.n.") }.count == reps * (segment.sets ?? 1))
            }
        }
        let strong = try build(chairDay, .inPlace, .strong)
        let sts = try #require(strong.segments.first { $0.exerciseID == "mv.sit-to-stand" })
        #expect(sts.sets == 2 && sts.reps == 8)
        #expect(sts.cues.contains { $0.line == "a4.v1.rest" } && sts.cues.contains { $0.line == "a4.v1.set2" })
    }

    // Steady program 2.7: Pro uses the reps she has earned (RepLadder.today), free keeps the day's own.
    @Test func proChairDayUsesEarnedReps() throws {
        let earned = ["mv.sit-to-stand": RepStep(sets: 2, reps: 10), "mv.side-leg": RepStep(sets: 2, reps: 10)]
        let plan = try SessionBuilder.build(kind: chairDay, level: .seated, intensity: .strong, limits: [], rotationIndex: 0,
                                            content: content, reps: earned)
        let sts = try #require(plan.segments.first { $0.exerciseID == "mv.sit-to-stand" })
        #expect(sts.reps == 10 && sts.sets == 2)
        // The next move is standing, so she is still told to stay standing after the last rep.
        #expect(sts.cues.contains { $0.line == "a4.to-stand.sts" })
        let side = try #require(plan.segments.first { $0.exerciseID == "mv.side-leg" })
        #expect(side.reps == 10 && side.sets == 2)
        let squat = try #require(plan.segments.first { $0.exerciseID == "mv.mini-squat" })
        #expect(squat.reps == 12)
    }

    @Test func freeChairDayUsesIntensityDefaults() throws {
        let plan = try build(chairDay, .seated, .strong)
        let sts = try #require(plan.segments.first { $0.exerciseID == "mv.sit-to-stand" })
        #expect(sts.reps == 8 && sts.sets == 2)
        let side = try #require(plan.segments.first { $0.exerciseID == "mv.side-leg" })
        #expect(side.reps == 12 && side.sets == nil)
    }

    @Test func easierVersionsFollowBodyLimits() throws {
        let plan = try build(chairDay, .seated, .steady, limits: [.knees])
        #expect(plan.easierExerciseIDs.contains("mv.sit-to-stand"))
        #expect(!plan.easierExerciseIDs.contains("mv.row"))
    }

    // MARK: Stretches (plan §2.3, A10 §3)

    /// 06/10/2026 (review Q4): Gentle 20 s, Steady and Strong 30 s; the key poses twice at every intensity;
    /// every session at most about 12 minutes.
    @Test(arguments: [(Intensity.gentle, 20), (.steady, 30), (.strong, 30)])
    func stretchDayHoldsPerIntensity(_ intensity: Intensity, _ hold: Int) throws {
        let plan = try build(stretchDay, .seated, intensity)
        #expect(plan.holdSeconds == hold)
        let held = plan.segments.filter { ($0.hold ?? 0) > 0 }
        #expect(!held.isEmpty)
        #expect(held.allSatisfy { $0.hold == hold })
        let chest = plan.segments.filter { $0.exerciseID == "st.chest" }.count
        #expect(chest == 2)
        for level in [WalkLevel.seated, .inPlace] {
            #expect(try build(stretchDay, level, intensity).totalSeconds <= 12 * 60 + 30)
        }
        #expect(plan.segments.last?.kind == .outro)
        #expect(plan.segments.contains { $0.kind == .cooldown && $0.seconds >= 50 })
    }

    @Test func stretchPosesFollowThePlan() throws {
        let gentle = try build(stretchDay, .seated, .gentle)
        #expect(firstSeen(gentle.segments.filter(\.isExercise).compactMap(\.exerciseID))
                == ["st.neck-turn", "st.chin-tuck", "st.chest", "st.twist", "st.thigh"])
        let standing = try build(stretchDay, .inPlace, .gentle)
        #expect(firstSeen(standing.segments.filter(\.isExercise).compactMap(\.exerciseID))
                == ["st.calf", "st.overhead", "st.side", "st.chest", "st.neck-turn"])
    }

    @Test func jointReplacementGetsAnklesInsteadOfTheThighStretch() throws {
        let plan = try build(stretchDay, .seated, .steady, limits: [.jointReplacement])
        #expect(!plan.exerciseIDs.contains("st.thigh"))
        #expect(plan.exerciseIDs.contains("st.ankle"))
        let standing = try build(stretchDay, .inPlace, .steady, limits: [.standingIsHard])
        #expect(!standing.exerciseIDs.contains("st.calf"))
    }

    // MARK: Extras (plan §2.4)

    @Test func balanceDeclaresTheHandsForEveryExercise() throws {
        for intensity in Intensity.allCases {
            let plan = try build(chairDay, .seated, intensity, variant: SessionBuilder.Variant.balance)
            #expect(plan.blocks.map(\.kind) == [.chair])
            let exercises = plan.segments.filter { $0.kind == .move }
            let expected: [String] = switch intensity {
            case .gentle: ["wk.shift", "mv.sit-to-stand", "bl.tandem", "mv.single-leg", "bl.side-walk", "mv.heel-toe"]
            case .steady: ["wk.shift", "mv.sit-to-stand", "bl.tandem", "mv.single-leg", "bl.side-walk", "bl.back-walk",
                           "mv.heel-toe"]
            case .strong: ["wk.shift", "mv.sit-to-stand", "bl.tandem", "mv.single-leg", "bl.walk-turn", "bl.back-walk",
                           "bl.heel-toe-walking", "mv.heel-toe"]
            }
            #expect(exercises.compactMap(\.exerciseID) == expected)
            // The Otago back extension warms up every level (06/10/2026).
            #expect(plan.exerciseIDs.contains("st.back-ext"))
            for segment in exercises {
                #expect(segment.cues.contains { $0.line.hasPrefix("a11.hands.") || $0.line.hasPrefix("a11.sts.") })
            }
        }
        // Someone who gets dizzy keeps both hands on the chair.
        let dizzy = try build(chairDay, .seated, .strong, limits: [.dizzy], variant: SessionBuilder.Variant.balance)
        #expect(!dizzy.lineIDs.contains("a11.hands.one"))
        #expect(!dizzy.lineIDs.contains("a11.hands.tips"))
        // Feeling unsteady: both hands, no walking backwards or heel and toe walking, no back extension.
        let unsteady = try build(chairDay, .seated, .strong, limits: [.unsteady], variant: SessionBuilder.Variant.balance)
        #expect(!unsteady.lineIDs.contains("a11.hands.one") && !unsteady.lineIDs.contains("a11.hands.tips"))
        #expect(!unsteady.exerciseIDs.contains("bl.back-walk"))
        #expect(!unsteady.exerciseIDs.contains("bl.heel-toe-walking"))
        #expect(!unsteady.exerciseIDs.contains("st.back-ext"))
        #expect(unsteady.exerciseIDs.contains("bl.walk-turn"))
    }

    // MARK: Steady set (review 06/10/2026 Q2)

    @Test func plannedDaysEndWithASteadySetOfAboutTwoMinutes() throws {
        let free = PlannedDay(main: .walk, chairMoves: 1, cooldown: true, steadySet: .gentle)
        for rotation in 0..<2 {
            let plan = try build(free, .seated, .strong, rotation: rotation)
            #expect(plan.blocks.last?.kind == .steady)
            let steady = try #require(plan.blocks.last)
            #expect((90...170).contains(steady.seconds), "\(steady.seconds) s")
            #expect(steady.segments.contains { $0.exerciseID == "bl.tandem" })
            #expect(steady.segments.contains { $0.exerciseID == (rotation == 0 ? "mv.sit-to-stand" : "mv.single-leg") })
            // Free is the gentle set: both hands on the chair, even on a strong day.
            let lines = steady.segments.flatMap { $0.cues.map(\.line) }
            #expect(lines.contains("a11.hands.two"))
            #expect(!lines.contains("a11.hands.one") && !lines.contains("a11.hands.tips"))
        }
    }

    @Test func steadySetFollowsBodyLimits() throws {
        let day = PlannedDay(main: .chair, chairMoves: 0, cooldown: true, steadySet: .matchingIntensity)
        for limit in [BodyLimit.unsteady, .dizzy] {
            let plan = try build(day, .inPlace, .strong, limits: [limit], rotation: 1)
            let steady = try #require(plan.blocks.last)
            #expect(!steady.segments.contains { $0.exerciseID == "mv.single-leg" }, "\(limit)")
            #expect(steady.segments.contains { $0.exerciseID == "mv.sit-to-stand" }, "\(limit)")
            let lines = steady.segments.flatMap { $0.cues.map(\.line) }
            #expect(!lines.contains("a11.hands.one") && !lines.contains("a11.hands.tips"), "\(limit)")
        }
        // Standing is hard: the seated set, no standing exercise.
        let seated = try build(day, .seated, .steady, limits: [.standingIsHard])
        let steady = try #require(seated.blocks.last)
        let standing = Set(content.exercises.filter(\.standing).map(\.id))
        #expect(steady.kind == .steady)
        #expect(steady.segments.compactMap(\.exerciseID).allSatisfy { !standing.contains($0) })
    }

    @Test func sessionsPickedOutsideThePlanHaveNoSteadySet() throws {
        let plan = try build(chairDay, .seated, .gentle, variant: SessionBuilder.Variant.balance)
        #expect(!plan.blocks.contains { $0.kind == .steady })
        #expect(!(try build(walkOnly, .seated, .gentle)).blocks.contains { $0.kind == .steady })
    }

    @Test func shorteningNeverCutsTheSteadySet() throws {
        let day = PlannedDay(main: .chair, chairMoves: 0, cooldown: true, steadySet: .matchingIntensity)
        let plan = try build(day, .inPlace, .strong)
        let short = plan.shortened(byMinutes: 10)
        #expect(short.blocks.last?.segments == plan.blocks.last?.segments)
    }

    @Test func morningStretchIsSeatedAndEndsStandingSlowly() throws {
        let plan = try build(stretchDay, .seated, .gentle, variant: SessionBuilder.Variant.morning)
        #expect(plan.blocks.map(\.kind) == [.stretch])
        #expect(plan.segments.last?.exerciseID == "mv.sit-to-stand")
        #expect(plan.lineIDs.contains("a11.morning.lightheaded"))
    }
}

/// Unique elements in first-seen order (a round-two segment repeats its pose).
private func firstSeen(_ ids: [String]) -> [String] {
    var seen = Set<String>()
    return ids.filter { seen.insert($0).inserted }
}
