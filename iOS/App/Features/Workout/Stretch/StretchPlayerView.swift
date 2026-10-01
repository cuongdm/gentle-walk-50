import SwiftUI
import GentleWalkCore

/// S12b Stretch player: clip (resting on the hold frame while counting), pose name, a hold
/// countdown with the side, a breathing dot, two tips, Easier version only.
struct StretchPlayerView: View {
    let model: StretchPlayerModel
    @State private var fullScreen = false
    @State private var showsSound = false
    /// Tips are folded until she opens them; the choice holds for the rest of the session.
    @State private var showsTips = false

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    private var isPaused: Bool { if case .paused = model.player.state { true } else { false } }

    var body: some View {
        Group {
            if fullScreen || verticalSizeClass == .compact {
                FullScreenVideoView(
                    fileName: model.videoFile, title: model.pose?.name,
                    moveProgress: model.moveProgress, next: model.followingName, counter: model.holdText,
                    caption: model.player.caption?.text, isPaused: isPaused,
                    onExit: exitFullScreen, onBack: model.back, onPause: model.session.togglePause,
                    onSkip: model.skip, onBreak: model.session.takeBreak, onHurts: model.session.openHurts)
            } else {
                portrait
            }
        }
        .leavesFullScreenWhenUpright($fullScreen)
        .sheet(isPresented: $showsSound) {
            SoundSheet(showsMusic: true) { model.player.setLevels(voice: $0.voice, music: $0.music) }
        }
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
        VStack(spacing: 10) {
            HStack {
                EndSessionButton(action: model.session.askToEnd)
                Spacer()
                if let position = model.cooldownPosition {
                    Text(verbatim: position).typeRole(.caption).fontWeight(.semibold).foregroundStyle(Palette.text)
                }
                SoundButton { showsSound = true }
            }
            if let progress = model.moveProgress {
                MoveProgressHeader(progress: progress, next: model.followingName)
            }
            ExerciseVideo(fileName: model.videoFile, isHolding: model.isHolding && !model.playsHoldClip)
                .overlay(alignment: .topTrailing) { VideoCornerButton.expand(enterFullScreen).padding(4) }
                // The breathing guide sits on the clip during a hold, not on a row of its own (owner 01/10).
                .overlay(alignment: .bottomLeading) {
                    if model.isHolding { BreathingGuide(isActive: !isPaused).padding(8) }
                }
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    MoveHeaderWithClock(exercise: model.pose) {
                        HoldTimer(text: model.holdText, side: model.sideText)
                    }
                    MoveOptionsRow(usesEasier: model.usesEasier, hasHarder: false, showsTips: $showsTips,
                                   onEasier: { Task { await model.chooseEasier() } })
                    MoveTips(tips: showsTips ? model.pose?.tips ?? [] : [], note: model.note)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            // The spoken line stays in view above the controls, as plain text (review U3).
            CaptionBar(caption: model.player.caption?.text, style: .plain(.center))
            PlayerControlRow(isPaused: isPaused, onBack: model.back, onPause: model.session.togglePause,
                             onSkip: model.skip)
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
        VStack(alignment: .trailing, spacing: 2) {
            Text(verbatim: text)
                .typeRole(.timer)
                .foregroundStyle(Palette.text)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .contentTransition(.numericText())
            if let side {
                Text(verbatim: side).typeRole(.cardTitle).foregroundStyle(Palette.text)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// The breathing dot with its label, on a light capsule over the clip. The circle is a breathing guide,
/// not a button (clarity review D33).
struct BreathingGuide: View {
    let isActive: Bool

    var body: some View {
        HStack(spacing: 8) {
            BreathingDot(isActive: isActive, size: 40)
            Text("Breathe with the circle").typeRole(.caption).foregroundStyle(Palette.text)
                .lineLimit(2)
        }
        .padding(.leading, 4)
        .padding(.trailing, 12)
        .padding(.vertical, 4)
        .background(Palette.surface.opacity(0.88), in: .capsule)
    }
}

/// Breathing dot: grows for 4 s, shrinks for 4 s. Reduce Motion shows the words only.
struct BreathingDot: View {
    let isActive: Bool
    var size: CGFloat = 88
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
                    .frame(width: size, height: size)
                    .scaleEffect(isActive ? scale : 0.7)
            }
            .frame(width: size + 8, height: size + 8)
            .accessibilityHidden(true)
        }
    }
}
