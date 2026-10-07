import SwiftUI

/// "Share with family": a square card with the landmark picture and one warm line. Never steps,
/// health details, street names or house numbers.
struct ShareCardButton: View {
    let content: CompleteContent
    @Environment(\.displayScale) private var displayScale
    @State private var image: Image?

    var body: some View {
        ZStack {
            // Non-empty base so the render task runs.
            Color.clear.frame(height: 1)
            if let image {
                ShareLink(item: image, preview: SharePreview(Text(verbatim: AppBrand.name), image: image)) {
                    Text("Share with family")
                }
                .buttonStyle(.secondaryAction)
            }
        }
        .task(id: content.shareLine) { image = render() }
    }

    @MainActor private func render() -> Image? {
        let renderer = ImageRenderer(content: ShareCard(line: content.shareLine))
        renderer.scale = displayScale
        return renderer.uiImage.map { Image(uiImage: $0) }
    }
}

/// The square card itself (1080 × 1080 at 3×).
struct ShareCard: View {
    let line: String

    var body: some View {
        VStack(spacing: 18) {
            ArtImage(art: .walkerCelebrate, height: 190, fallbackSymbol: "building.columns.fill")
            Text(verbatim: line)
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .foregroundStyle(Palette.text)
                .multilineTextAlignment(.center)
            Text(verbatim: AppBrand.name)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(Palette.secondary)
        }
        .padding(28)
        .frame(width: 360, height: 360)
        .background(Palette.bg)
    }
}
