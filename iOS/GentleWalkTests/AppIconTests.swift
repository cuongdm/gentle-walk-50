import SwiftUI
import Testing
import UIKit
@testable import GentleWalk

/// Every content icon ships in the asset catalog as a template (Bold + Fill twin), and no glyph carries
/// two meanings (`AppIcon`, built by `tools/art/build_icons.py`).
@Suite struct AppIconTests {
    @Test(arguments: AppIcon.allCases)
    func normalAndSelectedAssetsExist(_ icon: AppIcon) {
        #expect(UIImage(named: icon.assetName, in: .main, compatibleWith: nil) != nil,
                "missing image set \(icon.assetName)")
        #expect(UIImage(named: icon.selectedAssetName, in: .main, compatibleWith: nil) != nil,
                "missing image set \(icon.selectedAssetName)")
    }

    @Test(arguments: AppIcon.allCases)
    func assetsRenderAsTemplates(_ icon: AppIcon) throws {
        for name in [icon.assetName, icon.selectedAssetName] {
            let image = try #require(UIImage(named: name, in: .main, compatibleWith: nil))
            #expect(image.renderingMode == .alwaysTemplate, "\(name) is not a template image")
        }
    }

    /// Two-tone icons ship both layers (base + its selected Fill twin, mark) as templates; one-colour
    /// icons have no layers.
    @Test(arguments: AppIcon.allCases)
    func layersExistForTwoToneIcons(_ icon: AppIcon) throws {
        guard icon.isLayered else {
            #expect(icon.layerAssetName(.base) == nil && icon.layerAssetName(.mark) == nil)
            return
        }
        let names = [icon.layerAssetName(.base), icon.layerAssetName(.base, selected: true), icon.layerAssetName(.mark)]
        for name in names {
            let name = try #require(name)
            let image = try #require(UIImage(named: name, in: .main, compatibleWith: nil), "missing layer \(name)")
            #expect(image.renderingMode == .alwaysTemplate, "\(name) is not a template image")
        }
    }

    @Test func bodyAndLimitIconsAreTwoTone() {
        let twoTone: [AppIcon] = [.bodyKnees, .bodyHips, .bodyLowerBack, .bodyShoulders, .bodyJointReplacement,
                                  .limitFloor, .limitStandingLong, .limitDizzy, .limitUnsteady, .limitNoJumping]
        let layered = AppIcon.allCases.filter { $0.isLayered }
        #expect(Set(layered) == Set(twoTone))
    }

    /// One symbol, one meaning: two cases may share a glyph only when `sharedGlyphs` lists them.
    @Test func noGlyphCarriesTwoMeanings() {
        let owners = Dictionary(grouping: AppIcon.allCases, by: \.glyph)
        for (glyph, icons) in owners where icons.count > 1 {
            #expect(AppIcon.sharedGlyphs[glyph] == Set(icons),
                    "\(glyph) is used by \(icons.map(\.rawValue)); give each meaning its own glyph")
        }
    }

    @Test func selectedAssetIsTheFillTwin() {
        for icon in AppIcon.allCases {
            #expect(icon.selectedAssetName == icon.assetName + "-fill")
            #expect(icon.assetName.hasPrefix("\(AppIcon.folder)/"))
        }
    }
}
