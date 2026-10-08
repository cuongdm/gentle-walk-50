import Testing
@testable import GentleWalkCore

@Suite struct SessionCatalogTests {
    @Test func idsAreUniqueAndFindable() {
        let ids = SessionCatalog.all.map(\.id)
        #expect(Set(ids).count == ids.count)
        for preset in SessionCatalog.all {
            #expect(SessionCatalog.preset(id: preset.id) == preset)
        }
    }

    @Test(arguments: SessionPreset.Group.allCases)
    func everyGroupHasOneToSixSessions(_ group: SessionPreset.Group) {
        let presets = SessionCatalog.presets(in: group)
        #expect((1...6).contains(presets.count))
        #expect(presets.allSatisfy { $0.group == group })
    }

    @Test func freePlanGetsEveryWalkAndTheLightestChairAndStretch() {
        #expect(SessionCatalog.presets(in: .walks).allSatisfy { $0.isFree })
        #expect(SessionCatalog.presets(in: .chair).filter { $0.isFree }.map(\.id) == ["chair.gentle"])
        #expect(SessionCatalog.presets(in: .stretch).filter { $0.isFree }.map(\.id) == ["stretch.seated.gentle"])
        #expect(SessionCatalog.presets(in: .extras).allSatisfy { !$0.isFree })
    }

    @Test func presetsMatchTheirKind() {
        #expect(SessionCatalog.presets(in: .walks).allSatisfy { $0.main == .walk || $0.main == .longWalk })
        #expect(SessionCatalog.presets(in: .chair).allSatisfy { $0.main == .chair })
        #expect(SessionCatalog.presets(in: .stretch).allSatisfy { $0.main == .stretch })
        #expect(SessionCatalog.preset(id: "stretch.standing.gentle")?.standing == true)
        #expect(SessionCatalog.preset(id: "stretch.seated.gentle")?.standing == false)
    }

    // MARK: Swap today's session (10.2)

    @Test func walkDayOffersTheOtherKindsAndFiveMinutes() {
        let ids = SessionCatalog.swapOptions(planned: .walk).map(\.id)
        #expect(ids == ["chair.gentle", "stretch.seated.gentle", SessionCatalog.justFiveMinutesID])
        #expect(SessionCatalog.swapOptions(planned: .longWalk).map(\.id) == ids)
    }

    @Test func chairAndStretchDaysOfferAWalk() {
        #expect(SessionCatalog.swapOptions(planned: .chair).map(\.id) == ["walk.steady", "stretch.seated.gentle", SessionCatalog.justFiveMinutesID])
        #expect(SessionCatalog.swapOptions(planned: .stretch).map(\.id) == ["walk.steady", "chair.gentle", SessionCatalog.justFiveMinutesID])
    }

    @Test func restDayOffersNothingAndSwapsAreAlwaysFree() {
        #expect(SessionCatalog.swapOptions(planned: nil).isEmpty)
        for main in [PlannedDay.Main.walk, .longWalk, .chair, .stretch] {
            #expect(SessionCatalog.swapOptions(planned: main).allSatisfy { $0.isFree })
        }
    }

    /// Steady program 2.7a: every rep step is a pre-built segment with the coach's counts, and the
    /// day's own amount in `ses.moves.<intensity>` is the ladder's default step.
    @Test func everyRepStepHasAVariant() throws {
        let content = TestSupport.appContent
        for id in RepLadder.exercises {
            for (index, step) in RepLadder.steps(for: id).enumerated() {
                let template = try SessionBuilder.template(RepLadder.templateID(id, step: index), in: content)
                let moves = template.segments.filter { $0.exerciseID == id }
                #expect(moves.count == 1, "\(template.id)")
                #expect(moves.first?.reps == step.reps, "\(template.id)")
                #expect((moves.first?.sets ?? 1) == step.sets, "\(template.id)")
            }
            for intensity in Intensity.allCases {
                let library = try SessionBuilder.template("ses.moves.\(intensity.rawValue)", in: content)
                let move = try #require(library.segments.first { $0.exerciseID == id })
                let base = RepLadder.steps(for: id)[RepLadder.defaultStep(id, intensity: intensity)]
                #expect(move.reps == base.reps && (move.sets ?? 1) == base.sets, "\(id) \(intensity)")
            }
        }
    }
}
