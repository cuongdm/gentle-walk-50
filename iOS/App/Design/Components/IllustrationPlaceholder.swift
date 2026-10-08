import SwiftUI

/// Stand-in for a watercolour illustration until the art arrives (spec "Minh hoạ"): a soft tinted
/// panel with one symbol. Decorative, hidden from VoiceOver.
struct IllustrationPlaceholder: View {
    let symbol: String
    var tint: Color = Palette.secondary
    var height: CGFloat = 160

    @ScaledMetric(relativeTo: .largeTitle) private var symbolSize: CGFloat = 56

    var body: some View {
        RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
            .fill(LinearGradient(colors: [tint.opacity(0.28), tint.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay {
                Image(systemName: symbol)
                    // Grows with the text, but never past the panel (the 64 pt cancel-guide hand covered
                    // the step's words at the largest sizes).
                    .font(.system(size: min(symbolSize, height * 0.6), weight: .regular, design: .rounded))
                    .foregroundStyle(tint)
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .clipped()
            .accessibilityHidden(true)
    }
}
