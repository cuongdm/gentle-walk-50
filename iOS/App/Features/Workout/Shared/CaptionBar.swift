import SwiftUI

/// Caption strip (task 3.11): the exact spoken line on a dark translucent band, body size, up to
/// three lines. Input is only the text, so the bar redraws only when the line changes. Hidden when
/// Captions is off in Me (review I8).
/// `.plain` (30/09/2026): the line in the text colour with no band, for the walk player and the
/// full-screen panel, where a dark block would outweigh the clock.
struct CaptionBar: View {
    enum Style: Equatable {
        case band
        case plain(HorizontalAlignment)
        /// The chair player: the line the coach is saying at 22 pt in a speech bubble, like the coach's
        /// replies in onboarding (plan 08/10/2026 task 1.14).
        case bubble
    }

    let caption: String?
    var style: Style = .band
    @AppStorage("captionsOn") private var captionsOn = true
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if captionsOn {
            switch style {
            case .band: band
            case .plain(let alignment): plain(alignment)
            case .bubble: bubble
            }
        }
    }

    private var bubble: some View {
        Text(verbatim: caption ?? " ")
            .typeRole(.cardTitle)
            .foregroundStyle(Palette.text)
            .lineLimit(typeSize.isAccessibilitySize ? nil : 3)
            // Every line shows at the largest sizes (it was cut to one line; review C).
            .fixedSize(horizontal: false, vertical: typeSize.isAccessibilitySize)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 34)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Palette.surface, in: .rect(cornerRadius: Metrics.cardRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
                    .strokeBorder(Palette.textMuted.opacity(0.25), lineWidth: 1)
            }
            .opacity(caption == nil ? 0 : 1)
            .accessibilityElement()
            .accessibilityLabel(Text(verbatim: caption ?? ""))
            .accessibilityHidden(caption == nil)
            .accessibilityAddTraits(.updatesFrequently)
    }

    private func plain(_ alignment: HorizontalAlignment) -> some View {
        Text(verbatim: caption ?? " ")
            .typeRole(.body)
            .foregroundStyle(Palette.text)
            .lineLimit(typeSize.isAccessibilitySize ? nil : 3)
            // Every line shows at the largest sizes (it was cut to one line; review C).
            .fixedSize(horizontal: false, vertical: typeSize.isAccessibilitySize)
            .multilineTextAlignment(alignment == .leading ? .leading : .center)
            // Two lines kept free, so the controls below do not jump as lines come and go.
            .frame(maxWidth: .infinity, minHeight: 52, alignment: alignment == .leading ? .topLeading : .top)
            .opacity(caption == nil ? 0 : 1)
            .accessibilityElement()
            .accessibilityLabel(Text(verbatim: caption ?? ""))
            .accessibilityHidden(caption == nil)
            .accessibilityAddTraits(.updatesFrequently)
    }

    /// Room for two caption lines, so the band does not jump as lines change (not a touch target).
    private static let bandMinHeight: CGFloat = 60

    private var band: some View {
        Text(verbatim: caption ?? " ")
            .typeRole(.body)
            .foregroundStyle(.white)
            .lineLimit(typeSize.isAccessibilitySize ? nil : 3)
            // Every line shows at the largest sizes (it was cut to one line; review C).
            .fixedSize(horizontal: false, vertical: typeSize.isAccessibilitySize)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: Self.bandMinHeight)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.black.opacity(0.68), in: .rect(cornerRadius: 16, style: .continuous))
            .opacity(caption == nil ? 0 : 1)
            .accessibilityElement()
            .accessibilityLabel(Text(verbatim: caption ?? ""))
            .accessibilityHidden(caption == nil)
            .accessibilityAddTraits(.updatesFrequently)
    }
}
