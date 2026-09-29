import SwiftUI

extension View {
    /// Card from the spec: surface fill, radius 20, no heavy shadow.
    func cardStyle(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Palette.surface, in: .rect(cornerRadius: Metrics.cardRadius, style: .continuous))
    }

    /// Standard screen body: bg colour, 20 pt side margins.
    func screenBackground() -> some View {
        self.background(Palette.bg.ignoresSafeArea())
    }
}
