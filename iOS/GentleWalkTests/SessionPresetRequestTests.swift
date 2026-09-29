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

    @Test func balanceAlwaysUsesTheSameMoves() {
        let balance = SessionCatalog.preset(id: "extra.balance")!
        #expect(balance.request(limits: [], rotationIndex: 11).rotationIndex == 5)
        #expect(SessionCatalog.preset(id: "chair.gentle")!.request(limits: [], rotationIndex: 11).rotationIndex == 11)
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
