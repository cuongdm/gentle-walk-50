import SwiftUI
import GentleWalkCore

/// S02 "What would you like to feel?" — pick up to 2.
struct GoalView: View {
    let flow: OnboardingFlow

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScreenHeader(title: "What would you like to feel?", subtitle: "Pick up to 2.")
            ForEach(Goal.allCases, id: \.rawValue) { goal in
                SelectableCard(title: OnboardingCopy.title(goal), symbol: OnboardingCopy.symbol(goal),
                               isSelected: flow.answers.goals.contains(goal)) { flow.toggleGoal(goal) }
            }
            ContinueButton(hint: flow.hint, dimmed: flow.answers.goals.isEmpty, action: flow.next)
        }
    }
}

/// S03 "What's made it hard before?" — any that fit, no judgment.
struct BarriersView: View {
    let flow: OnboardingFlow

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScreenHeader(title: "What's made it hard before?", subtitle: "Pick any that fit. No judgment.")
            ForEach(Barrier.allCases, id: \.rawValue) { barrier in
                SelectableCard(title: OnboardingCopy.title(barrier), isSelected: flow.answers.barriers.contains(barrier)) {
                    flow.toggleBarrier(barrier)
                }
            }
            ContinueButton(action: flow.next)
        }
    }
}

/// S04 "You're not alone": no question, the title follows the first barrier picked.
struct UnderstandingView: View {
    let barrier: Barrier
    let onContinue: () -> Void

    var body: some View {
        let copy = OnboardingCopy.understanding(barrier)
        VStack(alignment: .leading, spacing: 18) {
            IllustrationPlaceholder(symbol: "cup.and.saucer.fill", tint: Palette.sun, height: 160)
                .padding(.top, 16)
            ScreenHeader(title: copy.title)
            Text(copy.body).typeRole(.body).foregroundStyle(Palette.text)
            ContinueButton(action: onContinue)
        }
    }
}

/// S05a "What should we call you?" — optional, with Skip.
struct NameView: View {
    @Bindable var flow: OnboardingFlow
    @FocusState private var focused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ScreenHeader(title: "What should we call you?")
            TextField(text: $flow.nameText, prompt: Text(verbatim: "Margaret")) { Text("Your name") }
                .typeRole(.cardTitle)
                .textContentType(.givenName)
                .submitLabel(.continue)
                .focused($focused)
                .padding(.horizontal, 16)
                .frame(minHeight: 64)
                .background(Palette.surface, in: .rect(cornerRadius: 16))
                .overlay { RoundedRectangle(cornerRadius: 16).strokeBorder(Palette.textMuted.opacity(0.4), lineWidth: 1) }
                .onSubmit(flow.next)
            ContinueButton(action: flow.next)
            Button("Skip") {
                flow.nameText = ""
                flow.next()
            }
            .buttonStyle(.textLink)
            .frame(maxWidth: .infinity)
        }
    }
}

/// S05b "How active are you now?"
struct ActivityLevelView: View {
    @Bindable var flow: OnboardingFlow

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScreenHeader(title: "How active are you now?")
            ForEach(ActivityAnswer.allCases, id: \.rawValue) { answer in
                SelectableCard(title: OnboardingCopy.title(answer), isSelected: flow.answers.activity == answer) {
                    flow.answers.activity = answer
                }
            }
            ContinueButton(hint: flow.hint, dimmed: flow.answers.activity == nil, action: flow.next)
        }
    }
}

/// S05c screen 1: one flight of stairs.
struct StairsView: View {
    @Bindable var flow: OnboardingFlow

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScreenHeader(title: "How do you feel after one flight of stairs?")
            ForEach(StairsAnswer.allCases, id: \.rawValue) { answer in
                SelectableCard(title: OnboardingCopy.title(answer), isSelected: flow.answers.stairs == answer) {
                    flow.answers.stairs = answer
                }
            }
            NotedLine(isShown: flow.answers.stairs != nil)
            ContinueButton(hint: flow.hint, dimmed: flow.answers.stairs == nil, action: flow.next)
        }
    }
}

/// S05c screen 2: getting up from a chair without hands.
struct ChairStrengthView: View {
    @Bindable var flow: OnboardingFlow

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScreenHeader(title: "Getting up from a chair without using your hands is…")
            ForEach(ChairAnswer.allCases, id: \.rawValue) { answer in
                SelectableCard(title: OnboardingCopy.title(answer), isSelected: flow.answers.chair == answer) {
                    flow.answers.chair = answer
                }
            }
            NotedLine(isShown: flow.answers.chair != nil)
            ContinueButton(hint: flow.hint, dimmed: flow.answers.chair == nil, action: flow.next)
        }
    }
}

/// "Noted. We'll check back later so you can see the change." — no score, no comparison.
private struct NotedLine: View {
    let isShown: Bool

    var body: some View {
        if isShown {
            Label("Noted. We'll check back later so you can see the change.", systemImage: "checkmark.circle.fill")
                .typeRole(.body)
                .foregroundStyle(Palette.text)
        }
    }
}

/// S06 "Anything we should go easy on?" — big chips, the body picture is only an illustration,
/// and a clear note to check with a doctor (1.4.1).
struct BodyLimitsView: View {
    let flow: OnboardingFlow

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScreenHeader(title: "Anything we should go easy on?", subtitle: "We'll only show moves that fit.")
            IllustrationPlaceholder(symbol: "figure.stand", tint: Palette.sky, height: 120)
            FlowLayout(spacing: Metrics.touchSpacing) {
                ForEach(OnboardingCopy.limitOrder, id: \.rawValue) { limit in
                    let selected = flow.answers.limits.contains(limit)
                    Button { flow.toggleLimit(limit) } label: { Text(OnboardingCopy.chip(limit)) }
                        .buttonStyle(PillButtonStyle(isSelected: selected))
                        .accessibilityAddTraits(selected ? .isSelected : [])
                }
                Button { flow.chooseNoLimits() } label: { Text("None of these") }
                    .buttonStyle(PillButtonStyle(isSelected: flow.noLimitsChosen))
                    .accessibilityAddTraits(flow.noLimitsChosen ? .isSelected : [])
            }
            Label("If you have a heart condition, recent surgery or you've been told to limit exercise, check with your doctor first.",
                  systemImage: "stethoscope")
                .typeRole(.body)
                .foregroundStyle(Palette.text)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Palette.sun.opacity(0.18), in: .rect(cornerRadius: Metrics.cardRadius))
            ContinueButton(action: flow.next)
        }
    }
}
