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
    @Environment(\.dynamicTypeSize) private var typeSize

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
                       miles: session.outdoorDistance?() ?? 0, seconds: model.player.currentTime,
                       steps: session.outdoorSteps?() ?? nil, height: height)
    }

    var body: some View {
        ZStack {
            if showsFullScreen {
                FullScreenVideoView(
                    fileName: video, title: model.phaseLabel, counter: model.clock, progress: model.phaseProgress,
                    tint: tint, caption: model.captionText, isPaused: isPaused,
                    onExit: exitFullScreen, onBack: model.back, onPause: session.togglePause, onSkip: model.skip,
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
            SoundSheet(showsMusic: showsMusic, player: session.player) { session.player.setLevels(voice: $0.voice, music: $0.music) }
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
                        PhaseBlock(label: model.phaseLabel, levelNote: levelNote, tone: model.tone, clock: model.clock,
                                   clockCaption: model.clockCaption, distance: distanceText, isLarge: true)
                        NextUpRow(next: model.nextLine, progress: model.isWalkingHome ? nil : model.phaseProgress, tone: model.tone)
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
                // The picture shrinks first, then hides (it left an empty gap when it hid inside its frame;
                // review C); the largest text sizes scroll the words, never the controls, the clock or the
                // safety buttons.
                // Indoors at the largest text sizes the crowded layout always: the other two could claim to
                // fit and then cut "Seated · Side step" above the controls on an iPhone SE (Mac 09/10/2026).
                let crowdedOnly = typeSize.isAccessibilitySize && !showsLiveMap
                ViewThatFits(in: .vertical) {
                    if showsLiveMap {
                        // The map shrinks on an iPhone SE, so the clock, Next and the spoken line stay in view.
                        portrait(.map(360))
                        portrait(.map(260))
                        portrait(.map(180))
                        // iPhone SE: a shorter map, with the clock at stat size and tighter spacing.
                        portrait(.map(150), isCompact: true)
                    } else if !crowdedOnly {
                        portrait(.picture)
                    }
                    if !crowdedOnly { portrait(.none) }
                    crowdedPortrait
                }
                .padding(.horizontal, Metrics.screenMargin)
                .padding(.bottom, 8)
                .frame(maxWidth: 700)
            }
        }
    }

    enum PortraitScene {
        case picture, map(CGFloat), none
        var isMap: Bool { if case .map = self { true } else { false } }
    }

    private func portrait(_ scene: PortraitScene, isCompact: Bool = false) -> some View {
        VStack(spacing: isCompact ? 10 : 14) {
            portraitText(scene, isCompact: isCompact)
            controls
        }
    }

    /// Everything above the controls: top bar, picture, phase, clock, next and the spoken line.
    private func portraitText(_ scene: PortraitScene, isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 10 : 14) {
            topBar(showsStatus: true)
            switch scene {
            case .map(let height):
                liveMap(height: height).frame(height: height)
            case .picture:
                // At least a useful size, or this layout does not fit and the next one (no picture) is used.
                WalkScene(level: model.level, video: video, isOutdoors: isOutdoors, height: sceneHeight,
                          minHeight: WalkScene.smallest, onFullScreen: expandAction)
                    .layoutPriority(1)
            case .none:
                EmptyView()
            }
            // The map's own strip shows the distance; without the map it sits under the clock.
            PhaseBlock(label: model.phaseLabel, levelNote: levelNote, tone: model.tone, clock: model.clock,
                       clockCaption: model.clockCaption, distance: scene.isMap ? nil : distanceText, isCompact: isCompact)
            NextUpRow(next: model.nextLine, progress: model.isWalkingHome ? nil : model.phaseProgress, tone: model.tone)
            CaptionBar(caption: model.captionText, style: .plain(.center))
            Spacer(minLength: 0)
        }
    }

    /// Largest text sizes: the part and its clock stay above the controls (held at a size that leaves
    /// room); the session line, Next and the spoken line scroll between them (review C, 09/10/2026).
    private var crowdedPortrait: some View {
        VStack(spacing: 10) {
            topBar(showsStatus: false)
            PhaseBlock(label: model.phaseLabel, levelNote: nil, tone: model.tone, clock: model.clock,
                       clockCaption: model.clockCaption, distance: distanceText)
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text(verbatim: model.statusLine).typeRole(.caption).foregroundStyle(Palette.text)
                        .fixedSize(horizontal: false, vertical: true)
                    if let levelNote {
                        Text(verbatim: levelNote).typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
                    }
                    NextUpRow(next: model.nextLine, progress: model.isWalkingHome ? nil : model.phaseProgress, tone: model.tone)
                    CaptionBar(caption: model.captionText, style: .plain(.leading))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollBounceBehavior(.basedOnSize)
            controls
        }
    }

    private func topBar(showsStatus: Bool) -> some View {
        WalkTopBar(status: showsStatus ? model.statusLine : nil, locationOn: !showsLiveMap && (session.locationOn?() ?? false),
                   onEnd: session.askToEnd, onSound: { showsSound = true })
    }

    /// Back · Pause · Skip as on the chair and stretch players (owner 02/10/2026: a tired walker could
    /// only leave a quicker part through This hurts, which logged pain); voice and music moved to the
    /// Sound sheet (top bar). Safety on the next row (Break · This hurts).
    private var controls: some View {
        VStack(spacing: 12) {
            PlayerControlRow(isPaused: isPaused, onBack: model.back, onPause: session.togglePause, onSkip: model.skip)
            WorkoutSafetyBar(showsVoice: false, onBreak: session.takeBreak, onHurts: session.openHurts)
        }
    }
}

/// "Round 2 of 6 · 7:13 left in total" on one line where it fits; otherwise broken at the dot, one part
/// per line, so a narrow phone never leaves "in total" alone on the second line (review A, 09/10/2026).
private struct StatusText: View {
    let status: String

    var body: some View {
        let parts = status.components(separatedBy: " · ")
        if parts.count == 2 {
            ViewThatFits(in: .horizontal) {
                Text(verbatim: status).lineLimit(1).fixedSize()
                VStack(alignment: .trailing, spacing: 0) {
                    Text(verbatim: parts[0]).fixedSize(horizontal: false, vertical: true)
                    Text(verbatim: parts[1]).fixedSize(horizontal: false, vertical: true)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: status))
        } else {
            Text(verbatim: status)
        }
    }
}

/// End on the left, where the session is on the right (15 pt).
struct WalkTopBar: View {
    /// "Round 2 of 6 · 7:13 left in total"; nil when the screen shows it elsewhere (largest text sizes).
    let status: String?
    var locationOn = false
    let onEnd: () -> Void
    var onSound: (() -> Void)? = nil

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        // At accessibility sizes End and Sound keep the row; the status and "Location on" get the full
        // width on the lines below, never squeezed between them (review A, 09/10/2026: the status ran to
        // five lines under the speaker on an iPhone SE).
        if typeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    EndSessionButton(action: onEnd)
                    Spacer()
                    if let onSound { SoundButton(action: onSound).dynamicTypeSize(...PlayerChrome.typeLimit) }
                }
                if locationOn { locationLabel }
                if let status {
                    Text(verbatim: status)
                        .typeRole(.caption)
                        .foregroundStyle(Palette.text)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        } else {
            HStack {
                EndSessionButton(action: onEnd)
                if locationOn { locationLabel }
                Spacer()
                if let status {
                    StatusText(status: status)
                        .typeRole(.caption)
                        .foregroundStyle(Palette.text)
                        .multilineTextAlignment(.trailing)
                }
                if let onSound { SoundButton(action: onSound).dynamicTypeSize(...PlayerChrome.typeLimit) }
            }
        }
    }

    private var locationLabel: some View {
        Label("Location on", systemImage: "location.fill")
            .typeRole(.caption)
            .foregroundStyle(Palette.text)
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

    static let smallest: CGFloat = 80

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(minHeight: minHeight ?? height, maxHeight: height)
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
    /// "left in this part", or "walking home" when the clock counts up.
    var clockCaption: LocalizedStringResource = "left in this part"
    var distance: String? = nil
    /// iPad and landscape: clock and label take half the screen.
    var isLarge = false
    /// iPhone SE beside the live map: the clock at stat size, without "left in this part".
    var isCompact = false

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
            PhaseClock(text: clock, isLarge: isLarge, isCompact: isCompact)
            // The big clock is this part; the top line is the whole session (clarity review D11).
            if !isCompact {
                Text(clockCaption).typeRole(.caption).foregroundStyle(Palette.textMuted)
            }
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
    var isCompact = false

    var body: some View {
        Text(verbatim: text)
            .typeRole(isLarge ? .wallClock : isCompact ? .stat : .timer)
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
    /// Nil while walking home: that part has no end, so a bar would only ever look stuck (review M13).
    let progress: Double?
    let tone: PhaseTone

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let progress {
                PhaseProgressBar(progress: progress, tint: tone == .brisk ? Palette.sun : Palette.secondary)
            }
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
    /// Why it paused, when it was not her ("Paused while your phone was busy.").
    var note: LocalizedStringResource?
    let onResume: () -> Void
    let onEnd: () -> Void

    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Paused").typeRole(.screenTitle).foregroundStyle(Palette.text)
                if let note {
                    Text(note).typeRole(.body).foregroundStyle(Palette.text).multilineTextAlignment(.center)
                }
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
