import SwiftUI

/// Type roles from the screen spec: no Light weight, body 19 pt (never under 17), caption 16.
/// Font A1 (owner 08/10/2026, docs/design/research-2026-10-08/font-va-hinh-anh.md §3a): screen titles in
/// New York, the system serif, so headings read like a notebook; text, buttons and captions in SF Pro
/// (sharper than Rounded at small sizes, optical sizes built in); SF Pro Rounded only for numbers.
///
/// Each role is anchored to a system text style, so it scales with Dynamic Type exactly like that
/// style; the spec size is the value at the default content size.
enum TypeRole: CaseIterable {
    /// Screen title: 30 pt bold, at most two lines.
    case screenTitle
    /// Card title: 22 pt semibold.
    case cardTitle
    /// Body: 19 pt.
    case body
    /// Button label: 20 pt semibold.
    case button
    /// Caption: 16 pt, secondary information only, never instructions.
    case caption
    /// Player phase label: 34 pt bold, uppercase with tracking (e.g. BRISK WALK).
    case phaseLabel
    /// Player clock and counters: 80 pt medium, tabular figures.
    case timer
    /// Phase change card: the new phase name, 52 pt bold.
    case transition
    /// Big numbers on Complete and counters: 40 pt bold.
    case stat
    /// Player clock on iPad and in landscape, where it takes half the screen: 160 pt.
    case wallClock

    var size: CGFloat {
        switch self {
        case .screenTitle: 30
        case .cardTitle: 22
        case .body: 19
        case .button: 20
        case .caption: 16
        case .phaseLabel: 34
        case .timer: 80
        case .transition: 52
        case .stat: 40
        case .wallClock: 160
        }
    }

    var weight: Font.Weight {
        switch self {
        case .screenTitle: .semibold
        case .phaseLabel, .transition, .stat: .bold
        case .cardTitle, .button: .semibold
        // Medium, not regular: big thin figures glare on dark and sand (decision D17).
        case .timer, .wallClock: .medium
        case .body, .caption: .regular
        }
    }

    /// New York for screen titles, SF Pro Rounded for numbers, SF Pro for everything else.
    var design: Font.Design {
        switch self {
        case .screenTitle: .serif
        case .phaseLabel, .timer, .transition, .stat, .wallClock: .rounded
        case .cardTitle, .body, .button, .caption: .default
        }
    }

    /// Extra space between lines: Vietnamese stacked marks need it in body text and titles.
    var lineSpacing: CGFloat {
        switch self {
        case .body, .screenTitle: 2
        default: 0
        }
    }

    /// The system text style this role scales with.

    var anchor: Font.TextStyle {
        switch self {
        case .screenTitle: .title
        case .cardTitle: .title2
        case .body, .button: .body
        case .caption: .callout
        case .phaseLabel, .timer, .transition, .stat, .wallClock: .largeTitle
        }
    }
}

/// Applies a `TypeRole` with Dynamic Type scaling.
private struct TypeRoleModifier: ViewModifier {
    let role: TypeRole
    @ScaledMetric private var size: CGFloat

    init(role: TypeRole) {
        self.role = role
        _size = ScaledMetric(wrappedValue: role.size, relativeTo: role.anchor)
    }

    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: role.weight, design: role.design))
            .monospacedDigit()
            .tracking(role == .phaseLabel || role == .transition ? 1.5 : 0)
            .lineSpacing(role.lineSpacing)
    }
}

extension View {
    /// Sets the font for a spec type role, scaled with Dynamic Type.
    func typeRole(_ role: TypeRole) -> some View {
        modifier(TypeRoleModifier(role: role))
    }
}
