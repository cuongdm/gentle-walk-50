import SwiftUI
import UIKit

/// Colour roles from the screen spec (docs/design/gentle-walk-screen-spec.html, "Design tokens").
///
/// Each role lives in `Assets.xcassets` with a dark variant. The "Pigment" palette (owner 03/10/2026)
/// takes its hues from the app's own watercolours instead of the stock sage-cream-terracotta set:
/// paper, umber ink, Hooker's green, sap green, ochre, sienna and a sky wash. Every pair below
/// reaches 4.5:1 in light and dark (DesignTokenTests).
enum Palette {
    /// App background.
    static let bg = Color(Name.bg)
    /// Cards.
    static let surface = Color(Name.surface)
    /// The one main button per screen; white text. Hooker's green, deep like ink (Pigment, 03/10/2026):
    /// green reads as "go" next to the red This hurts button and stands out on paper for older eyes.
    static let primary = Color(Name.primary)
    /// Soft depth on the main button (Claude Design direction, owner 08/10/2026, lightened the same day:
    /// the deep Hooker green read too heavy): a vertical gradient `primaryTop` → `primaryMid` (55 %) →
    /// `primaryBottom`; pressed, `primaryBottom` → `primaryPressed`. White text on every stop (≥ 4.5:1).
    static let primaryTop = Color(Name.primaryTop)
    static let primaryMid = Color(Name.primaryMid)
    static let primaryBottom = Color(Name.primaryBottom)
    static let primaryPressed = Color(Name.primaryPressed)
    /// Card paper: a faint gradient from `surfaceTop` to `surfaceBottom` around `surface`.
    static let surfaceTop = Color(Name.surfaceTop)
    static let surfaceBottom = Color(Name.surfaceBottom)
    /// Warm umber for soft shadows under cards (black in dark mode). Never used for text.
    static let shadow = Color(Name.shadow)
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
    /// The stroke of every content icon (`AppIcon`) on its watercolour wash: deep green on paper, cream in
    /// dark mode (Claude Design, owner 08/10/2026). Never sky or sun as a line colour (`nguon-icon.md` §4).
    static let iconInk = Color(Name.iconInk)
    /// Small live-status dots ("Tracking your walk", "Counted for you"): sap green on paper, a lighter
    /// sap green in dark mode, where the deep one vanished on the dark pill and screen (review C, 09/10/2026).
    static let statusDot = Color(Name.statusDot)

    /// Asset catalog names, one per colour set.
    enum Name {
        static let bg = "bg"
        static let surface = "surface"
        static let primary = "primary"
        static let primaryTop = "primaryTop"
        static let primaryMid = "primaryMid"
        static let primaryPressed = "primaryPressed"
        static let primaryBottom = "primaryBottom"
        static let surfaceTop = "surfaceTop"
        static let surfaceBottom = "surfaceBottom"
        static let shadow = "shadow"
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
        static let iconInk = "iconInk"
        static let statusDot = "statusDot"
    }

    static let assetNames = [
        Name.bg, Name.surface, Name.primary, Name.accent, Name.secondary, Name.sky, Name.sun,
        Name.text, Name.textMuted, Name.dangerSoft, Name.onStrongFill, Name.onLightFill, Name.artPaper,
        Name.primaryTop, Name.primaryMid, Name.primaryBottom, Name.primaryPressed, Name.surfaceTop, Name.surfaceBottom, Name.shadow,
        Name.iconInk, Name.statusDot,
    ]

    /// A text colour drawn on a fill colour somewhere in the app.
    struct TextPair: Sendable {
        /// Small text (chip labels, the tab word) keeps a margin over 4.5:1 (plan 08/10/2026 task 1.2).
        static let smallText = 5.0
        /// Icons and other graphics need 3:1 (WCAG 1.4.11).
        static let graphic = 3.0

        let name: String
        let foreground: String
        let background: String
        var minimum = 4.5
        /// The background is a watercolour wash: `background` at this opacity over the card (`surface`).
        var wash: Double? = nil
    }

    /// Every text-on-fill pairing the screens use; each must reach its minimum (4.5:1, small text 5:1)
    /// in light and dark.
    static let textPairs = [
        TextPair(name: "text on bg", foreground: Name.text, background: Name.bg),
        TextPair(name: "text on surface", foreground: Name.text, background: Name.surface),
        TextPair(name: "textMuted on bg", foreground: Name.textMuted, background: Name.bg),
        TextPair(name: "textMuted on surface", foreground: Name.textMuted, background: Name.surface),
        TextPair(name: "button on primary", foreground: Name.onStrongFill, background: Name.primary),
        TextPair(name: "button on primary gradient top", foreground: Name.onStrongFill, background: Name.primaryTop),
        TextPair(name: "button on primary gradient middle", foreground: Name.onStrongFill, background: Name.primaryMid),
        TextPair(name: "button on primary gradient bottom", foreground: Name.onStrongFill, background: Name.primaryBottom),
        TextPair(name: "button on primary pressed", foreground: Name.onStrongFill, background: Name.primaryPressed),
        TextPair(name: "text on card paper top", foreground: Name.text, background: Name.surfaceTop),
        TextPair(name: "text on card paper bottom", foreground: Name.text, background: Name.surfaceBottom),
        TextPair(name: "textMuted on card paper top", foreground: Name.textMuted, background: Name.surfaceTop),
        TextPair(name: "textMuted on card paper bottom", foreground: Name.textMuted, background: Name.surfaceBottom),
        TextPair(name: "selected tab on bg", foreground: Name.accent, background: Name.bg, minimum: TextPair.smallText),
        TextPair(name: "ink on art paper", foreground: Name.onLightFill, background: Name.artPaper),
        TextPair(name: "label on secondary", foreground: Name.onStrongFill, background: Name.secondary, minimum: TextPair.smallText),
        TextPair(name: "button on dangerSoft", foreground: Name.onStrongFill, background: Name.dangerSoft),
        TextPair(name: "label on sky", foreground: Name.onLightFill, background: Name.sky),
        TextPair(name: "label on sun", foreground: Name.onLightFill, background: Name.sun),
        // Icon chips (`AppIconChip`): the glyph on its tint's wash at the wash's deepest point (40 %).
        TextPair(name: "icon ink on surface", foreground: Name.iconInk, background: Name.surface, minimum: TextPair.graphic),
        TextPair(name: "icon ink on sap wash", foreground: Name.iconInk, background: Name.secondary, minimum: TextPair.graphic, wash: 0.4),
        TextPair(name: "icon ink on sky wash", foreground: Name.iconInk, background: Name.sky, minimum: TextPair.graphic, wash: 0.4),
        TextPair(name: "icon ink on ochre wash", foreground: Name.iconInk, background: Name.sun, minimum: TextPair.graphic, wash: 0.4),
        TextPair(name: "icon ink on sienna wash", foreground: Name.iconInk, background: Name.accent, minimum: TextPair.graphic, wash: 0.4),
        TextPair(name: "icon ink on danger wash", foreground: Name.iconInk, background: Name.dangerSoft, minimum: TextPair.graphic, wash: 0.4),
        // Status dots: graphics, 3:1 on the screen and on the badge's card.
        TextPair(name: "status dot on bg", foreground: Name.statusDot, background: Name.bg, minimum: TextPair.graphic),
        TextPair(name: "status dot on surface", foreground: Name.statusDot, background: Name.surface, minimum: TextPair.graphic),
    ]
}

/// Layout numbers from the screen spec (buttons, touch targets, margins, cards).
enum Metrics {
    static let screenMargin: CGFloat = 20
    /// Widest column of text and buttons on iPad (review U1): about 60 characters of 19 pt body
    /// (plan 08/10/2026).
    static let readableWidth: CGFloat = 620
    /// Main buttons: 64 pt, about 10 mm on an iPhone (font-va-hinh-anh.md §5).
    static let buttonHeight: CGFloat = 64
    /// Tappable rows and choice cards (plan 08/10/2026 task 1.3).
    static let rowHeight: CGFloat = 64
    /// 14 and 16 (Pigment, 03/10/2026): calmer corners than the stock 18–28.
    static let buttonRadius: CGFloat = 14
    static let secondaryBorder: CGFloat = 2
    static let cardRadius: CGFloat = 16
    static let minTouchTarget: CGFloat = 56
    static let touchSpacing: CGFloat = 12
}

/// WCAG 2.x contrast ratio between two colour sets, resolved for an appearance.
enum ContrastRatio {
    enum Failure: Error { case missingColour(String) }

    /// The ratio of a pair as drawn: a wash pair blends its fill over the card first.
    static func ratio(of pair: Palette.TextPair, style: UIUserInterfaceStyle) throws -> Double {
        guard let wash = pair.wash else { return try between(pair.foreground, pair.background, style: style) }
        let traits = UITraitCollection(userInterfaceStyle: style)
        func colour(_ name: String) throws -> UIColor {
            guard let value = UIColor(named: name, in: .main, compatibleWith: traits)?.resolvedColor(with: traits) else {
                throw Failure.missingColour(name)
            }
            return value
        }
        let fg = try colour(pair.foreground), tint = try colour(pair.background), paper = try colour(Palette.Name.surface)
        var (tr, tg, tb, ta): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (pr, pg, pb, pa): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        tint.getRed(&tr, green: &tg, blue: &tb, alpha: &ta)
        paper.getRed(&pr, green: &pg, blue: &pb, alpha: &pa)
        let a = CGFloat(wash)
        let bg = UIColor(red: tr * a + pr * (1 - a), green: tg * a + pg * (1 - a), blue: tb * a + pb * (1 - a), alpha: 1)
        let (high, low) = (max(luminance(fg), luminance(bg)), min(luminance(fg), luminance(bg)))
        return (high + 0.05) / (low + 0.05)
    }

    static func between(_ foreground: String, _ background: String, style: UIUserInterfaceStyle) throws -> Double {
        let traits = UITraitCollection(userInterfaceStyle: style)
        // `resolvedColor(with:)`: a named colour is dynamic, and reading its components without
        // resolving gives the light value even for dark (found 08/10/2026: dark was never checked).
        guard let fg = UIColor(named: foreground, in: .main, compatibleWith: traits)?.resolvedColor(with: traits) else {
            throw Failure.missingColour(foreground)
        }
        guard let bg = UIColor(named: background, in: .main, compatibleWith: traits)?.resolvedColor(with: traits) else {
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
