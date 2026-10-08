import SwiftUI

extension View {
    /// Card from the spec: paper fill (`CardPaper`), radius 16, light shadows only.
    func cardStyle(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { CardPaper() }
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
    /// The band reads the top inset itself: a tab's scroll view reaches up under the status bar, where
    /// a zero-height band that grows into the safe area stayed at zero (Progress scrolled, 08/10/2026).
    func screenBackground() -> some View {
        self.background(Palette.bg.ignoresSafeArea())
            .overlay(alignment: .top) { StatusBarBand() }
    }
}

/// The background colour behind the status bar, over the content that scrolls under it. The reader sits
/// just below the status bar and reports its height as the top inset; the band is drawn above itself.
private struct StatusBarBand: View {
    var body: some View {
        GeometryReader { proxy in
            Palette.bg
                .frame(maxWidth: .infinity)
                .frame(height: proxy.safeAreaInsets.top)
                .offset(y: -proxy.safeAreaInsets.top)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// Card paper (Claude Design direction, owner 08/10/2026): a faint top-to-bottom paper gradient and
/// two light shadows, so cards sit on the page without looking raised.
struct CardPaper: View {
    private static let shape = RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
    private static let paper = LinearGradient(colors: [Palette.surfaceTop, Palette.surfaceBottom],
                                              startPoint: .top, endPoint: .bottom)

    var body: some View {
        Self.shape.fill(Self.paper)
            .shadow(color: Palette.shadow.opacity(0.05), radius: 1, y: 1)
            .shadow(color: Palette.shadow.opacity(0.07), radius: 10, y: 4)
    }
}
