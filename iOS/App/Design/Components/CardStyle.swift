import SwiftUI

extension View {
    /// Card from the spec: surface fill, radius 20, no heavy shadow.
    func cardStyle(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.surface, in: .rect(cornerRadius: Metrics.cardRadius, style: .continuous))
    }

    /// iPad and landscape: content in a centred column no wider than a comfortable reading line
    /// (review U1, 30/09/2026); on phones it changes nothing.
    func readableColumn(_ width: CGFloat = Metrics.readableWidth) -> some View {
        frame(maxWidth: width).frame(maxWidth: .infinity)
    }

    /// A fixed screen that scrolls only when its content does not fit (large text, small phones),
    /// so nothing is cut off with "…" (review U2).
    func scrollsWhenCrowded() -> some View {
        ViewThatFits(in: .vertical) {
            self
            ScrollView { self }.scrollBounceBehavior(.basedOnSize)
        }
    }

    /// Standard screen body: bg colour, 20 pt side margins. The status bar keeps a band of the
    /// background colour, so text scrolling up never runs under the clock (real iPhone, 30/09/2026).
    func screenBackground() -> some View {
        self.background(Palette.bg.ignoresSafeArea())
            .overlay(alignment: .top) {
                Palette.bg.frame(height: 0).ignoresSafeArea(edges: .top).allowsHitTesting(false)
            }
    }
}
