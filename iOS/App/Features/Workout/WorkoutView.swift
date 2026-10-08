import SwiftUI
import GentleWalkCore

/// The workout cover: picks the player for the current part of the day (walk, chair moves,
/// stretch), and shows Break, This hurts, the End question and Complete.
struct WorkoutView: View {
    let session: WorkoutSessionModel
    let name: String?
    var showsMusic = false
    /// Apple Health is connected, so an outdoor route is saved there.
    var healthConnected = false
    /// Review milestone allowed for this result (task 6.11), and what to record once asked.
    var reviewMilestone: (CompletionResult) -> ReviewMilestone? = { _ in nil }
    var onReviewAsked: (ReviewMilestone) -> Void = { _ in }
    /// Outdoors: start today's chair moves from Complete.
    var onChairMoves: (() -> Void)?
    /// Complete → "New postcard · Open": closes this session (recording it), then opens the postcard.
    var onOpenPostcard: ((Journey.Stop) -> Void)?
    /// Complete → "Do it again": closes this session (recording it), then starts the same one.
    var onAgain: (() -> Void)?
    /// "Not yet" on Up next: closes the session; the app may offer a reminder (First Walk).
    var onNotYet: (() -> Void)?
    /// Complete's week-0 invite: "Let's do it" closes this session (recording it), then opens the self-check;
    /// "Later" asks again in two days (steady program task 4.12).
    var onSelfCheck: (() -> Void)?
    var onSelfCheckLater: (() -> Void)?
    let onClose: (CompletionResult?) -> Void
    @State private var standCue = SpokenCue()
    @State private var arrivalCue = SpokenCue()

    var body: some View {
        content
            // Exercise clips move only while the coach plays: Pause, Break, a phone call or This hurts
            // freeze the clip with her (they kept looping before).
            .environment(\.videoPaused, session.player.state != .playing)
            .environment(\.clipDirection, session.player.moveDirection)
            .onChange(of: session.player.state) { _, state in
                if state == .finished, !session.isComplete, session.stage == .playing {
                    Task { await session.finish() }
                }
            }
            .alert("End this session?", isPresented: endBinding) {
                Button("Keep going", role: .cancel, action: session.keepGoing)
                Button("End session") { Task { await session.finish() } }
            } message: {
                // Under a minute nothing is saved: the question says so (it promised "saved", then the
                // next screen said nothing was; review 02/10/2026).
                if !WorkoutSessionModel.wouldSave(seconds: session.player.currentTime) {
                    Text("It's under a minute, so nothing will be saved.")
                } else {
                    Text("Your progress so far is saved.")
                }
            }
    }

    @ViewBuilder private var content: some View {
        switch session.stage {
        case .preparing, .saving:
            ProgressView().controlSize(.large).frame(maxWidth: .infinity, maxHeight: .infinity).screenBackground()
        case .ready:
            WorkoutReadyView(request: session.request, minutes: session.request.minutes(content: session.content),
                             onReady: session.readyConfirmed, onNotYet: { onNotYet?() ?? onClose(nil) })
        case .countdown:
            WorkoutCountdownView(title: session.request.title, onFinished: session.countdownFinished)
        case .standBehindChair:
            StandBehindChairView(onReady: session.confirmStanding, onSkip: session.skipStandingMove,
                                 onEnd: session.askToEnd,
                                 onSpeak: { standCue.play(["a7.stand", "a7.stand.wait"], from: session.content) },
                                 onStopSpeaking: standCue.stop)
        case .breakTime(let startedAt):
            BreakView(startedAt: startedAt, isOutdoors: session.request.place == .outdoors,
                      onContinue: session.endBreak, onFinish: { Task { await session.finish() } },
                      onWalkHome: {
                          Task {
                              try? await session.player.apply(.walkHomeGently)
                              session.endBreak()
                          }
                      })
        case .hurts:
            if let hurts = session.hurtsModel {
                ThisHurtsView(model: hurts) { outcome in
                    Task { await session.closeHurts(outcome) }
                }
            }
        case .complete(let result):
            CompleteView(
                content: CompleteContent(result: result, request: session.request, minutes: session.minutesDone,
                                         name: name, content: session.content, comparison: session.goalLine,
                                         stoppedForPain: session.stoppedForPain),
                onFeeling: session.recordFeeling, onDone: { onClose(result) },
                onOpenPostcard: { stop in onClose(result); onOpenPostcard?(stop) }, route: session.route,
                routeInHealth: healthConnected,
                // Stopped for pain: no "do more" offers (chair moves, again).
                chairMovesMinutes: session.request.place == .outdoors && onChairMoves != nil && !session.stoppedForPain
                    ? WorkoutRequest.chairMovesAfterOutdoor(limits: session.request.limits, rotationIndex: 0)
                        .minutes(content: session.content)
                    : nil,
                onChairMoves: { onChairMoves?() },
                onAgain: session.stoppedForPain ? nil : onAgain.map { again in { onClose(result); again() } },
                levelUpLine: session.stoppedForPain ? nil : session.levelUpLine,
                selfCheckInvite: session.offersSelfCheck && !session.stoppedForPain
                    ? onSelfCheck.map { open in
                        CompleteView.SelfCheckInvite(onStart: { onClose(result); open() }, onLater: { onSelfCheckLater?() })
                    }
                    : nil)
            .reviewPrompt(reviewMilestone(result), onAsked: onReviewAsked)
            // A new stop reached: the coach names it once, as the postcard opens (A8, plan 08/10/2026 #7).
            .task(id: result.recordID) {
                guard session.speaksOnComplete, let line = session.arrivalLineID else { return }
                arrivalCue.play([line], from: session.content)
            }
            .onDisappear(perform: arrivalCue.stop)
        case .notSaved:
            NotSavedView { onClose(nil) }
        case .playing, .confirmEnd:
            player
                // A phone call, Siri or headphones taken out paused it: say so on every player, with
                // Resume (it sat silent, only the Pause icon had turned to Play; review 02/10/2026).
                .overlay {
                    if session.player.state == .paused(.interrupted), session.stage == .playing {
                        PausedOverlay(note: "Paused while your phone was busy.", onResume: session.togglePause,
                                      onEnd: session.askToEnd)
                    }
                }
        }
    }

    @ViewBuilder private var player: some View {
        switch session.player.currentPhase?.block ?? .walk {
        case .walk:
            WalkPlayerView(model: session.walkModel, session: session, showsMusic: showsMusic)
        case .chair, .steady:
            ChairPlayerView(model: session.chairModel)
        case .stretch, .cooldown:
            StretchPlayerView(model: session.stretchModel)
        }
    }

    private var endBinding: Binding<Bool> {
        // Both alert buttons change the stage themselves; dismissal alone changes nothing.
        Binding(get: { session.stage == .confirmEnd }, set: { _ in })
    }
}

/// Ended in under a minute: no celebration and nothing saved, said kindly (owner 30/09/2026).
struct NotSavedView: View {
    let onClose: () -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        // Close stays pinned; the words scroll at the largest sizes, where the painting steps aside
        // (they were cut to "No proble…"; review C).
        VStack(spacing: 20) {
            Spacer(minLength: 0)
            if !typeSize.isAccessibilitySize {
                ArtImage(art: .walkerWave, height: 180).frame(maxWidth: 220).accessibilityHidden(true)
            }
            VStack(spacing: 8) {
                Text("No problem.").typeRole(.screenTitle).foregroundStyle(Palette.text)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                Text("Nothing was saved. Come back whenever you like.")
                    .typeRole(.body).foregroundStyle(Palette.text)
                    .multilineTextAlignment(.center)
            }
            .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(Metrics.screenMargin)
        .frame(maxWidth: .infinity)
        .readableColumn()
        .scrollsWhenCrowded()
        .pinnedActions(true) { Button("Close", action: onClose).buttonStyle(.primaryAction) }
        .screenBackground()
    }
}
