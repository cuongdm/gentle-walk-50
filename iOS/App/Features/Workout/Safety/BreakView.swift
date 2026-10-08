import SwiftUI

/// S14 Break: for breathlessness, heat or dizziness (different from pain). Counts up, never down;
/// nothing on screen says "giving up". Outdoors adds "Walk home gently".
struct BreakView: View {
    let startedAt: Date
    var isOutdoors = false
    let onContinue: () -> Void
    let onFinish: () -> Void
    var onWalkHome: () -> Void = {}

    @Environment(\.dynamicTypeSize) private var typeSize
    /// The buttons stay pinned at the bottom (on an iPhone SE all three were below the fold; review C);
    /// at accessibility sizes they end the page instead.
    private var pinsActions: Bool { !typeSize.isAccessibilitySize }

    var body: some View {
        // The painting shrinks first, then the words scroll; the buttons never move.
        ViewThatFits(in: .vertical) {
            content(artHeight: 180)
            content(artHeight: 120)
            ScrollView { content(artHeight: 120) }.scrollBounceBehavior(.basedOnSize)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if pinsActions {
                VStack(spacing: 10) { actions }
                    .padding(.horizontal, Metrics.screenMargin)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .readableColumn()
                    .background { PinnedBarBackground(wash: Palette.sky.opacity(0.22)) }
            }
        }
        .background(Palette.sky.opacity(0.22).ignoresSafeArea())
        .background(Palette.bg.ignoresSafeArea())
    }

    private func content(artHeight: CGFloat) -> some View {
        VStack(spacing: 16) {
            ArtImage(art: isOutdoors ? .sceneParkBench : .sceneBreak, height: artHeight,
                     fallbackSymbol: isOutdoors ? "tree.fill" : "cup.and.saucer.fill")
            ScreenHeader(title: "Take your time.",
                         subtitle: isOutdoors
                            ? "Find somewhere to sit or lean, in the shade if you can. Sip some water and breathe slowly."
                            : "Sit down, sip some water, breathe slowly. Your progress is saved.")
            // Counts up, so it is labelled: nobody should read it as time running out (review D35).
            VStack(spacing: 4) {
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
            }
            UrgentSignsNote()
            Spacer(minLength: 0)
            if !pinsActions { actions }
        }
        .padding(.horizontal, Metrics.screenMargin)
        .padding(.top, Metrics.screenMargin)
        .readableColumn()
    }

    @ViewBuilder private var actions: some View {
        Button("I'm ready to continue", action: onContinue).buttonStyle(.primaryAction)
        if isOutdoors {
            Button("Walk home gently", action: onWalkHome).buttonStyle(.secondaryAction)
        }
        Button("Finish here for today", action: onFinish).buttonStyle(.textLink)
    }
}
