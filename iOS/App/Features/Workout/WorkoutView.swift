import SwiftUI
import GentleWalkCore

/// The workout cover: picks the player for the current part of the day (walk, chair moves,
/// stretch), and shows Break, This hurts, the End question and Complete.
struct WorkoutView: View {
    let session: WorkoutSessionModel
    let name: String?
    var showsMusic = false
    /// Review milestone allowed for this result (task 6.11), and what to record once asked.
    var reviewMilestone: (CompletionResult) -> ReviewMilestone? = { _ in nil }
    var onReviewAsked: (ReviewMilestone) -> Void = { _ in }
    /// Outdoors: start today's chair moves from Complete.
    var onChairMoves: (() -> Void)?
    /// Complete → "Do it again": closes this session (recording it), then starts the same one.
    var onAgain: (() -> Void)?
    let onClose: (CompletionResult?) -> Void

    var body: some View {
        content
            .onChange(of: session.player.state) { _, state in
                if state == .finished, !session.isComplete, session.stage == .playing {
                    Task { await session.finish() }
                }
            }
            .alert("End this session?", isPresented: endBinding) {
                Button("Keep going", role: .cancel, action: session.keepGoing)
                Button("End session") { Task { await session.finish() } }
            } message: {
                Text("Your progress so far is saved.")
            }
    }

    @ViewBuilder private var content: some View {
        switch session.stage {
        case .preparing, .saving:
            ProgressView().controlSize(.large).frame(maxWidth: .infinity, maxHeight: .infinity).screenBackground()
        case .countdown:
            WorkoutCountdownView(title: session.request.title, onFinished: session.countdownFinished)
        case .standBehindChair:
            StandBehindChairView(onReady: session.confirmStanding)
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
                                         name: name, content: session.content),
                onFeeling: session.recordFeeling, onDone: { onClose(result) }, route: session.route,
                chairMovesMinutes: session.request.place == .outdoors && onChairMoves != nil ? 4 : nil,
                onChairMoves: { onChairMoves?() },
                onAgain: onAgain.map { again in { onClose(result); again() } })
            .reviewPrompt(reviewMilestone(result), onAsked: onReviewAsked)
        case .playing, .confirmEnd:
            player
        }
    }

    @ViewBuilder private var player: some View {
        switch session.player.currentPhase?.block ?? .walk {
        case .walk:
            WalkPlayerView(model: session.walkModel, session: session, showsMusic: showsMusic)
        case .chair:
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
