import Testing
import UIKit
import GentleWalkCore
@testable import GentleWalk

/// Painted art (tools/art/build_art.py → Assets.xcassets/Art) is in the app for every name the
/// screens ask for; postcards may still fall back to their journey cover.
@Suite struct ArtCatalogTests {
    @Test(arguments: Art.allCases)
    func everyNamedPaintingIsBundled(_ art: Art) {
        #expect(UIImage(named: art.rawValue) != nil, "missing art \(art.rawValue)")
    }

    @Test func everyJourneyHasACover() throws {
        let bundle = try ContentStore.load(bundle: .main)
        for journey in bundle.journeys {
            let name = Art.coverName(journeyID: journey.id)
            #expect(UIImage(named: name) != nil, "missing cover \(name)")
        }
    }

    @Test(arguments: TreeLevel.allCases)
    func everyTreeLevelIsPainted(_ level: TreeLevel) {
        #expect(UIImage(named: Art.treeName(level: level)) != nil, "missing \(Art.treeName(level: level))")
    }

    @Test func postcardNamesFallBackToTheirJourneyCover() {
        #expect(Art.postcardName(stopID: "pc.ny.zoo") == "postcard-pc-ny-zoo")
        #expect(Art.coverName(stopID: "pc.ny.zoo") == "cover-jr-ny")
        #expect(Art.coverName(stopID: "pc.camino.3") == "cover-jr-camino")
    }
}
