import SwiftUI
import GentleWalkCore

/// S02 "What would you like from this?" — pick up to 2 (the answers are not all feelings, review D23).
struct GoalView: View {
    let flow: OnboardingFlow

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScreenHeader(title: "What would you like from this?", subtitle: "Pick up to 2.")
            ForEach(Goal.allCases, id: \.rawValue) { goal in
                SelectableCard(title: OnboardingCopy.title(goal), symbol: OnboardingCopy.symbol(goal),
                               tint: OnboardingCopy.tint(goal), isSelected: flow.answers.goals.contains(goal)) { flow.toggleGoal(goal) }
            }
            if flow.showsGoalLimit {
                Label("You can pick 2. Tap one to change it.", systemImage: "info.circle")
                    .typeRole(.body).foregroundStyle(Palette.text)
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

/// S04 "You're not alone": no question, the title follows the first barrier picked. It also opens
/// part 2 (the part intros went, owner 01/10/2026), so a last line says what comes next.
struct UnderstandingView: View {
    let barrier: Barrier
    var showsContinue = true
    let onContinue: () -> Void

    var body: some View {
        let copy = OnboardingCopy.understanding(barrier)
        VStack(alignment: .leading, spacing: 18) {
            ArtImage(art: .momentFriends, height: 180, fallbackSymbol: "cup.and.saucer.fill")
                .padding(.top, 16)
            ScreenHeader(title: copy.title)
            Text(copy.body).typeRole(.body).foregroundStyle(Palette.text)
            Text("Next, a few questions about your day.").typeRole(.body).foregroundStyle(Palette.textMuted)
                .padding(.top, 4)
            if showsContinue { ContinueButton(action: onContinue) }
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
        // The keyboard is up at once, ready for her name (owner 30/09/2026); a short wait lets the
        // step's slide-in finish first.
        .task {
            try? await Task.sleep(for: .milliseconds(450))
            focused = true
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

/// S05c: getting up from a chair without hands.
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

/// "Noted." — no score, no comparison (review D24). The "we'll ask again" promise went with the
/// stairs question (owner 01/10/2026): there is no check-in to ask it again yet.
private struct NotedLine: View {
    let isShown: Bool

    var body: some View {
        if isShown {
            Label("Noted. We'll start you somewhere comfortable.", systemImage: "checkmark.circle.fill")
                .typeRole(.body)
                .foregroundStyle(Palette.text)
        }
    }
}

/// S06 "Anything we should go easy on?" — the choices in two short groups (`BodyLimitChips`) and a
/// clear note to check with a doctor (1.4.1), pinned with Continue so it is always in view. No
/// picture: it took a third of the screen and said nothing (owner 01/10).
struct BodyLimitsView: View {
    let flow: OnboardingFlow
    /// Continue is pinned at the bottom by the container, except at accessibility sizes.
    var showsContinue = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScreenHeader(title: "Anything we should go easy on?", subtitle: "We'll only show moves that fit.")
            BodyLimitChips(selected: flow.answers.limits, onToggle: flow.toggleLimit,
                           noneChosen: flow.noLimitsChosen, onNone: flow.chooseNoLimits)
            if showsContinue {
                DoctorNote()
                ContinueButton(action: flow.next)
            }
        }
    }
}

/// "Check with your doctor first" (1.4.1): small, always next to Continue on S06.
struct DoctorNote: View {
    var body: some View {
        Label("If you have a heart condition, recent surgery or you've been told to limit exercise, check with your doctor first.",
              systemImage: "stethoscope")
            .typeRole(.caption)
            .foregroundStyle(Palette.text)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
