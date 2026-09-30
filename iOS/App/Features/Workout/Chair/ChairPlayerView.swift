import SwiftUI
import GentleWalkCore

/// S12 Chair move player: 16:9 clip on the top third, big counter or timer, three ticked tips,
/// Easier / Harder, Back · Pause · Skip, and the fixed Break · This hurts row.
struct ChairPlayerView: View {
    let model: ChairPlayerModel
    @State private var fullScreen = false

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.startsFullScreen) private var startsFullScreen

    private var isPaused: Bool { if case .paused = model.player.state { true } else { false } }

    var body: some View {
        Group {
            if fullScreen || verticalSizeClass == .compact {
                FullScreenVideoView(
                    fileName: model.exercise?.videoFile, title: model.exercise?.name,
                    counter: model.countsReps ? model.repsText : model.timerText,
                    caption: model.player.caption?.text, isPaused: isPaused,
                    onExit: exitFullScreen, onBack: model.back, onPause: model.session.togglePause,
                    onSkip: { Task { await model.skip() } },
                    onBreak: model.session.takeBreak, onHurts: model.session.openHurts)
            } else if model.isRest {
                RestBetweenMoves(timer: model.timerText, next: model.nextExercise,
                                 onSkipRest: { Task { await model.skip() } },
                                 onBreak: model.session.takeBreak, onHurts: model.session.openHurts)
            } else {
                portrait
            }
        }
        .leavesFullScreenWhenUpright($fullScreen)
        .onAppear { if startsFullScreen { enterFullScreen() } }
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
                if let position = model.blockPosition {
                    Text(verbatim: position).typeRole(.caption).foregroundStyle(Palette.text)
                }
            }
            ExerciseVideo(fileName: model.exercise?.videoFile)
                .overlay(alignment: .topTrailing) { VideoCornerButton.expand(enterFullScreen).padding(4) }
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    MoveHeader(exercise: model.exercise)
                    if model.countsReps {
                        RepCounter(text: model.repsText, countedForYou: model.session.isCountedForYou,
                                   pulse: model.session.motion?.pulse ?? 0, onAdd: model.session.addRep)
                    } else {
                        MoveTimer(text: model.timerText)
                    }
                    MoveTips(tips: model.exercise?.tips ?? [], note: model.versionNote)
                    VersionPills(usesEasier: model.usesEasier, showsHarder: model.showsHarder,
                                 hasHarder: model.exercise?.harder != nil,
                                 onEasier: { Task { await model.chooseEasier() } }, onHarder: model.chooseHarder)
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

/// Move name (screen title, scales with the text size) and its everyday purpose.
struct MoveHeader: View {
    let exercise: Exercise?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: exercise?.name ?? "")
                .typeRole(.screenTitle)
                .foregroundStyle(Palette.text)
                .accessibilityAddTraits(.isHeader)
            Text(verbatim: exercise?.purpose ?? "").typeRole(.body).foregroundStyle(Palette.text)
        }
    }
}

/// "6 of 10" with a round +1 for counting by hand, and "Counted for you" when the sensor is sure.
struct RepCounter: View {
    let text: String
    var countedForYou = false
    var pulse = 0
    let onAdd: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text(verbatim: text)
                    .typeRole(.timer)
                    .foregroundStyle(Palette.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .contentTransition(.numericText())
                if countedForYou {
                    CountedForYouLabel(pulse: pulse)
                }
            }
            Spacer(minLength: 0)
            Button(action: onAdd) {
                Text(verbatim: "+1")
                    .typeRole(.cardTitle)
                    .foregroundStyle(Palette.onStrongFill)
                    .frame(width: 72, height: 72)
                    .background(Palette.secondary, in: .circle)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Count one"))
        }
    }
}

/// Small "Counted for you" with a green dot that blinks on each counted rep. Hidden when the
/// sensor is not sure; never an error message.
struct CountedForYouLabel: View {
    let pulse: Int
    @State private var lit = false

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(Palette.secondary).frame(width: 12, height: 12).opacity(lit ? 1 : 0.35)
            Text("Counted for you").typeRole(.caption).fontWeight(.semibold).foregroundStyle(Palette.text)
        }
        .onChange(of: pulse) {
            lit = true
            Task { try? await Task.sleep(for: .milliseconds(350)); lit = false }
        }
    }
}

/// Timer for timed moves: "00:40".
struct MoveTimer: View {
    let text: String

    var body: some View {
        Text(verbatim: text)
            .typeRole(.timer)
            .foregroundStyle(Palette.text)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .contentTransition(.numericText())
            .accessibilityLabel(Text("Time left: \(text)"))
    }
}

/// Three tips with ticks, and the chosen version's instruction.
struct MoveTips: View {
    let tips: [String]
    let note: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(tips, id: \.self) { tip in
                Label {
                    Text(verbatim: tip).typeRole(.body)
                } icon: {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Palette.secondary)
                }
                .foregroundStyle(Palette.text)
            }
            if let note {
                Text(verbatim: note)
                    .typeRole(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(Palette.text)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Palette.secondary.opacity(0.14), in: .rect(cornerRadius: 14))
            }
        }
    }
}

/// "Easier version" · "Harder version" pills (stretches: Easier only).
struct VersionPills: View {
    let usesEasier: Bool
    var showsHarder = false
    var hasHarder = true
    let onEasier: () -> Void
    var onHarder: () -> Void = {}

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Metrics.touchSpacing) { pills }
            VStack(alignment: .leading, spacing: Metrics.touchSpacing) { pills }
        }
    }

    @ViewBuilder private var pills: some View {
        Button("Easier version", action: onEasier)
            .buttonStyle(PillButtonStyle(isSelected: usesEasier))
            .accessibilityAddTraits(usesEasier ? .isSelected : [])
        if hasHarder {
            Button("Harder version", action: onHarder)
                .buttonStyle(PillButtonStyle(isSelected: showsHarder))
                .accessibilityAddTraits(showsHarder ? .isSelected : [])
        }
    }
}

/// Rest between moves: light background, "Rest · 00:20", what comes next, Skip rest.
struct RestBetweenMoves: View {
    let timer: String
    let next: Exercise?
    let onSkipRest: () -> Void
    let onBreak: () -> Void
    let onHurts: () -> Void

    var body: some View {
        // Break and This hurts stay on screen; only the part above them scrolls when crowded.
        VStack(spacing: 18) {
            restInfo.scrollsWhenCrowded()
            WorkoutSafetyBar(showsVoice: false, onBreak: onBreak, onHurts: onHurts)
        }
        .padding(.horizontal, Metrics.screenMargin)
        .padding(.bottom, 8)
        .readableColumn()
        .background(Palette.sky.opacity(0.2).ignoresSafeArea())
        .background(Palette.bg.ignoresSafeArea())
    }

    private var restInfo: some View {
        VStack(spacing: 18) {
            Spacer()
            Text("Rest").typeRole(.phaseLabel).foregroundStyle(Palette.text)
            Text(verbatim: timer).typeRole(.timer).lineLimit(1).minimumScaleFactor(0.5)
                .foregroundStyle(Palette.text).contentTransition(.numericText())
            if let next {
                // Clip beside the name; the name goes under the clip when the text is large.
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 14) {
                        ExerciseVideo(fileName: next.videoFile).frame(width: 120)
                        NextUpName(name: next.name).fixedSize(horizontal: true, vertical: false)
                        Spacer(minLength: 0)
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        ExerciseVideo(fileName: next.videoFile).frame(maxWidth: 240)
                        NextUpName(name: next.name)
                    }
                }
                .cardStyle()
            }
            Button("Skip rest", action: onSkipRest).buttonStyle(.textLink)
            Spacer()
        }
    }
}

private struct NextUpName: View {
    let name: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("Next up").typeRole(.caption).foregroundStyle(Palette.textMuted)
            Text(verbatim: name).typeRole(.cardTitle).foregroundStyle(Palette.text)
        }
    }
}

/// Before a standing move: "Stand behind your chair. Hold on if you need to." · Ready.
struct StandBehindChairView: View {
    var line: LocalizedStringResource = "Stand behind your chair. Hold on if you need to."
    let onReady: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            ArtImage(art: .walkerBehindChair, height: 220, fallbackSymbol: "chair.fill")
            Text(line)
                .typeRole(.screenTitle)
                .foregroundStyle(Palette.text)
                .multilineTextAlignment(.center)
            Spacer()
            Button("Ready", action: onReady).buttonStyle(.primaryAction)
        }
        .padding(Metrics.screenMargin)
        .scrollsWhenCrowded()
        .readableColumn()
        .screenBackground()
    }
}
