import SwiftUI

/// Caption strip (task 3.11): the exact spoken line on a dark translucent band, body size, up to
/// three lines. Input is only the text, so the bar redraws only when the line changes.
struct CaptionBar: View {
    let caption: String?

    var body: some View {
        Text(verbatim: caption ?? " ")
            .typeRole(.body)
            .foregroundStyle(.white)
            .lineLimit(3)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 60)
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
