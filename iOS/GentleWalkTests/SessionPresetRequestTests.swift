import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

@MainActor @Suite struct SessionPresetRequestTests {
    @Test(arguments: SessionCatalog.all)
    func everyPresetBuildsAPlayableSession(_ preset: SessionPreset) throws {
        let request = preset.request(limits: [], rotationIndex: 3)
        #expect(request.presetID == preset.id)
        #expect(request.day.main == preset.main)
        #expect(request.intensity == preset.intensity)
        #expect(preset.minutes(content: TestFixtures.content) > 0)
    }

    @Test func seatedStretchKeepsHerSeatedAndStandingDoesNot() {
        let seated = SessionCatalog.preset(id: "stretch.seated.gentle")!.request(limits: [.knees], rotationIndex: 0)
        #expect(seated.limits == [.knees, .standingIsHard])
        let standing = SessionCatalog.preset(id: "stretch.standing.gentle")!.request(limits: [.knees], rotationIndex: 0)
        #expect(standing.limits == [.knees])
    }

    @Test func extrasPlayTheirOwnTemplates() throws {
        let balance = SessionCatalog.preset(id: "extra.balance")!
        let moves = try (0..<3).map { day in
            try balance.request(limits: [], rotationIndex: day).plan(content: TestFixtures.content).exerciseIDs
        }
        #expect(moves.allSatisfy { $0 == moves[0] })
        #expect(moves[0].contains("bl.tandem"))
        #expect(balance.request(limits: [], rotationIndex: 0).variant == SessionBuilder.Variant.balance)
        #expect(balance.request(limits: [], rotationIndex: 0).title == "Balance")
        let morning = try SessionCatalog.preset(id: "extra.morning")!.request(limits: [], rotationIndex: 0).plan(content: TestFixtures.content)
        #expect(morning.lineIDs.contains("a11.morning.open"))
        let commercial = try SessionCatalog.preset(id: "extra.commercial")!.request(limits: [], rotationIndex: 0).plan(content: TestFixtures.content)
        #expect(commercial.lineIDs.contains("a11.break.open.1"))
    }

    @Test func standingStretchIsBuiltStanding() throws {
        let standing = try SessionCatalog.preset(id: "stretch.standing.gentle")!.request(limits: [], rotationIndex: 0)
            .plan(content: TestFixtures.content)
        #expect(standing.exerciseIDs.contains("st.calf"))
        let seated = try SessionCatalog.preset(id: "stretch.seated.gentle")!.request(limits: [], rotationIndex: 0)
            .plan(content: TestFixtures.content)
        #expect(!seated.exerciseIDs.contains("st.calf"))
    }

    @Test func previewRowsAreUniqueAndBalanceKeepsItsMoves() {
        for preset in SessionCatalog.all {
            let model = WorkoutPreviewModel(day: PlannedDay(main: preset.main, chairMoves: 0, cooldown: false), intensity: preset.intensity,
                                            checkIn: nil, suggestedLevel: preset.level, limits: [], rotationIndex: 0,
                                            content: TestFixtures.content, presetID: preset.id, standing: preset.standing)
            let ids = model.rows.map(\.id)
            #expect(Set(ids).count == ids.count, "\(preset.id): \(ids)")
            #expect(!ids.isEmpty)
            if preset.variant == SessionBuilder.Variant.balance {
                #expect(model.rows.allSatisfy { $0.swappableExerciseID == nil })
                #expect(model.title.hasPrefix("Balance · "))
            }
        }
    }

    @Test func doItAgainFollowsThePlan() {
        let planned = WorkoutRequest(day: PlannedDay(main: .walk, chairMoves: 1, cooldown: false), level: .seated,
                                     intensity: .steady, place: .indoors, limits: [], rotationIndex: 0)
        #expect(planned.canReplay(isPro: false))
        #expect(!WorkoutRequest.firstWalk(limits: []).canReplay(isPro: true))
        let proOnly = SessionCatalog.preset(id: "chair.strong")!.request(limits: [], rotationIndex: 0)
        #expect(!proOnly.canReplay(isPro: false))
        #expect(proOnly.canReplay(isPro: true))
        #expect(SessionCatalog.preset(id: "walk.long")!.request(limits: [], rotationIndex: 0).canReplay(isPro: false))
    }

    @Test func previewKeepsThePickedSessionAndItsStance() {
        let preset = SessionCatalog.preset(id: "stretch.standing.steady")!
        let model = WorkoutPreviewModel(day: PlannedDay(main: .stretch, chairMoves: 0, cooldown: false), intensity: .steady,
                                        checkIn: nil, suggestedLevel: .seated, limits: [.knees], rotationIndex: 0,
                                        content: TestFixtures.content, presetID: preset.id, standing: preset.standing)
        #expect(model.standingStretch)
        #expect(model.request.presetID == preset.id)
        #expect(!model.request.limits.contains(.standingIsHard))
    }
}
