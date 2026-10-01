import SwiftUI
import GentleWalkCore

/// Onboarding container: a progress line naming the part and a Back button with a word, then one
/// question per screen. The paywall (S08) is shown by the app flow after "See my options".
struct OnboardingView: View {
    @Bindable var flow: OnboardingFlow
    let onRestore: () -> Void
    let onFinished: () -> Void

    @Environment(\.dynamicTypeSize) private var typeSize
    /// "See my options" stays in view on the long plan screen (not at accessibility sizes).
    private var pinsPlanButton: Bool { flow.step == .plan && !typeSize.isAccessibilitySize }
    /// Short steps (a picture and a line) keep Continue at the bottom like the question steps,
    /// instead of right under the text with half the screen empty (review U5).
    private var pinsContinue: Bool {
        [.part1, .understanding, .part2, .part3, .body].contains(flow.step) && !typeSize.isAccessibilitySize
    }

    var body: some View {
        VStack(spacing: 0) {
            if flow.step != .welcome {
                // A part's intro screen already names the part in its title (review D22).
                OnboardingProgressHeader(label: [.part1, .part2, .part3].contains(flow.step) ? nil : flow.progressLabel,
                                         onBack: flow.back)
            }
            ScrollView {
                screen
                    .padding(.horizontal, Metrics.screenMargin)
                    .padding(.bottom, 24)
                    .frame(maxWidth: 640)
                    .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .pinnedActions(pinsPlanButton || pinsContinue) {
            if pinsPlanButton {
                ContinueButton(title: "See my options", action: flow.next)
            } else if flow.step == .body {
                DoctorNote()
                ContinueButton(action: flow.next)
            } else {
                ContinueButton(action: flow.next)
            }
        }
        .screenBackground()
        .onChange(of: flow.step) { _, step in if step == .paywall { onFinished() } }
    }

    @ViewBuilder private var screen: some View {
        switch flow.step {
        case .welcome: WelcomeView(onBegin: flow.next, onRestore: onRestore)
        case .part1: PartIntroView(part: 1, title: "Your goal", showsContinue: !pinsContinue, onContinue: flow.next)
        case .goal: GoalView(flow: flow)
        case .barriers: BarriersView(flow: flow)
        case .understanding: UnderstandingView(barrier: flow.profile.understandingKey, showsContinue: !pinsContinue,
                                               onContinue: flow.next)
        case .part2: PartIntroView(part: 2, title: "About you", showsContinue: !pinsContinue, onContinue: flow.next)
        case .name: NameView(flow: flow)
        case .activity: ActivityLevelView(flow: flow)
        case .stairs: StairsView(flow: flow)
        case .chair: ChairStrengthView(flow: flow)
        case .part3: PartIntroView(part: 3, title: "Your body", showsContinue: !pinsContinue, onContinue: flow.next)
        case .body: BodyLimitsView(flow: flow, showsContinue: !pinsContinue)
        case .plan, .paywall: PlanReadyView(flow: flow, showsContinue: !pinsPlanButton)
        }
    }
}

/// "Part 2 of 3 · About you" with a Back button that has a word, not just an arrow.
struct OnboardingProgressHeader: View {
    let label: String?
    let onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Label("Back", systemImage: "chevron.left")
            }
            .buttonStyle(.smallTextLink)
            Spacer()
            if let label {
                Text(verbatim: label).typeRole(.caption).fontWeight(.semibold).foregroundStyle(Palette.text)
            }
        }
        .padding(.horizontal, Metrics.screenMargin)
        .padding(.top, 4)
    }
}

/// Continue button with the hint above it ("Pick at least one.").
struct ContinueButton: View {
    var hint: String?
    var title: LocalizedStringResource = "Continue"
    var dimmed = false
    let action: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            if let hint {
                Text(verbatim: hint).typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
            }
            Button(action: action) { Text(title) }
                .buttonStyle(.primaryAction)
                .opacity(dimmed ? 0.7 : 1)
        }
        .padding(.top, 8)
    }
}
