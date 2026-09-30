import SwiftUI

/// "Get ready" before the first word: the coach, the session's name and a calm 3, 2, 1, Go.
/// Nothing plays yet, so she can put the phone down and find her spot; "Skip the countdown" skips it.
struct WorkoutCountdownView: View {
    let title: String
    let onFinished: () -> Void

    /// 3, 2, 1, then 0 for "Go".
    @State private var count = 3
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 0)
            ArtImage(art: .walkerWave, height: 180)
                .frame(maxWidth: 220)
                .accessibilityHidden(true)
            VStack(spacing: 6) {
                Text("Get ready").typeRole(.screenTitle).foregroundStyle(Palette.text)
                    .accessibilityAddTraits(.isHeader)
                Text(verbatim: title).typeRole(.body).foregroundStyle(Palette.textMuted)
                    .multilineTextAlignment(.center)
            }
            CountdownDial(count: count, reduceMotion: reduceMotion)
            Spacer(minLength: 0)
            Button("Skip the countdown", action: finish).buttonStyle(.secondaryAction)
        }
        .padding(Metrics.screenMargin)
        .frame(maxWidth: 520)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
        .sensoryFeedback(.impact(weight: .light), trigger: count)
        .task { await run() }
    }

    private func run() async {
        while count > 0 {
            announce()
            try? await Task.sleep(for: .seconds(1))
            if Task.isCancelled { return }
            count -= 1
        }
        announce()
        try? await Task.sleep(for: .seconds(0.7))
        if Task.isCancelled { return }
        finish()
    }

    private func announce() {
        let text = count > 0 ? String(count) : String(localized: "Go")
        AccessibilityNotification.Announcement(text).post()
    }

    private func finish() { onFinished() }
}

/// The number in a sage ring that empties as the seconds pass.
private struct CountdownDial: View {
    let count: Int
    let reduceMotion: Bool

    var body: some View {
        ZStack {
            Circle().stroke(Palette.secondary.opacity(0.2), lineWidth: 10)
            Circle()
                .trim(from: 0, to: CGFloat(count) / 3)
                .stroke(Palette.secondary, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.9), value: count)
            Group {
                if count > 0 {
                    Text(verbatim: String(count))
                } else {
                    Text("Go")
                }
            }
            .font(.system(size: 76, weight: .bold, design: .rounded))
            .foregroundStyle(Palette.text)
            .contentTransition(reduceMotion ? .opacity : .numericText(countsDown: true))
            .animation(reduceMotion ? nil : .snappy, value: count)
        }
        .frame(width: 160, height: 160)
        .accessibilityHidden(true)
    }
}
