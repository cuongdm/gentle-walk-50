import SwiftUI
import GentleWalkCore

/// S11 Walk player: readable from 1–2 m on a table. Phase label and clock are the biggest things;
/// Break and This hurts are always on screen. iPad and landscape put controls on the right.
struct WalkPlayerView: View {
    let model: WalkPlayerModel
    let session: WorkoutSessionModel
    var showsMusic = false

    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var isWide: Bool { sizeClass == .regular || verticalSizeClass == .compact }
    private var isOutdoors: Bool { session.request.place == .outdoors }
    /// Outdoors: "0.6 mi" under the clock, from GPS or steps.
    private var distanceText: String? {
        guard isOutdoors, let miles = session.outdoorDistance?() else { return nil }
        return CompleteContent.miles(miles)
    }
    private var isPaused: Bool { if case .paused = model.player.state { true } else { false } }

    var body: some View {
        ZStack {
            Palette.bg.ignoresSafeArea()
            model.tone.wash.ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: model.tone)
            if isWide {
                HStack(alignment: .top, spacing: 24) {
                    VStack(spacing: 16) {
                        WalkTopBar(status: model.statusLine, locationOn: session.locationOn?() ?? false, onEnd: session.askToEnd)
                        Spacer(minLength: 0)
                        PhaseBlock(label: model.phaseLabel, tone: model.tone, clock: model.clock, distance: distanceText, isLarge: true)
                        NextUpRow(next: model.nextLine, progress: model.phaseProgress, tone: model.tone)
                        CaptionBar(caption: model.captionText)
                        Spacer(minLength: 0)
                    }
                    VStack(spacing: 20) {
                        WalkScene(level: model.level, isOutdoors: isOutdoors, height: 220)
                        if !isOutdoors { LevelLine(level: model.level) }
                        PauseButton(isPaused: isPaused, action: session.togglePause)
                        Spacer(minLength: 0)
                        safetyBar
                    }
                    .frame(maxWidth: 360)
                }
                .padding(Metrics.screenMargin)
            } else {
                // Small phones (iPhone SE) and large text: drop the picture first, never the
                // controls, the clock or the safety buttons.
                ViewThatFits(in: .vertical) {
                    portrait(showsScene: true)
                    portrait(showsScene: false)
                }
                .padding(.horizontal, Metrics.screenMargin)
                .padding(.bottom, 8)
            }
            if model.player.state == .paused(.user), session.stage == .playing {
                PausedOverlay(onResume: session.togglePause, onEnd: session.askToEnd)
            }
            if let transition = session.transition {
                PhaseTransitionCard(label: transition.label, tone: transition.tone)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: session.transition)
    }

    /// The picture takes whatever height is left (110–260 pt); too little room drops it.
    private func portrait(showsScene: Bool) -> some View {
        VStack(spacing: 14) {
            WalkTopBar(status: model.statusLine, locationOn: session.locationOn?() ?? false, onEnd: session.askToEnd)
            if showsScene {
                WalkScene(level: model.level, isOutdoors: isOutdoors, height: 260, minHeight: 110)
            }
            PhaseBlock(label: model.phaseLabel, tone: model.tone, clock: model.clock, distance: distanceText)
            NextUpRow(next: model.nextLine, progress: model.phaseProgress, tone: model.tone)
            if !showsScene { Spacer(minLength: 0) }
            CaptionBar(caption: model.captionText)
            if !isOutdoors { LevelLine(level: model.level) }
            PauseButton(isPaused: isPaused, action: session.togglePause)
            safetyBar
        }
    }

    private var safetyBar: some View {
        WorkoutSafetyBar(isVoiceOn: model.player.isVoiceOn, showsMusic: showsMusic, isMusicOn: model.player.isMusicOn,
                         onVoice: { model.player.setVoiceOn(!model.player.isVoiceOn) },
                         onMusic: { model.player.setMusicOn(!model.player.isMusicOn) },
                         onBreak: session.takeBreak, onHurts: session.openHurts)
    }
}

/// End on the left, where the session is on the right (15 pt).
struct WalkTopBar: View {
    let status: String
    var locationOn = false
    let onEnd: () -> Void

    var body: some View {
        HStack {
            Button("End", action: onEnd)
                .buttonStyle(.smallTextLink)
            if locationOn {
                Label("Location on", systemImage: "location.fill")
                    .typeRole(.caption)
                    .foregroundStyle(Palette.text)
            }
            Spacer()
            Text(verbatim: status)
                .typeRole(.caption)
                .foregroundStyle(Palette.text)
                .multilineTextAlignment(.trailing)
        }
    }
}

/// Illustration by level (placeholder until the watercolour scenes exist).
struct WalkScene: View {
    let level: WalkLevel
    var isOutdoors = false
    var height: CGFloat = 150
    var minHeight: CGFloat?

    var body: some View {
        if let minHeight {
            ArtImage.flexible(art, minHeight: minHeight, maxHeight: height, fallbackSymbol: symbol)
        } else {
            ArtImage(art: art, height: height, fallbackSymbol: symbol)
        }
    }

    private var art: Art {
        if isOutdoors { return .sceneOutdoors }
        return switch level {
        case .seated: .walkerSeatedMarch
        case .inPlace: .sceneLivingRoom
        case .pad: .sceneWalkingPad
        }
    }

    private var symbol: String {
        if isOutdoors { return "tree.fill" }
        return switch level {
        case .seated: "figure.seated.side"
        case .inPlace: "figure.walk"
        case .pad: "figure.walk.treadmill"
        }
    }
}

/// Phase name (34 pt, sun/sky chip) and the phase clock (the biggest number).
struct PhaseBlock: View {
    let label: String
    let tone: PhaseTone
    let clock: String
    var distance: String? = nil
    /// iPad and landscape: clock and label take half the screen.
    var isLarge = false

    var body: some View {
        VStack(spacing: 6) {
            Text(verbatim: label)
                .typeRole(.phaseLabel)
                .foregroundStyle(Palette.onLightFill)
                .padding(.horizontal, 18)
                .padding(.vertical, 6)
                .background(tone.fill, in: .capsule)
                .accessibilityAddTraits(.isHeader)
            PhaseClock(text: clock, isLarge: isLarge)
            if let distance {
                Text(verbatim: distance).typeRole(.cardTitle).foregroundStyle(Palette.text)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct PhaseClock: View {
    let text: String
    var isLarge = false

    var body: some View {
        Text(verbatim: text)
            .typeRole(isLarge ? .wallClock : .timer)
            .foregroundStyle(Palette.text)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .contentTransition(.numericText())
            .accessibilityLabel(Text("Time left in this part: \(text)"))
    }
}

/// Phase progress bar and "Next: easy walk · 3:00".
struct NextUpRow: View {
    let next: String?
    let progress: Double
    let tone: PhaseTone

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            PhaseProgressBar(progress: progress, tint: tone == .brisk ? Palette.sun : Palette.secondary)
            if let next {
                Text(verbatim: next).typeRole(.body).foregroundStyle(Palette.text)
            }
        }
    }
}

/// A thick rounded bar for the part in progress (readable from a distance, unlike a hairline).
struct PhaseProgressBar: View {
    let progress: Double
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(tint.opacity(0.25))
                Capsule().fill(tint).frame(width: max(12, proxy.size.width * min(1, max(0, progress))))
            }
        }
        .frame(height: 12)
        .accessibilityHidden(true)
    }
}

/// "Seated · Change level" (hidden outdoors).
struct LevelLine: View {
    let level: WalkLevel

    var body: some View {
        Text(level.title)
            .typeRole(.caption)
            .foregroundStyle(Palette.textMuted)
    }
}

/// Paused: dimmed background, "Paused", a big Resume and End workout.
struct PausedOverlay: View {
    let onResume: () -> Void
    let onEnd: () -> Void

    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Paused").typeRole(.screenTitle).foregroundStyle(Palette.text)
                Button("Resume", action: onResume).buttonStyle(.primaryAction)
                Button("End workout", action: onEnd).buttonStyle(.textLink)
            }
            .padding(Metrics.screenMargin)
        }
    }
}

extension WalkLevel {
    var title: LocalizedStringResource {
        switch self {
        case .seated: "Seated"
        case .inPlace: "In place"
        case .pad: "Walking pad"
        }
    }
}
