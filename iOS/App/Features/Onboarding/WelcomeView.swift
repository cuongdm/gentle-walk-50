import SwiftUI

/// S01 Welcome: safety in five seconds. No sign-in, no account. The painting moves: the coach marches
/// gently in place in her living room (a 3.3 s loop made from the painting, owner 03/10/2026); with
/// Reduce Motion it stays the still painting. The lines rise in one by one.
struct WelcomeView: View {
    let onBegin: () -> Void
    let onRestore: () -> Void

    var body: some View {
        // Tight spacing so "Let's begin" and "Restore purchase" both fit an iPhone SE (task 1.4).
        VStack(alignment: .leading, spacing: 12) {
            WelcomeHero()
                .padding(.top, 4)
                .reveal(.rise)
            HStack(spacing: 6) {
                AppIcon.steps.image.resizable().scaledToFit().frame(width: 18, height: 18).accessibilityHidden(true)
                Text(verbatim: AppBrand.name.uppercased())
                    .typeRole(.caption).fontWeight(.heavy).tracking(1.6)
                    .accessibilityLabel(Text(verbatim: AppBrand.name))
            }
            .foregroundStyle(Palette.primary)
            .reveal(delay: 0.1)
            Text("Steadier on your feet, at your own pace.")
                .typeRole(.screenTitle)
                .foregroundStyle(Palette.text)
                .accessibilityAddTraits(.isHeader)
                // A brush stroke of sienna under the slogan's end (Claude Design "Welcome").
                .overlay(alignment: .bottomTrailing) { BrushUnderline().frame(width: 130, height: 8).offset(y: 6) }
                .padding(.bottom, 4)
                .reveal(delay: 0.18)
            VStack(alignment: .leading, spacing: 8) {
                // The one promise first (steady program task 4.13), then how: seated, by voice. Each line
                // at most seven words so all three fit an iPhone SE (plan 08/10/2026 task 1.4).
                WelcomeLine(icon: .program, text: "12 weeks, 5 to 10 minutes a day").reveal(delay: 0.32)
                WelcomeLine(icon: .seated, text: "Every move has a seated version").reveal(delay: 0.42)
                WelcomeLine(icon: .listen, text: "Follow the voice, no need to watch").reveal(delay: 0.52)
            }
            Button("Let's begin", action: onBegin).buttonStyle(.primaryAction).reveal(delay: 0.7)
            Button("Restore purchase", action: onRestore)
                .buttonStyle(.smallTextLink)
                .frame(maxWidth: .infinity)
        }
    }
}

/// Bundled scene clips that belong to no exercise (ContentStoreTests checks the exercise clips).
enum SceneVideo {
    static let welcome = "welcome-loop.mp4"
    static let all: Set<String> = [welcome]
}

/// The moving painting, on paper with the card's corners; the still painting with Reduce Motion or
/// if the clip is missing. About a third of the visible height, at most 260 pt, so "Let's begin" stays
/// on an iPhone SE (≈ 207 pt there; plan 08/10/2026 task 1.4).
private struct WelcomeHero: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
            .fill(Palette.artPaper)
            .containerRelativeFrame(.vertical) { height, _ in min(260, height * 0.32) }
            .overlay { picture }
            .clipShape(.rect(cornerRadius: Metrics.cardRadius, style: .continuous))
            .accessibilityHidden(true)
    }

    @ViewBuilder private var picture: some View {
        if !reduceMotion, let url = ExerciseVideo.url(for: SceneVideo.welcome) {
            VideoLoopView(url: url, isPlaying: true, animates: false)
        } else {
            ArtImage.flexible(.sceneLivingRoom, minHeight: 120, maxHeight: 260, fallbackSymbol: "figure.seated.side")
        }
    }
}

private struct WelcomeLine: View {
    let icon: AppIcon
    let text: LocalizedStringResource

    var body: some View {
        HStack(spacing: 12) {
            AppIconChip(icon: icon)
            Text(text).typeRole(.body).foregroundStyle(Palette.text)
        }
        .accessibilityElement(children: .combine)
    }
}

/// A loose hand-drawn stroke, a little uneven, in sienna.
private struct BrushUnderline: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width, h = proxy.size.height
            Path { path in
                path.move(to: CGPoint(x: 0, y: h * 0.75))
                path.addCurve(to: CGPoint(x: w, y: h * 0.35), control1: CGPoint(x: w * 0.35, y: h * 0.2),
                              control2: CGPoint(x: w * 0.7, y: h * 0.7))
            }
            .stroke(Palette.accent.opacity(0.8), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
        }
        .accessibilityHidden(true)
    }
}
