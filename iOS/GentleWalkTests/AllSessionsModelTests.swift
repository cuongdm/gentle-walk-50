import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

@MainActor @Suite(.serialized) struct AllSessionsModelTests {
    let defaults: UserDefaults = {
        let defaults = UserDefaults(suiteName: "all-sessions-tests")!
        defaults.removePersistentDomain(forName: "all-sessions-tests")
        return defaults
    }()

    func model(isPro: Bool, limits: Set<BodyLimit> = []) -> AllSessionsModel {
        AllSessionsModel(isPro: isPro, limits: limits, rotationIndex: 2, content: TestFixtures.content,
                         favourites: FavouriteSessions(defaults: defaults))
    }

    @Test func fourGroupsInOrderWithLengths() {
        let model = model(isPro: true)
        #expect(model.sections.map(\.group) == [.walks, .chair, .stretch, .extras])
        #expect(model.sections.allSatisfy { !$0.items.isEmpty && $0.items.allSatisfy { $0.detail.hasSuffix(" min") } })
        #expect(model.sections.flatMap(\.items).allSatisfy { !$0.isLocked })
    }

    @Test func freePlanLocksAllButWalksAndTheLightestChairAndStretch() {
        let open = model(isPro: false).sections.flatMap(\.items).filter { !$0.isLocked }.map(\.id)
        #expect(open == ["walk.gentle", "walk.steady", "walk.strong", "walk.long", "chair.gentle", "stretch.seated.gentle"])
    }

    @Test func sessionsWithAFilmedMoveAreMarkedVideo() {
        let items = model(isPro: true).sections.flatMap(\.items)
        let video = Set(items.filter(\.hasVideo).map(\.id))
        // The seated and in-place march (W1-1, W2-1) and the first six chair moves ship with the app.
        #expect(video.isSuperset(of: ["walk.gentle", "walk.steady", "walk.strong", "chair.gentle", "chair.steady",
                                      "chair.strong", "extra.commercial", "extra.balance"]))
    }

    @Test func favouritesComeFirstInTheOrderAdded() {
        let model = model(isPro: true)
        #expect(model.favouriteItems.isEmpty)
        model.toggleFavourite("extra.balance")
        model.toggleFavourite("walk.long")
        #expect(model.favouriteItems.map(\.id) == ["extra.balance", "walk.long"])
        #expect(model.isFavourite("walk.long"))
        model.toggleFavourite("extra.balance")
        #expect(model.favouriteItems.map(\.id) == ["walk.long"])
    }

    @Test func standingIsHardHidesStandingStretchesAndBalance() {
        let sections = model(isPro: true, limits: [.standingIsHard]).sections
        let stretches = sections.first { $0.group == .stretch }?.items.map(\.id)
        #expect(stretches == ["stretch.seated.gentle", "stretch.seated.steady"])
        let extras = sections.first { $0.group == .extras }?.items.map(\.id)
        #expect(extras == ["extra.commercial", "extra.morning"])
    }

    @Test func cardsShowTheRealLength() throws {
        let items = model(isPro: true).sections.flatMap(\.items)
        for item in items {
            let seconds = try item.request.plan(content: TestFixtures.content).totalSeconds
            #expect(item.detail == "\(max(1, Int((Double(seconds) / 60).rounded()))) min")
        }
    }
}
