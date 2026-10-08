import Testing
import UIKit
@testable import GentleWalk

/// Every colour role resolves from the asset catalog in light and dark, and every text/fill pair
/// the app uses reaches WCAG 4.5:1 (screen spec, "Design tokens").
@Suite struct DesignTokenTests {
    @Test(arguments: Palette.assetNames)
    func colourAssetExists(_ name: String) {
        #expect(UIColor(named: name, in: .main, compatibleWith: nil) != nil, "missing colour set \(name)")
    }

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func textPairsReachFourPointFive(_ style: UIUserInterfaceStyle) throws {
        for pair in Palette.textPairs {
            let ratio = try ContrastRatio.between(pair.foreground, pair.background, style: style)
            #expect(ratio >= pair.minimum, "\(pair.name) in \(style == .dark ? "dark" : "light"): \(ratio)")
        }
    }

    /// Small text on a fill (chip labels on `secondary`, the selected tab word) keeps a margin over
    /// 4.5:1 (plan 08/10/2026 task 1.2).
    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func smallTextPairsReachFive(_ style: UIUserInterfaceStyle) throws {
        let small = Palette.textPairs.filter { $0.minimum >= Palette.TextPair.smallText }
        #expect(Set(small.map(\.name)).isSuperset(of: ["label on secondary", "selected tab on bg"]))
        for pair in small {
            let ratio = try ContrastRatio.between(pair.foreground, pair.background, style: style)
            #expect(ratio >= 5.0, "\(pair.name) in \(style == .dark ? "dark" : "light"): \(ratio)")
        }
    }

    @Test func buttonHeightIsSixtyFour() {
        #expect(Metrics.buttonHeight == 64)
        #expect(Metrics.rowHeight == 64)
        #expect(Metrics.minTouchTarget == 56)
        #expect(Metrics.readableWidth == 620)
    }
}
