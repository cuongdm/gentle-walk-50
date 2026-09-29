import SwiftUI

/// An SF Symbol in a soft tinted circle: the leading icon of list rows and benefit lines.
struct IconChip: View {
    let symbol: String
    var tint: Color = Palette.secondary
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 44

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.14), in: .circle)
            .accessibilityHidden(true)
    }
}
