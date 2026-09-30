import SwiftUI

/// S01 Welcome: safety in five seconds. No sign-in, no account.
struct WelcomeView: View {
    let onBegin: () -> Void
    let onRestore: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ArtImage(art: .sceneLivingRoom, height: 260, fallbackSymbol: "figure.seated.side")
                .padding(.top, 12)
            Text(verbatim: "Gentle Walk").typeRole(.cardTitle).foregroundStyle(Palette.secondary)
            Text("Gentle walks and chair moves, at your pace.")
                .typeRole(.screenTitle)
                .foregroundStyle(Palette.text)
                .accessibilityAddTraits(.isHeader)
            VStack(alignment: .leading, spacing: 12) {
                WelcomeLine(symbol: "chair.fill", text: "Every move has a seated version")
                WelcomeLine(symbol: "ear", text: "Follow the voice, no need to watch")
                WelcomeLine(symbol: "clock", text: "5 minutes is enough to start")
            }
            Button("Let's begin", action: onBegin).buttonStyle(.primaryAction)
            Button("Restore purchase", action: onRestore)
                .buttonStyle(.smallTextLink)
                .frame(maxWidth: .infinity)
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

/// P1–P3: small picture, the part name, one line, Continue. Never moves on by itself.
struct PartIntroView: View {
    let part: Int
    let title: LocalizedStringResource
    var showsContinue = true
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ArtImage(art: .momentPlanNotebook, height: 160, fallbackSymbol: "list.bullet.rectangle")
                .padding(.top, 24)
            Text("Part \(part) · \(Text(title))")
                .typeRole(.screenTitle)
                .foregroundStyle(Palette.text)
                .accessibilityAddTraits(.isHeader)
            Text("A few quick questions. About a minute.").typeRole(.body).foregroundStyle(Palette.text)
            if showsContinue { ContinueButton(action: onContinue) }
        }
    }
}
