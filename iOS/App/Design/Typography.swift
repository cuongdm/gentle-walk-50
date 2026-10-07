import SwiftUI

/// Type roles from the screen spec: SF Pro Rounded, no Light weight, body 19 pt (never under 17).
/// Screen titles are set in New York, the system serif (owner 03/10/2026: "A + the titles of B"), so
/// headings read like a notebook rather than a stock app; everything else stays rounded.
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
    /// Caption: 15 pt, secondary information only.
    case caption
    /// Player phase label: 34 pt bold, uppercase with tracking (e.g. BRISK WALK).
    case phaseLabel
    /// Player clock and counters: 80 pt, tabular figures.
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
        case .caption: 15
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
        case .body, .caption, .timer, .wallClock: .regular
        }
    }

    /// The system text style this role scales with.
    /// New York for screen titles, SF Pro Rounded for the rest.
    var design: Font.Design { self == .screenTitle ? .serif : .rounded }

    var anchor: Font.TextStyle {
        switch self {
        case .screenTitle: .title
        case .cardTitle: .title2
        case .body, .button: .body
        case .caption: .subheadline
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
    }
}

extension View {
    /// Sets the font for a spec type role, scaled with Dynamic Type.
    func typeRole(_ role: TypeRole) -> some View {
        modifier(TypeRoleModifier(role: role))
    }
}
