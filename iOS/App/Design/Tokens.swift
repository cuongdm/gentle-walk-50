import SwiftUI
import UIKit

/// Colour roles from the screen spec (docs/design/gentle-walk-screen-spec.html, "Design tokens").
///
/// Each role lives in `Assets.xcassets` with a dark variant. Light shades of primary, secondary and
/// dangerSoft are darkened slightly from the spec hex (7.5 %, 10 %, 4.5 %) so white text reaches
/// 4.5:1, as the spec allows ("keep each colour's role and reach 4.5:1"). Dark variants are the light
/// shade dimmed 10 %.
enum Palette {
    /// App background.
    static let bg = Color(Name.bg)
    /// Cards.
    static let surface = Color(Name.surface)
    /// The one main button per screen; white text. Deep sage (decided 29/09/2026): green reads as
    /// "go" next to the red This hurts button, and the dark shade stands out on cream for older eyes.
    static let primary = Color(Name.primary)
    /// Small warm accent (the old terracotta): selected tab. Used as text, never as a fill under text.
    static let accent = Color(Name.accent)
    /// Progress, journey, "done".
    static let secondary = Color(Name.secondary)
    /// Easy phase, Break button, Achy check-in.
    static let sky = Color(Name.sky)
    /// Brisk phase, milestones.
    static let sun = Color(Name.sun)
    /// Main text.
    static let text = Color(Name.text)
    /// Secondary information only, never instructions.
    static let textMuted = Color(Name.textMuted)
    /// Only the This hurts button and deleting data.
    static let dangerSoft = Color(Name.dangerSoft)
    /// Text on primary, secondary and dangerSoft fills.
    static let onStrongFill = Color(Name.onStrongFill)
    /// Text on sky and sun fills: dark ink in both appearances, since those fills stay light.
    static let onLightFill = Color(Name.onLightFill)
    /// Paper behind the painted figures (Assets.xcassets/Art). Same in dark mode: the art is a
    /// painting on paper, shown as a card. No text is ever drawn on it.
    static let artPaper = Color(Name.artPaper)

    /// Asset catalog names, one per colour set.
    enum Name {
        static let bg = "bg"
        static let surface = "surface"
        static let primary = "primary"
        static let accent = "accent"
        static let secondary = "secondary"
        static let sky = "sky"
        static let sun = "sun"
        static let text = "text"
        static let textMuted = "textMuted"
        static let dangerSoft = "dangerSoft"
        static let onStrongFill = "onStrongFill"
        static let onLightFill = "onLightFill"
        static let artPaper = "artPaper"
    }

    static let assetNames = [
        Name.bg, Name.surface, Name.primary, Name.accent, Name.secondary, Name.sky, Name.sun,
        Name.text, Name.textMuted, Name.dangerSoft, Name.onStrongFill, Name.onLightFill, Name.artPaper,
    ]

    /// A text colour drawn on a fill colour somewhere in the app.
    struct TextPair: Sendable {
        let name: String
        let foreground: String
        let background: String
    }

    /// Every text-on-fill pairing the screens use; each must reach 4.5:1 in light and dark.
    static let textPairs = [
        TextPair(name: "text on bg", foreground: Name.text, background: Name.bg),
        TextPair(name: "text on surface", foreground: Name.text, background: Name.surface),
        TextPair(name: "textMuted on bg", foreground: Name.textMuted, background: Name.bg),
        TextPair(name: "textMuted on surface", foreground: Name.textMuted, background: Name.surface),
        TextPair(name: "button on primary", foreground: Name.onStrongFill, background: Name.primary),
        TextPair(name: "selected tab on bg", foreground: Name.accent, background: Name.bg),
        TextPair(name: "ink on art paper", foreground: Name.onLightFill, background: Name.artPaper),
        TextPair(name: "label on secondary", foreground: Name.onStrongFill, background: Name.secondary),
        TextPair(name: "button on dangerSoft", foreground: Name.onStrongFill, background: Name.dangerSoft),
        TextPair(name: "label on sky", foreground: Name.onLightFill, background: Name.sky),
        TextPair(name: "label on sun", foreground: Name.onLightFill, background: Name.sun),
    ]
}

/// Layout numbers from the screen spec (buttons, touch targets, margins, cards).
enum Metrics {
    static let screenMargin: CGFloat = 20
    static let buttonHeight: CGFloat = 60
    static let buttonRadius: CGFloat = 18
    static let secondaryBorder: CGFloat = 2
    static let cardRadius: CGFloat = 20
    static let minTouchTarget: CGFloat = 56
    static let touchSpacing: CGFloat = 12
}

/// WCAG 2.x contrast ratio between two colour sets, resolved for an appearance.
enum ContrastRatio {
    enum Failure: Error { case missingColour(String) }

    static func between(_ foreground: String, _ background: String, style: UIUserInterfaceStyle) throws -> Double {
        let traits = UITraitCollection(userInterfaceStyle: style)
        guard let fg = UIColor(named: foreground, in: .main, compatibleWith: traits) else {
            throw Failure.missingColour(foreground)
        }
        guard let bg = UIColor(named: background, in: .main, compatibleWith: traits) else {
            throw Failure.missingColour(background)
        }
        let (high, low) = (max(luminance(fg), luminance(bg)), min(luminance(fg), luminance(bg)))
        return (high + 0.05) / (low + 0.05)
    }

    /// Relative luminance of an sRGB colour.
    static func luminance(_ colour: UIColor) -> Double {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        colour.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        func linear(_ value: CGFloat) -> Double {
            let v = Double(value)
            return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(red) + 0.7152 * linear(green) + 0.0722 * linear(blue)
    }
}
