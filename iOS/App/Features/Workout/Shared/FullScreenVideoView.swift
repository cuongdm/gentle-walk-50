import SwiftUI
import GentleWalkCore

/// Full-screen video (task 4.7, laid out again 30/09/2026). Phone on its side: the clip fills the
/// height on the left, where the coach stands, and one panel over the clip's empty wall on the
/// right holds the rest: part and clock, caption, controls, Break and This hurts. Nothing covers
/// her and nothing hides. Upright (iPad, or a phone that did not turn), the panel sits under the clip.
struct FullScreenVideoView: View {
    let fileName: String?
    /// Part or move above the counter ("BRISK WALK", "Sit-to-stand").
    var title: String? = nil
    /// Chair and stretch: one segment per move, and the next move's name.
    var moveProgress: SessionTimeline.MoveProgress? = nil
    var next: String? = nil
    let counter: String
    /// Share of this part done, as a bar under the counter.
    var progress: Double? = nil
    var tint: Color = Palette.secondary
    let caption: String?
    let isPaused: Bool
    let onExit: () -> Void
    /// Walks have no Back or Skip: only Pause shows, next to the clock.
    let onBack: (() -> Void)?
    let onPause: () -> Void
    let onSkip: (() -> Void)?
    let onBreak: () -> Void
    let onHurts: () -> Void

    @State private var showsTV = false

    var body: some View {
        GeometryReader { proxy in
            if proxy.size.width > proxy.size.height {
                sideBySide
            } else {
                stacked
            }
        }
        .background(Color.black.ignoresSafeArea())
        .sheet(isPresented: $showsTV) { WatchOnTVSheet() }
    }

    /// Exit and "Watch on your TV" in the clip's corner.
    private var cornerButtons: some View {
        HStack(spacing: 4) {
            VideoCornerButton.exit(onExit)
            VideoCornerButton(symbol: "tv", label: "Watch on your TV") { showsTV = true }
        }
    }

    private var sideBySide: some View {
        ZStack(alignment: .trailing) {
            ExerciseVideo(fileName: fileName)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .overlay(alignment: .topLeading) { cornerButtons.padding(6) }
            panel(scrolls: true)
                .frame(width: 330)
        }
        .padding(.vertical, 8)
    }

    private var stacked: some View {
        VStack(spacing: 16) {
            HStack {
                cornerButtons
                Spacer()
            }
            ExerciseVideo(fileName: fileName)
            panel(scrolls: false)
            Spacer(minLength: 0)
        }
        .padding(Metrics.screenMargin)
    }

    private var hasSkipping: Bool { onBack != nil && onSkip != nil }

    /// On its side the panel is the screen's height, so the top part scrolls at large text sizes;
    /// upright it is only as tall as its content.
    private func panel(scrolls: Bool) -> some View {
        VStack(spacing: 12) {
            if scrolls {
                ScrollView { readout }.scrollBounceBehavior(.basedOnSize)
            } else {
                readout
            }
            if let onBack, let onSkip {
                PlayerControlRow(isPaused: isPaused, onBack: onBack, onPause: onPause, onSkip: onSkip)
            }
            WorkoutSafetyBar(showsVoice: false, onBreak: onBreak, onHurts: onHurts)
        }
        .padding(14)
        .background(Palette.surface, in: .rect(cornerRadius: 24, style: .continuous))
    }

    /// Part, counter (with Pause beside it on walks), progress and the spoken line.
    private var readout: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let moveProgress { MoveProgressHeader(progress: moveProgress, next: next) }
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    if let title {
                        Text(verbatim: title).typeRole(.caption).fontWeight(.bold)
                            .foregroundStyle(Palette.textMuted)
                            .accessibilityAddTraits(.isHeader)
                    }
                    Text(verbatim: counter)
                        .typeRole(.stat)
                        .foregroundStyle(Palette.text)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .contentTransition(.numericText())
                }
                Spacer(minLength: 8)
                if !hasSkipping { PauseButton(isPaused: isPaused, size: 64, action: onPause) }
            }
            if let progress { PhaseProgressBar(progress: progress, tint: tint) }
            CaptionBar(caption: caption, style: .plain(.leading))
        }
    }
}
