import SwiftUI
import GentleWalkCore

/// S12 Chair move player: 16:9 clip on the top third, big counter or timer, three ticked tips,
/// Easier / Harder, Back · Pause · Skip, and the fixed Break · This hurts row.
struct ChairPlayerView: View {
    let model: ChairPlayerModel
    @State private var fullScreen = false
    @State private var showsSound = false
    /// Tips are folded until she opens them; the choice holds for the rest of the session.
    @State private var showsTips = false

    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.startsFullScreen) private var startsFullScreen

    private var isPaused: Bool { if case .paused = model.player.state { true } else { false } }

    var body: some View {
        Group {
            if fullScreen || verticalSizeClass == .compact {
                FullScreenVideoView(
                    fileName: model.videoFile, title: model.exercise?.name,
                    moveProgress: model.moveProgress, next: model.followingName,
                    counter: model.countsReps ? model.repsText : model.timerText,
                    caption: model.player.caption?.text, isPaused: isPaused,
                    onExit: exitFullScreen, onBack: model.back, onPause: model.session.togglePause,
                    onSkip: model.skip,
                    onBreak: model.session.takeBreak, onHurts: model.session.openHurts)
            } else if model.isRest {
                RestBetweenMoves(timer: model.timerText, next: model.nextExercise, nextVideo: model.nextVideoFile,
                                 onSkipRest: model.skip,
                                 onBreak: model.session.takeBreak, onHurts: model.session.openHurts)
            } else {
                portrait
            }
        }
        .leavesFullScreenWhenUpright($fullScreen)
        .sheet(isPresented: $showsSound) {
            SoundSheet(showsMusic: true) { model.player.setLevels(voice: $0.voice, music: $0.music) }
        }
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
        VStack(spacing: 10) {
            HStack {
                Button("End", action: model.session.askToEnd).buttonStyle(.smallTextLink)
                Spacer()
                if let position = model.blockPosition {
                    Text(verbatim: position).typeRole(.caption).foregroundStyle(Palette.text)
                }
                SoundButton { showsSound = true }
            }
            if let progress = model.moveProgress {
                MoveProgressHeader(progress: progress, next: model.followingName)
            }
            ExerciseVideo(fileName: model.videoFile)
                .overlay(alignment: .topTrailing) { VideoCornerButton.expand(enterFullScreen).padding(4) }
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if model.countsReps {
                        MoveHeaderWithClock(exercise: model.exercise, clockWidth: 190) {
                            RepCounter(text: model.repsText, onAdd: model.session.addRep)
                        } detail: {
                            if model.session.isCountedForYou {
                                CountedForYouLabel(pulse: model.session.motion?.pulse ?? 0)
                            } else {
                                // Without the phone held to the chest, the count is hers (review D13).
                                Text("Tap +1 each time you stand").typeRole(.caption).foregroundStyle(Palette.textMuted)
                            }
                        }
                    } else {
                        // The clock beside the name, not on a row of its own (owner 01/10).
                        MoveHeaderWithClock(exercise: model.exercise) { MoveTimer(text: model.timerText) }
                    }
                    MoveOptionsRow(usesEasier: model.usesEasier, showsHarder: model.showsHarder,
                                   hasHarder: model.exercise?.harder != nil, showsTips: $showsTips,
                                   onEasier: { Task { await model.chooseEasier() } }, onHarder: model.chooseHarder)
                    MoveTips(tips: showsTips ? model.exercise?.tips ?? [] : [], note: model.versionNote)
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

/// "6 of 10" with a round +1 for counting by hand. "Counted for you" / the tap hint sit under the
/// move's name (`MoveHeaderWithClock`).
struct RepCounter: View {
    let text: String
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack(alignment: .center, spacing: 12) {
                Text(verbatim: text)
                    .typeRole(.timer)
                    .foregroundStyle(Palette.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.45)
                    .contentTransition(.numericText())
                Button(action: onAdd) {
                    Text(verbatim: "+1")
                        .typeRole(.cardTitle)
                        .foregroundStyle(Palette.onStrongFill)
                        .frame(width: 64, height: 64)
                        .background(Palette.secondary, in: .circle)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Count one"))
            }
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
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Palette.secondary.opacity(0.14), in: .rect(cornerRadius: 14))
            }
        }
    }
}

/// Rest between moves: light background, "Rest · 00:20", what comes next, Skip rest.
struct RestBetweenMoves: View {
    let timer: String
    let next: Exercise?
    /// The next move's clip, if the app has it.
    var nextVideo: String?
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
                // A large look at the next move, like a class's "get ready" (competitor idea 1).
                VStack(alignment: .leading, spacing: 10) {
                    NextUpName(name: next.name)
                    ExerciseVideo(fileName: nextVideo).frame(maxWidth: 420)
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
