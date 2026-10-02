import SwiftUI

/// S14 Break: for breathlessness, heat or dizziness (different from pain). Counts up, never down;
/// nothing on screen says "giving up". Outdoors adds "Walk home gently".
struct BreakView: View {
    let startedAt: Date
    var isOutdoors = false
    let onContinue: () -> Void
    let onFinish: () -> Void
    var onWalkHome: () -> Void = {}

    var body: some View {
        VStack(spacing: 20) {
            ArtImage(art: isOutdoors ? .sceneParkBench : .sceneBreak, height: 180,
                     fallbackSymbol: isOutdoors ? "tree.fill" : "cup.and.saucer.fill")
            ScreenHeader(title: "Take your time.",
                         subtitle: isOutdoors
                            ? "Find somewhere to sit or lean, in the shade if you can. Sip some water and breathe slowly."
                            : "Sit down, sip some water, breathe slowly. Your progress is saved.")
            // Counts up, so it is labelled: nobody should read it as time running out (review D35).
            Text("Resting for").typeRole(.body).foregroundStyle(Palette.textMuted)
            TimelineView(.periodic(from: startedAt, by: 1)) { context in
                let seconds = max(0, Int(context.date.timeIntervalSince(startedAt)))
                Text(verbatim: Duration.seconds(seconds).formatted(.time(pattern: .minuteSecond)))
                    .typeRole(.timer)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .foregroundStyle(Palette.text)
                    .contentTransition(.numericText())
                    .accessibilityLabel(Text("Break time \(Duration.seconds(seconds).formatted(.units(allowed: [.minutes, .seconds])))"))
            }
            Text("Take as long as you need.").typeRole(.body).foregroundStyle(Palette.text)
            UrgentSignsNote()
            Spacer(minLength: 0)
            Button("I'm ready to continue", action: onContinue).buttonStyle(.primaryAction)
            if isOutdoors {
                Button("Walk home gently", action: onWalkHome).buttonStyle(.secondaryAction)
            }
            Button("Finish here for today", action: onFinish).buttonStyle(.textLink)
        }
        .padding(Metrics.screenMargin)
        .scrollsWhenCrowded()
        .readableColumn()
        .background(Palette.sky.opacity(0.22).ignoresSafeArea())
        .background(Palette.bg.ignoresSafeArea())
    }
}
