import SwiftUI
import GentleWalkCore

/// S11 Walk player: readable from 1–2 m on a table. Phase label and clock are the biggest things;
/// Break and This hurts are always on screen. Laid out again 30/09/2026: the clip (or painting) on
/// top, part and clock, the spoken line as plain text, then two control rows — Voice · Pause ·
/// Music, and Break · This hurts. A phone on its side shows the clip full screen.
struct WalkPlayerView: View {
    let model: WalkPlayerModel
    let session: WorkoutSessionModel
    var showsMusic = false
    @State private var fullScreen = false
    @State private var showsSound = false

    @Environment(\.startsFullScreen) private var startsFullScreen
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var isOutdoors: Bool { session.request.place == .outdoors }
    /// Outdoors: "0.6 mi" under the clock, from GPS or steps.
    private var distanceText: String? {
        guard isOutdoors, let miles = session.outdoorDistance?() else { return nil }
        return String(localized: "\(CompleteContent.miles(miles)) walked")
    }
    private var isPaused: Bool { if case .paused = model.player.state { true } else { false } }
    /// The filmed loop for this move at her level and pace, if the app has it.
    private var video: String? { model.videoFile(isOutdoors: isOutdoors) }
    /// Phone on its side, or the expand button: the clip fills the screen.
    private var showsFullScreen: Bool { video != nil && (fullScreen || verticalSizeClass == .compact) }
    private var tint: Color { model.tone == .brisk ? Palette.sun : Palette.secondary }
    /// Outdoors with GPS: the live map takes the picture's place, and the distance moves into it.
    private var showsLiveMap: Bool { isOutdoors && session.tracksRoute }

    private func liveMap(height: CGFloat) -> some View {
        OutdoorLiveMap(route: session.routeProvider?() ?? [], hasFix: session.locationOn?() ?? false,
                       miles: session.outdoorDistance?() ?? 0, seconds: model.player.currentTime, height: height)
    }

    var body: some View {
        ZStack {
            if showsFullScreen {
                FullScreenVideoView(
                    fileName: video, title: model.phaseLabel, counter: model.clock, progress: model.phaseProgress,
                    tint: tint, caption: model.captionText, isPaused: isPaused,
                    onExit: exitFullScreen, onBack: nil, onPause: session.togglePause, onSkip: nil,
                    onBreak: session.takeBreak, onHurts: session.openHurts)
            } else {
                columns
            }
            if model.player.state == .paused(.user), session.stage == .playing, !showsFullScreen {
                PausedOverlay(onResume: session.togglePause, onEnd: session.askToEnd)
            }
            if let transition = session.transition {
                PhaseTransitionCard(label: transition.label, tone: transition.tone)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: session.transition)
        .leavesFullScreenWhenUpright($fullScreen)
        .sheet(isPresented: $showsSound) {
            SoundSheet(showsMusic: showsMusic) { session.player.setLevels(voice: $0.voice, music: $0.music) }
        }
        .onAppear { if startsFullScreen { enterFullScreen() } }
    }

    /// Tallest the picture may grow in the upright layout: a clip is bounded by its 16:9 width;
    /// a painting (no clip, or outdoors) takes the room that would otherwise stay empty (review U11).
    private var sceneHeight: CGFloat {
        if sizeClass == .regular { return 394 }
        return video == nil ? 320 : 232
    }

    /// Indoors: "Seated · Heel dig" under the part's name (the clip alone left it unclear).
    private var levelNote: String? { isOutdoors ? nil : model.levelNote }

    /// The expand button shows only on a clip.
    private var expandAction: (() -> Void)? {
        guard video != nil else { return nil }
        return enterFullScreen
    }

    private func enterFullScreen() {
        fullScreen = true
        InterfaceOrientation.landscape()
    }

    private func exitFullScreen() {
        fullScreen = false
        InterfaceOrientation.portrait()
    }

    /// Side by side on a phone on its side and on iPad held wide; stacked otherwise (iPad upright
    /// too, at a readable width).
    private var columns: some View {
        GeometryReader { proxy in
            let isWide = verticalSizeClass == .compact || (sizeClass == .regular && proxy.size.width > proxy.size.height)
            columns(isWide: isWide)
        }
    }

    @ViewBuilder private func columns(isWide: Bool) -> some View {
        ZStack {
            Palette.bg.ignoresSafeArea()
            model.tone.wash.ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: model.tone)
            if isWide {
                HStack(alignment: .top, spacing: 24) {
                    VStack(spacing: 16) {
                        WalkTopBar(status: model.statusLine, locationOn: !showsLiveMap && (session.locationOn?() ?? false), onEnd: session.askToEnd,
                                   onSound: { showsSound = true })
                        Spacer(minLength: 0)
                        PhaseBlock(label: model.phaseLabel, levelNote: levelNote, tone: model.tone, clock: model.clock, distance: distanceText,
                                   isLarge: true)
                        NextUpRow(next: model.nextLine, progress: model.phaseProgress, tone: model.tone)
                        CaptionBar(caption: model.captionText, style: .plain(.center))
                        Spacer(minLength: 0)
                    }
                    VStack(spacing: 20) {
                        // A phone on its side has no room for the picture above the controls.
                        if showsLiveMap {
                            liveMap(height: verticalSizeClass == .compact ? 220 : 340)
                        } else if verticalSizeClass != .compact {
                            WalkScene(level: model.level, video: video, isOutdoors: isOutdoors, height: 270,
                                      onFullScreen: expandAction)
                        }
                        Spacer(minLength: 0)
                        controls
                    }
                    .frame(maxWidth: 480)
                }
                .padding(Metrics.screenMargin)
            } else {
                // The picture shrinks first (and hides when too small); the largest text sizes
                // scroll the words, never the controls, the clock or the safety buttons.
                ViewThatFits(in: .vertical) {
                    portrait(showsScene: true)
                    // Largest text sizes: the words scroll so nothing is cut, while the controls
                    // stay on screen (review I11).
                    VStack(spacing: 10) {
                        ScrollView { portraitText(showsScene: false) }
                        controls
                    }
                }
                .padding(.horizontal, Metrics.screenMargin)
                .padding(.bottom, 8)
                .frame(maxWidth: 700)
            }
        }
    }

    /// The picture takes the room it needs first (see `sceneHeight`); too little room drops it.
    private func portrait(showsScene: Bool) -> some View {
        VStack(spacing: 14) {
            portraitText(showsScene: showsScene)
            controls
        }
    }

    /// Everything above the controls: top bar, picture, phase, clock, next and the spoken line.
    private func portraitText(showsScene: Bool) -> some View {
        VStack(spacing: 14) {
            WalkTopBar(status: model.statusLine, locationOn: !showsLiveMap && (session.locationOn?() ?? false), onEnd: session.askToEnd,
                                   onSound: { showsSound = true })
            if showsLiveMap {
                liveMap(height: 360).layoutPriority(1)
            } else if showsScene {
                WalkScene(level: model.level, video: video, isOutdoors: isOutdoors, height: sceneHeight, minHeight: 0,
                          onFullScreen: expandAction)
                    .layoutPriority(1)
            }
            PhaseBlock(label: model.phaseLabel, levelNote: levelNote, tone: model.tone, clock: model.clock,
                       distance: showsLiveMap ? nil : distanceText)
            NextUpRow(next: model.nextLine, progress: model.phaseProgress, tone: model.tone)
            CaptionBar(caption: model.captionText, style: .plain(.center))
            Spacer(minLength: 0)
        }
    }

    /// Playback on one row (Voice · Pause · Music), safety on the next (Break · This hurts).
    private var controls: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                PlayerToggle(title: "Voice", symbol: model.player.isVoiceOn ? "speaker.wave.2.fill" : "speaker.slash.fill",
                             isOn: model.player.isVoiceOn) { model.player.setVoiceOn(!model.player.isVoiceOn) }
                Spacer(minLength: 8)
                PauseButton(isPaused: isPaused, action: session.togglePause)
                Spacer(minLength: 8)
                if showsMusic {
                    PlayerToggle(title: "Music", symbol: model.player.isMusicOn ? "music.note" : "speaker.slash",
                                 isOn: model.player.isMusicOn) { model.player.setMusicOn(!model.player.isMusicOn) }
                } else {
                    // Keeps Pause in the middle.
                    Color.clear.frame(width: PlayerToggle.width, height: 1).accessibilityHidden(true)
                }
            }
            WorkoutSafetyBar(showsVoice: false, onBreak: session.takeBreak, onHurts: session.openHurts)
        }
    }
}

/// Voice or Music beside Pause: a round 56 pt button with its word under it.
struct PlayerToggle: View {
    static let width: CGFloat = 76

    let title: LocalizedStringResource
    let symbol: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .typeRole(.body)
                    .fontWeight(.semibold)
                    .frame(width: Metrics.minTouchTarget, height: Metrics.minTouchTarget)
                    .background(Palette.surface, in: .circle)
                    .overlay { Circle().strokeBorder(Palette.textMuted.opacity(0.2)) }
                    .accessibilityHidden(true)
                Text(title).typeRole(.caption)
            }
            .foregroundStyle(Palette.text)
            .frame(minWidth: Self.width)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityValue(isOn ? Text("On") : Text("Off"))
    }
}

/// End on the left, where the session is on the right (15 pt).
struct WalkTopBar: View {
    let status: String
    var locationOn = false
    let onEnd: () -> Void
    var onSound: (() -> Void)? = nil

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
            if let onSound { SoundButton(action: onSound) }
        }
    }
}

/// The filmed loop for the move when there is one, otherwise the painting for her level. It takes
/// the room left between the top bar and the clock, up to `height`, and hides itself below a useful
/// size, so a small phone never gets a sliver or an empty gap (review U7, U11).
struct WalkScene: View {
    let level: WalkLevel
    /// The clip to loop (from `WalkPlayerModel.videoFile`); nil shows the painting.
    var video: String?
    var isOutdoors = false
    var height: CGFloat = 150
    /// Upright phone: grows into the free room (nil = always `height`, the side column).
    var minHeight: CGFloat?
    /// Shows the full-screen button on the clip.
    var onFullScreen: (() -> Void)?

    private static let smallest: CGFloat = 80

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(minHeight: minHeight == nil ? height : 0, maxHeight: height)
            .overlay(alignment: .top) {
                GeometryReader { proxy in
                    if proxy.size.height >= Self.smallest {
                        picture(height: proxy.size.height)
                            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
                    }
                }
            }
    }

    @ViewBuilder private func picture(height: CGFloat) -> some View {
        if let video {
            ExerciseVideo(fileName: video)
                .overlay(alignment: .topTrailing) {
                    if let onFullScreen { VideoCornerButton.expand(onFullScreen).padding(4) }
                }
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
    /// "Seated": a walk done in a chair says so under the label (clarity review D31).
    var levelNote: String? = nil
    let tone: PhaseTone
    let clock: String
    var distance: String? = nil
    /// iPad and landscape: clock and label take half the screen.
    var isLarge = false

    var body: some View {
        VStack(spacing: 6) {
            Text(verbatim: label)
                .typeRole(.phaseLabel)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(Palette.onLightFill)
                .padding(.horizontal, 18)
                .padding(.vertical, 6)
                .background(tone.fill, in: .capsule)
                .accessibilityAddTraits(.isHeader)
            if let levelNote {
                Text(verbatim: levelNote).typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
            }
            PhaseClock(text: clock, isLarge: isLarge)
            // The big clock is this part; the top line is the whole session (clarity review D11).
            Text("left in this part").typeRole(.caption).foregroundStyle(Palette.textMuted)
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

/// Paused: dimmed background, "Paused", a big Resume and End session.
struct PausedOverlay: View {
    let onResume: () -> Void
    let onEnd: () -> Void

    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Paused").typeRole(.screenTitle).foregroundStyle(Palette.text)
                Button("Resume", action: onResume).buttonStyle(.primaryAction)
                Button("End session", action: onEnd).buttonStyle(.textLink)
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
