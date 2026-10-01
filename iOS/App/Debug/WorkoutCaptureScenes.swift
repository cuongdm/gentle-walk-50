#if DEBUG
import SwiftUI
import GentleWalkCore

/// Screenshot scenes for the workout screens (S09–S15). Each builds the real view with a silent
/// engine frozen at a chosen moment.
struct WorkoutCaptureScene: View {
    let state: CaptureState
    let content: ContentBundle

    @State private var session: WorkoutSessionModel?
    @State private var preview: WorkoutPreviewModel?

    var body: some View {
        // A non-empty base so `.task` always runs (a task on an empty Group never starts).
        ZStack {
            Palette.bg.ignoresSafeArea()
            switch state {
            case .phonePlacement:
                PhonePlacementView(onDone: { _ in })
            case .previewIndoor, .previewOutdoor, .previewStretch, .previewChair, .previewWalkingPad:
                if let preview {
                    WorkoutPreviewView(model: preview, onStart: { _ in }, onRemindLater: {})
                }
            default:
                if let session {
                    WorkoutView(session: session, name: "Margaret", showsMusic: true, healthConnected: true,
                                onChairMoves: session.request.place == .outdoors ? {} : nil,
                                onAgain: session.request.canReplay(isPro: true) ? {} : nil, onClose: { _ in })
                        .environment(\.forceStillFrames, state == .chairPlayerReduceMotion)
                        .environment(\.startsFullScreen, state == .chairFullscreen || state == .walkFullscreen)
                } else {
                    ProgressView()
                }
            }
        }
        .task { await build() }
    }

    private func build() async {
        switch state {
        case .previewIndoor, .previewOutdoor, .previewWalkingPad:
            let model = previewModel(PlannedDay(main: .walk, chairMoves: 1, cooldown: true), checkIn: .okay)
            model.place = state == .previewOutdoor ? .outdoors : state == .previewWalkingPad ? .pad : .indoors
            preview = model
        case .previewStretch:
            preview = previewModel(PlannedDay(main: .stretch, chairMoves: 0, cooldown: false), checkIn: .okay)
        case .previewChair:
            preview = previewModel(PlannedDay(main: .chair, chairMoves: 0, cooldown: true), checkIn: .okay)
        default:
            session = await sessionScene()
        }
    }

    private func previewModel(_ day: PlannedDay, checkIn: CheckIn) -> WorkoutPreviewModel {
        let defaults = UserDefaults(suiteName: "capture") ?? .standard
        defaults.removePersistentDomain(forName: "capture")
        return WorkoutPreviewModel(day: day, intensity: Intensity(checkIn: checkIn), checkIn: checkIn, suggestedLevel: .seated,
                                   limits: [.knees, .noFloor], rotationIndex: 0, content: content, defaults: defaults)
    }

    private func request(_ day: PlannedDay, intensity: Intensity = .steady, place: WorkoutPlace = .indoors,
                         firstWalk: Bool = false) -> WorkoutRequest {
        if firstWalk { return .firstWalk(limits: [.knees]) }
        return WorkoutRequest(day: day, level: .seated, intensity: intensity, place: place, limits: [.knees, .noFloor],
                              rotationIndex: 0)
    }

    private func make(_ request: WorkoutRequest) async -> WorkoutSessionModel {
        let model = WorkoutSessionModel(request: request, content: content, engine: SilentPlaybackEngine(), completion: nil,
                                        painRecorder: DiscardingPainRecorder(), prepareMedia: false)
        try? await model.load()
        model.play()
        return model
    }

    private func sessionScene() async -> WorkoutSessionModel? {
        let walk = PlannedDay(main: .walk, chairMoves: 0, cooldown: false)
        let chair = PlannedDay(main: .chair, chairMoves: 0, cooldown: true)
        switch state {
        case .walkPlayer, .walkPlayerDark, .walkPlayerIpad, .walkFullscreen, .walkTransition, .walkPaused, .walkEnd, .break, .breakOutdoor, .thisHurts:
            let place: WorkoutPlace = state == .breakOutdoor ? .outdoors : .indoors
            let model = await make(request(walk, intensity: .strong, place: place))
            // A moment in round 2 while the coach is speaking, so the caption shows.
            let brisk = model.player.timeline.phases.filter { $0.kind == .brisk }.dropFirst().first
            let cue = model.player.timeline.voice.first { $0.start >= (brisk?.start ?? 240) + 5 }
            model.player.tick((cue?.start ?? 246) + 0.6)
            if state == .walkTransition { model.setTransition(.init(label: model.walkModel.phaseLabel, tone: .brisk)) }
            if state == .walkPaused { model.togglePause() }
            if state == .walkEnd { model.askToEnd() }
            if state == .break || state == .breakOutdoor {
                model.stage(.breakTime(startedAt: Date().addingTimeInterval(-42)))
            }
            if state == .thisHurts { model.openHurts() }
            return model
        case .notSaved:
            let model = await make(request(PlannedDay(main: .walk, chairMoves: 0, cooldown: false)))
            model.stage(.notSaved)
            return model
        case .countdown:
            let model = WorkoutSessionModel(request: request(walk, intensity: .gentle), content: content,
                                            engine: SilentPlaybackEngine(), completion: nil, prepareMedia: false)
            try? await model.load()
            model.startWithCountdown()
            return model
        case .readyFirstWalk:
            let model = WorkoutSessionModel(request: request(PlannedDay(main: .walk, chairMoves: 0, cooldown: false), firstWalk: true),
                                            content: content, engine: SilentPlaybackEngine(), completion: nil, prepareMedia: false)
            try? await model.load()
            model.startWithCountdown(showsReady: true)
            return model
        case .outdoorPlayer, .outdoorPlayerNoGps, .outdoorPlayerFinding:
            let model = await make(request(walk, intensity: .steady, place: .outdoors))
            let gps = state == .outdoorPlayer
            // GPS on: the live map with a walk along Central Park's East Drive; finding: no fix
            // yet; no GPS: steps only, the painting stays.
            model.tracksRoute = state != .outdoorPlayerNoGps
            model.outdoorDistance = { gps ? 0.6 : state == .outdoorPlayerFinding ? 0 : 0.5 }
            model.locationOn = { gps }
            model.routeProvider = { gps ? Self.sampleRoute : [] }
            model.player.tick(200)
            return model
        case .chairPlayer, .chairPlayerDark, .chairFullscreen, .chairPlayerReduceMotion, .chairStandBehind, .chairTimed, .chairRest,
             .chairCounted:
            // Chair moves 7: three seated moves, sit-to-stand, then a move behind the chair.
            let model = await make(request(chair, intensity: .steady))
            let phases = model.player.timeline.phases
            let moves = phases.filter { $0.kind == .move }
            let sitToStand = moves.first { $0.exerciseID == "mv.sit-to-stand" } ?? moves[0]
            switch state {
            case .chairStandBehind:
                let standing = moves.last ?? moves[0]
                model.player.tick(standing.start + 0.5)
            case .chairTimed:
                model.player.tick(moves[0].start + 20)
            case .chairRest:
                if let rest = phases.first(where: { $0.kind == .rest }) { model.player.tick(rest.start + 6) }
            default:
                model.player.tick(sitToStand.start + 40)
                for _ in 0..<4 { model.addRep() }
                model.forceCountedForYou = state == .chairCounted
            }
            return model
        case .stretchPlayer, .stretchSwitchSide:
            let model = await make(request(PlannedDay(main: .stretch, chairMoves: 0, cooldown: false)))
            let twist = model.player.timeline.phases.first { $0.exerciseID == "st.twist" }
            let switchCue = model.player.timeline.voice.first { $0.lineID.hasPrefix("a10.switch") && $0.start > (twist?.start ?? 0) }
            let at = (switchCue?.start ?? 60) + (state == .stretchPlayer ? -8 : 12)
            model.player.tick(at)
            return model
        case .stretchCooldown:
            // A walk with a chair move ends with the cool-down stretch set.
            let model = await make(request(PlannedDay(main: .walk, chairMoves: 1, cooldown: true)))
            let poses = model.player.timeline.phases.filter { $0.block == .cooldown && $0.isExercise }
            if poses.count > 1 { model.player.tick(poses[1].start + 24) }
            return model
        case .complete, .completeXxl, .completeFirstWalk, .completeLevelUp, .completeStretch, .completeOutdoor:
            return await completeScene()
        default:
            return nil
        }
    }

    private func completeScene() async -> WorkoutSessionModel {
        let ny = content.journeys.first { $0.id == "jr.ny" }!
        var result = CompletionResult(sessionMiles: 0.6, journeyID: "jr.ny", routeMiles: 2.4,
                                      unlockedStops: [ny.stops[2]], nextStop: ny.stops[3], milesToNext: 0.4, activeDays: 13)
        var req = request(PlannedDay(main: .walk, chairMoves: 1, cooldown: true))
        var seconds = 12 * 60
        switch state {
        case .completeFirstWalk:
            req = request(PlannedDay(main: .walk, chairMoves: 0, cooldown: false), firstWalk: true)
            result = CompletionResult(sessionMiles: 0.25, journeyID: "jr.ny", routeMiles: 0.25, unlockedStops: [ny.stops[0]],
                                      nextStop: ny.stops[1], milesToNext: 0.75, activeDays: 1, isFirstWorkout: true)
            seconds = 300
        case .completeLevelUp:
            result.activeDays = 7
            result.reachedLevel = .sprout
            result.unlockedStops = []
        case .completeStretch:
            req = request(PlannedDay(main: .stretch, chairMoves: 0, cooldown: false))
            result.unlockedStops = []
            seconds = 8 * 60
        case .completeOutdoor:
            req = request(PlannedDay(main: .walk, chairMoves: 0, cooldown: false), place: .outdoors)
            result.sessionMiles = 0.9
            result.unlockedStops = []
        default:
            break
        }
        let model = WorkoutSessionModel(request: req, content: content, engine: SilentPlaybackEngine(), completion: nil,
                                        prepareMedia: false)
        if state == .completeOutdoor {
            // A loop in Central Park for the map (never shared).
            let start = Date()
            model.setRoute((0..<40).map { i in
                let angle = Double(i) / 39 * 2 * .pi
                return RoutePoint(latitude: 40.7812 + 0.004 * sin(angle), longitude: -73.9665 + 0.005 * cos(angle),
                                  horizontalAccuracy: 5, timestamp: start.addingTimeInterval(Double(i) * 18))
            })
        }
        model.show(result, seconds: seconds)
        return model
    }
}


extension WorkoutCaptureScene {
    /// About 0.6 mi up the East Drive of Central Park, for the live map capture.
    static let sampleRoute: [RoutePoint] = {
        let points: [(Double, Double)] = [
            (40.7644, -73.9730), (40.7655, -73.9724), (40.7667, -73.9716), (40.7679, -73.9709),
            (40.7690, -73.9704), (40.7701, -73.9700), (40.7712, -73.9697), (40.7723, -73.9693),
            (40.7733, -73.9688), (40.7742, -73.9680), (40.7750, -73.9671), (40.7757, -73.9662),
        ]
        let start = Date(timeIntervalSince1970: 1_790_000_000)
        return points.enumerated().map { index, point in
            RoutePoint(latitude: point.0, longitude: point.1, horizontalAccuracy: 5,
                       timestamp: start.addingTimeInterval(Double(index) * 18))
        }
    }()
}

#endif
