import SwiftUI
import GentleWalkCore

/// Onboarding container (plan 08/10/2026 milestone 2): Welcome, seven questions on one shared frame
/// with the garden header, then Your plan. The paywall (S08) is shown by the app flow after "See my
/// options".
struct OnboardingView: View {
    @Bindable var flow: OnboardingFlow
    /// The coach preview on Your plan plays her real first lines.
    let voiceSource: VoiceSource
    let voiceLines: [VoiceLine]
    var playsCoachOnAppear = false
    let onRestore: () -> Void
    let onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            if flow.step != .welcome {
                OnboardingHeader(label: flow.stepLabel, gardenStep: flow.gardenStep, onBack: flow.back)
            }
            screen
                // One screen slides in as the last one leaves: from the right going on, from the left going
                // Back; a cross-fade only with Reduce Motion.
                .id(flow.step)
                .transition(reduceMotion ? .opacity
                            : .asymmetric(insertion: .move(edge: flow.movedForward ? .trailing : .leading).combined(with: .opacity),
                                          removal: .opacity))
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .animation(reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.45, dampingFraction: 0.9), value: flow.step)
        .screenBackground()
        .onChange(of: flow.step) { _, step in if step == .paywall { onFinished() } }
    }

    @ViewBuilder private var screen: some View {
        switch flow.step {
        case .welcome:
            ScrollView {
                WelcomeView(onBegin: flow.next, onRestore: onRestore)
                    .padding(.horizontal, Metrics.screenMargin)
                    .padding(.bottom, 24)
                    .readableColumn()
            }
            .scrollBounceBehavior(.basedOnSize)
        case .goal: GoalView(flow: flow)
        case .barriers: BarriersView(flow: flow)
        case .name: NameView(flow: flow)
        case .activity: ActivityLevelView(flow: flow)
        case .chair: ChairStrengthView(flow: flow)
        case .soreSpots: SoreSpotsView(flow: flow)
        case .anythingElse: AnythingElseView(flow: flow)
        case .plan, .paywall:
            PlanReadyView(flow: flow, voiceSource: voiceSource, voiceLines: voiceLines, playsCoachOnAppear: playsCoachOnAppear)
        }
    }
}

/// Screenshots run with the keyboard down (it would cover the buttons being checked).
enum CaptureHookGate {
    static var allowsKeyboard: Bool {
        #if DEBUG
        CaptureHook.state(from: ProcessInfo.processInfo.arguments) == nil
        #else
        true
        #endif
    }
}
