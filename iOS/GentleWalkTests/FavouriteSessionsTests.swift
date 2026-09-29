import Foundation
import Testing
import GentleWalkCore
@testable import GentleWalk

@MainActor @Suite(.serialized) struct FavouriteSessionsTests {
    let defaults: UserDefaults = {
        let defaults = UserDefaults(suiteName: "favourite-tests")!
        defaults.removePersistentDomain(forName: "favourite-tests")
        return defaults
    }()

    @Test func toggleAddsInOrderAndRemoves() {
        let favourites = FavouriteSessions(defaults: defaults)
        favourites.toggle("chair.gentle")
        favourites.toggle("walk.long")
        #expect(favourites.ids == ["chair.gentle", "walk.long"])
        #expect(favourites.contains("walk.long"))
        favourites.toggle("chair.gentle")
        #expect(favourites.ids == ["walk.long"])
        #expect(!favourites.contains("chair.gentle"))
    }

    @Test func survivesRelaunchAndDropsUnknownIDs() {
        defaults.set(["walk.long", "retired.session", "stretch.seated.gentle"], forKey: FavouriteSessions.defaultsKey)
        let favourites = FavouriteSessions(defaults: defaults)
        #expect(favourites.ids == ["walk.long", "stretch.seated.gentle"])
        favourites.toggle("extra.balance")
        #expect(FavouriteSessions(defaults: defaults).ids == ["walk.long", "stretch.seated.gentle", "extra.balance"])
    }

    @Test func deleteAllMyDataForgetsFavourites() {
        #expect(AppDefaultsKeys.all.contains(FavouriteSessions.defaultsKey))
    }
}
