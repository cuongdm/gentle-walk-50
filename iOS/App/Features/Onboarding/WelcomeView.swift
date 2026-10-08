import SwiftUI

/// S01 Welcome: safety in five seconds. No sign-in, no account. The painting moves: the coach marches
/// gently in place in her living room (a 3.3 s loop made from the painting, owner 03/10/2026); with
/// Reduce Motion it stays the still painting. The lines rise in one by one.
struct WelcomeView: View {
    let onBegin: () -> Void
    let onRestore: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            WelcomeHero()
                .padding(.top, 12)
                .reveal(.rise)
            Text(verbatim: AppBrand.name.uppercased())
                .typeRole(.caption).fontWeight(.heavy).tracking(1.6)
                .foregroundStyle(Palette.secondary)
                .accessibilityLabel(Text(verbatim: AppBrand.name))
                .reveal(delay: 0.1)
            Text("Steadier on your feet, at your own pace.")
                .typeRole(.screenTitle)
                .foregroundStyle(Palette.text)
                .accessibilityAddTraits(.isHeader)
                .reveal(delay: 0.18)
            VStack(alignment: .leading, spacing: 12) {
                // The one promise first (steady program task 4.13), then how: seated, by voice.
                WelcomeLine(symbol: "calendar", text: "A 12-week plan for stronger legs and better balance").reveal(delay: 0.32)
                WelcomeLine(symbol: "chair.fill", text: "Every move has a seated version").reveal(delay: 0.42)
                WelcomeLine(symbol: "ear", text: "Follow the voice, no need to watch").reveal(delay: 0.52)
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
/// if the clip is missing.
private struct WelcomeHero: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if !reduceMotion, let url = ExerciseVideo.url(for: SceneVideo.welcome) {
            RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
                .fill(Palette.artPaper)
                .frame(height: 260)
                .overlay { VideoLoopView(url: url, isPlaying: true, animates: false) }
                .clipShape(.rect(cornerRadius: Metrics.cardRadius, style: .continuous))
                .accessibilityHidden(true)
        } else {
            ArtImage(art: .sceneLivingRoom, height: 260, fallbackSymbol: "figure.seated.side")
        }
    }
}

private struct WelcomeLine: View {
    let symbol: String
    let text: LocalizedStringResource

    var body: some View {
        HStack(spacing: 12) {
            IconChip(symbol: symbol)
            Text(text).typeRole(.body).foregroundStyle(Palette.text)
        }
        .accessibilityElement(children: .combine)
    }
}
