import SwiftUI

/// Keeps a screen's main buttons in view at the bottom, over a soft edge, so a long screen never
/// hides Start or Continue. At accessibility text sizes the caller shows them inline instead (a
/// pinned bar would eat the screen), passing `pinned: false`.
struct PinnedActions<Actions: View>: ViewModifier {
    let pinned: Bool
    @ViewBuilder let actions: () -> Actions

    func body(content: Content) -> some View {
        content.safeAreaInset(edge: .bottom) {
            if pinned {
                VStack(spacing: 10) { actions() }
                    .padding(.horizontal, Metrics.screenMargin)
                    .padding(.top, 10)
                    .padding(.bottom, 6)
                    .frame(maxWidth: 640)
                    .frame(maxWidth: .infinity)
                    .background { PinnedBarBackground() }
            }
        }
    }
}

extension View {
    func pinnedActions<Actions: View>(_ pinned: Bool, @ViewBuilder _ actions: @escaping () -> Actions) -> some View {
        modifier(PinnedActions(pinned: pinned, actions: actions))
    }
}

/// The pinned bar's fill: the page colour (with the screen's own wash, if any) over a soft top shadow,
/// so words scrolling under the buttons never show through.
struct PinnedBarBackground: View {
    var wash: Color = .clear

    var body: some View {
        ZStack {
            Rectangle().fill(Palette.bg.shadow(.drop(color: .black.opacity(0.08), radius: 8, y: -2)))
            wash
        }
        .ignoresSafeArea()
    }
}
