import Foundation

/// The app's public name, in one place (owner 07/10/2026: "Good Footing", slogan below).
/// User-facing strings interpolate it ("\(AppBrand.name) Pro"), so the catalog keys read "%@ Pro"
/// and a later rename changes this file only, with no new translations. The name is a proper noun:
/// never translated. Bundle ID, product IDs, target and type names stay "GentleWalk" (they can't
/// change after App Store Connect, see docs/design/doi-ten-app-checklist.md §7).
enum AppBrand {
    /// Home-screen name, Settings, paywall, share card, Now Playing. Keep ≤ 12 characters
    /// (matches `CFBundleDisplayName` in project.yml and InfoPlist.xcstrings).
    static let name = "Good Footing"
}
