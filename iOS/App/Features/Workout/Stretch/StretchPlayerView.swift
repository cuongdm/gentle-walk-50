import SwiftUI
import GentleWalkCore

/// S12b Stretch player: clip (resting on the hold frame while counting), pose name, a hold
/// countdown with the side, a breathing dot, two tips, Easier version only.
struct StretchPlayerView: View {
    let model: StretchPlayerModel
    @State private var fullScreen = false

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    private var isPaused: Bool { if case .paused = model.player.state { true } else { false } }

    var body: some View {
        Group {
            if fullScreen || verticalSizeClass == .compact {
                FullScreenVideoView(
                    fileName: model.pose?.videoFile, title: model.pose?.name, counter: model.holdText,
                    caption: model.player.caption?.text, isPaused: isPaused,
                    onExit: exitFullScreen, onBack: model.back, onPause: model.session.togglePause,
                    onSkip: { Task { await model.skip() } }, onBreak: model.session.takeBreak, onHurts: model.session.openHurts)
            } else {
                portrait
            }
        }
        .leavesFullScreenWhenUpright($fullScreen)
    }

    private func enterFullScreen() {
        fullScreen = true
        InterfaceOrientation.landscape()
    }

    private func exitFullScreen() {
        fullScreen = false
        InterfaceOrientation.portrait()
    }

    private var portrait: some View {
        VStack(spacing: 12) {
            HStack {
                Button("End", action: model.session.askToEnd).buttonStyle(.smallTextLink)
                Spacer()
                if let position = model.cooldownPosition {
                    Text(verbatim: position).typeRole(.caption).fontWeight(.semibold).foregroundStyle(Palette.text)
                }
            }
            ExerciseVideo(fileName: model.pose?.videoFile, isHolding: model.isHolding)
                .overlay(alignment: .topTrailing) { VideoCornerButton.expand(enterFullScreen).padding(4) }
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    MoveHeader(exercise: model.pose)
                    HStack(alignment: .center, spacing: 20) {
                        HoldTimer(text: model.holdText, side: model.sideText)
                        Spacer(minLength: 0)
                        BreathingDot(isActive: model.isHolding && !isPaused)
                    }
                    MoveTips(tips: model.pose?.tips ?? [], note: model.usesEasier ? model.pose?.easier : nil)
                    VersionPills(usesEasier: model.usesEasier, hasHarder: false,
                                 onEasier: { Task { await model.chooseEasier() } })
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            // The spoken line stays in view above the controls, as plain text (review U3).
            CaptionBar(caption: model.player.caption?.text, style: .plain(.center))
            PlayerControlRow(isPaused: isPaused, onBack: model.back, onPause: model.session.togglePause,
                             onSkip: { Task { await model.skip() } })
            WorkoutSafetyBar(showsVoice: false, onBreak: model.session.takeBreak, onHurts: model.session.openHurts)
        }
        .padding(.horizontal, Metrics.screenMargin)
        .padding(.bottom, 8)
        .readableColumn()
        .screenBackground()
    }
}

/// Hold countdown (64 pt+) with "Left side" / "Right side" under it.
struct HoldTimer: View {
    let text: String
    let side: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: text)
                .typeRole(.timer)
                .foregroundStyle(Palette.text)
                .contentTransition(.numericText())
            if let side {
                Text(verbatim: side).typeRole(.cardTitle).foregroundStyle(Palette.text)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// Breathing dot: grows for 4 s, shrinks for 4 s. Reduce Motion shows the words only.
struct BreathingDot: View {
    let isActive: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            Text("Breathe in… and out.")
                .typeRole(.caption)
                .foregroundStyle(Palette.text)
                .frame(maxWidth: 120)
        } else {
            TimelineView(.animation(paused: !isActive)) { context in
                let phase = context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 8)
                let scale = phase < 4 ? 0.55 + 0.45 * (phase / 4) : 1 - 0.45 * ((phase - 4) / 4)
                Circle()
                    .fill(Palette.sky)
                    .frame(width: 88, height: 88)
                    .scaleEffect(isActive ? scale : 0.7)
            }
            .frame(width: 96, height: 96)
            .accessibilityHidden(true)
        }
    }
}
