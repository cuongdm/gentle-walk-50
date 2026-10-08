#if DEBUG
import SwiftUI

/// Debug-only gallery of colour roles, type roles and button styles (plan task 1.15).
/// Shown with `-ScreenshotMode tokens`. Labels use `Text(verbatim:)` so nothing enters the catalog.
struct TokenGalleryView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(verbatim: "Design tokens")
                    .typeRole(.screenTitle)
                    .foregroundStyle(Palette.text)
                SwatchGrid()
                ButtonSamples()
                TypeRamp()
            }
            .padding(Metrics.screenMargin)
        }
        .background(Palette.bg)
    }
}

/// One tile per fill colour, labelled in the text colour the app uses on that fill, with its ratio.
private struct SwatchGrid: View {
    private struct Swatch: Identifiable {
        let fill: String
        let label: String
        var id: String { fill }
    }

    private let swatches = [
        Swatch(fill: Palette.Name.bg, label: Palette.Name.text),
        Swatch(fill: Palette.Name.surface, label: Palette.Name.text),
        Swatch(fill: Palette.Name.primary, label: Palette.Name.onStrongFill),
        Swatch(fill: Palette.Name.secondary, label: Palette.Name.onStrongFill),
        Swatch(fill: Palette.Name.dangerSoft, label: Palette.Name.onStrongFill),
        Swatch(fill: Palette.Name.sky, label: Palette.Name.onLightFill),
        Swatch(fill: Palette.Name.sun, label: Palette.Name.onLightFill),
    ]

    @Environment(\.colorScheme) private var colorScheme
    /// Grows with Dynamic Type, so accessibility sizes fall back to one column.
    @ScaledMetric(relativeTo: .body) private var tileMinWidth: CGFloat = 150

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: tileMinWidth), spacing: Metrics.touchSpacing)],
                  spacing: Metrics.touchSpacing) {
            ForEach(swatches) { swatch in
                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: swatch.fill).typeRole(.cardTitle)
                    Text(verbatim: ratio(swatch)).typeRole(.caption)
                }
                .foregroundStyle(Color(swatch.label))
                .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
                .padding(10)
                .background(Color(swatch.fill), in: .rect(cornerRadius: Metrics.cardRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: Metrics.cardRadius)
                        .strokeBorder(Palette.textMuted.opacity(0.3), lineWidth: 1)
                }
            }
        }
    }

    private func ratio(_ swatch: Swatch) -> String {
        let style: UIUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        let value = (try? ContrastRatio.between(swatch.label, swatch.fill, style: style)) ?? 0
        return "\(swatch.label) · \(value.formatted(.number.precision(.fractionLength(2)))):1"
    }
}

/// Every type role at the current Dynamic Type size.
private struct TypeRamp: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: "Screen title 30").typeRole(.screenTitle)
            Text(verbatim: "Card title 22").typeRole(.cardTitle)
            Text(verbatim: "Body 19 — Walk at your own pace, one step at a time.").typeRole(.body)
            Text(verbatim: "Caption 16, muted").typeRole(.caption).foregroundStyle(Palette.textMuted)
            Text(verbatim: "BRISK WALK").typeRole(.phaseLabel).foregroundStyle(Palette.onLightFill)
                .padding(.horizontal, 12)
                .background(Palette.sun, in: .rect(cornerRadius: 12))
            Text(verbatim: "04:30").typeRole(.timer)
        }
        .foregroundStyle(Palette.text)
    }
}

/// Main, secondary and danger buttons, plus a disabled main button.
private struct ButtonSamples: View {
    var body: some View {
        VStack(spacing: Metrics.touchSpacing) {
            Button {} label: { Text(verbatim: "Start walking") }
                .buttonStyle(.primaryAction)
            Button {} label: { Text(verbatim: "Not now") }
                .buttonStyle(.secondaryAction)
            Button {} label: { Text(verbatim: "This hurts") }
                .buttonStyle(.dangerAction)
            Button {} label: { Text(verbatim: "Disabled") }
                .buttonStyle(.primaryAction)
                .disabled(true)
        }
    }
}

#Preview("Light") { TokenGalleryView() }
#Preview("Dark") { TokenGalleryView().preferredColorScheme(.dark) }
#endif
