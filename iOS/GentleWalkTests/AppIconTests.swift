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

/// Milestone 3 (plan 08/10/2026 tasks 3.2, 3.4, 3.5, 3.8): the app's concepts map to one icon each, and the
/// screens moved to `AppIcon` keep no SF Symbol that a concept replaces (only ›, ✓, ✕, +, −, ‹, ▶ stay).
@Suite struct AppIconConceptTests {
    @Test func meRowsHaveOneIconEach() {
        // The goal row shows her goal's own icon; every other row has its own picture.
        let rows = MeRow.allCases.filter { $0 != .goal }
        let icons = rows.map(\.icon)
        #expect(Set(icons).count == icons.count, "two Me rows share an icon: \(rows.map { "\($0): \($0.icon)" })")
    }

    @Test func momentsHaveOneIconEach() {
        let icons = DailyMoment.allCases.map(AppIcon.moment)
        #expect(Set(icons).count == DailyMoment.allCases.count)
        #expect(AppIcon.moment(.coffee) == .coffee)
        #expect(AppIcon.moment(.custom) == .time)
    }

    @Test func sessionKindsHaveTheirOwnIcon() {
        #expect(AppIcon.session(.walk, seated: false) == .walk)
        #expect(AppIcon.session(.walk, seated: true) == .seated)
        #expect(AppIcon.session(.longWalk, seated: false) == .longWalk)
        #expect(AppIcon.session(.chair, seated: false) == .chair)
        #expect(AppIcon.session(.stretch, seated: false) == .stretch)
        // The 2-week check is a stopwatch, never the chair of chair moves (icon doc §2, T2).
        #expect(AppIcon.selfCheck != AppIcon.session(.chair, seated: false))
    }

    @Test func specialCardsSayWhatTheyAreAbout() {
        #expect(AppIcon.special(.pain(area: .knees)) == .hurts)
        #expect(AppIcon.special(.movedUp(to: .inPlace)) == .levelUp)
        #expect(AppIcon.special(.movedDown(to: .seated)) == .levelDown)
        #expect(AppIcon.special(.connectHealth) == .health)
        #expect(AppIcon.special(.moveReminder(minutes: 540)) == .reminder)
        #expect(AppIcon.special(.longerWalk) == .longWalk)
    }

    /// The icon licence ships in the app and Me → Help → Acknowledgements reads it (MIT: the notice must
    /// travel with the icons).
    @Test func acknowledgementsShowThePhosphorLicence() {
        let text = AcknowledgementsView.licenceText()
        #expect(text?.contains("MIT License") == true)
        #expect(text?.contains("Phosphor Icons") == true)
        // Paragraphs flow on a phone: no hard 80-column breaks left inside a paragraph.
        #expect(text?.contains("to deal in the Software") == true)
    }

    /// Screens of milestone 3 (not Complete and Progress: tasks 3.6 and 3.7 have their own pass).
    static let migratedFiles = [
        "Features/Today/TodayCards.swift", "Features/Today/TodayView.swift",
        "Features/Me/MeView.swift", "Features/Me/MeSections.swift", "Features/Me/MeRows.swift",
        "Features/Me/NotificationSection.swift", "Features/Me/GoalSection.swift",
        "Features/Permissions/PermissionStepView.swift", "Features/Outdoor/OutdoorPrepView.swift",
        "Features/SelfCheck/SelfCheckViews.swift", "Features/Shared/DailyMomentPicker.swift",
        "Features/Program/ProgramView.swift",
    ]

    @Test(arguments: migratedFiles)
    func migratedScreensUseNoReplacedSymbols(_ file: String) throws {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let manifest = try JSONSerialization.jsonObject(
            with: Data(contentsOf: root.deletingLastPathComponent().appending(path: "tools/art/icons-manifest.json")))
        let icons = try #require((manifest as? [String: Any])?["icons"] as? [[String: Any]])
        // A tick stays a system control (✓ for done, connected, chosen) even where a concept once took it over.
        let systemControls = ["chevron", "checkmark", "xmark", "plus", "minus", "play", "pause"]
        let replaced = Set(icons.compactMap { $0["replaces"] as? String }
            .filter { symbol in !symbol.isEmpty && !systemControls.contains { symbol.hasPrefix($0) } })
        let source = try String(contentsOf: root.appending(path: "App/\(file)"), encoding: .utf8)
        // Every string literal that names a replaced SF Symbol, except an art fallback (shown only if a
        // painting were missing, which ArtCatalogTests rules out).
        let literal = /(fallbackSymbol:\s*)?"([a-z0-9.]+)"/
        let found = source.matches(of: literal).filter { $0.output.1 == nil && replaced.contains(String($0.output.2)) }
            .map { String($0.output.2) }
        #expect(found.isEmpty, "\(file) still uses SF Symbols replaced by AppIcon: \(found)")
    }
}
