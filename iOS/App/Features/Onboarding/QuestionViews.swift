import SwiftUI
import GentleWalkCore

// The seven onboarding questions (plan 08/10/2026 tasks 2.5–2.9), each on `OnboardingStepScaffold`:
// answers on a notebook page (Claude Design), body choices as drawn cards, the coach's hint and reply
// in the fixed slot under the title.

/// Step 1 "What matters most?": one main goal (owner 08/10/2026).
struct GoalView: View {
    let flow: OnboardingFlow

    var body: some View {
        OnboardingStepScaffold(title: OnboardingCopy.title(.goal), coach: flow.coachLine,
                               blockedReason: flow.continueBlockedReason, onContinue: flow.next) {
            NotebookChoiceList(items: OnboardingCopy.goalOrder, title: OnboardingCopy.title, icon: OnboardingCopy.icon,
                               isSelected: { flow.answers.goals.contains($0) }, onTap: flow.chooseGoal)
        }
    }
}

/// Step 2 "What got in the way before?": any that fit, no judgment; the coach answers the first one.
struct BarriersView: View {
    let flow: OnboardingFlow

    var body: some View {
        OnboardingStepScaffold(title: OnboardingCopy.title(.barriers), coach: flow.coachLine, onContinue: flow.next) {
            NotebookChoiceList(items: Barrier.allCases, title: OnboardingCopy.title, icon: OnboardingCopy.icon,
                               isSelected: { flow.answers.barriers.contains($0) }, onTap: flow.toggleBarrier)
        }
    }
}

/// Step 3 "What should we call you?": optional, with Skip under Continue. Once she types, the coach
/// says hello.
struct NameView: View {
    @Bindable var flow: OnboardingFlow
    @FocusState private var focused: Bool

    var body: some View {
        OnboardingStepScaffold(title: OnboardingCopy.title(.name), coach: flow.coachLine, onContinue: flow.next,
                               belowContinue: AnyView(skip)) {
            TextField(text: $flow.nameText, prompt: Text(LocalizedStringResource("name.example", defaultValue: "Margaret",
                                                                                     comment: "Example first name in the empty name field; a common name in each language."))) { Text("Your name") }
                .typeRole(.cardTitle)
                .textContentType(.givenName)
                .submitLabel(.continue)
                .focused($focused)
                .padding(.horizontal, 16)
                .frame(minHeight: Metrics.rowHeight)
                .background { CardPaper() }
                .overlay { RoundedRectangle(cornerRadius: Metrics.cardRadius).strokeBorder(Palette.textMuted.opacity(0.4), lineWidth: 1) }
                .onSubmit(flow.next)
        }
        // The keyboard is up at once, ready for her name (owner 30/09/2026); a short wait lets the
        // step's slide-in finish first. Not in screenshots (the keyboard would cover the buttons).
        .task {
            guard CaptureHookGate.allowsKeyboard else { return }
            try? await Task.sleep(for: .milliseconds(450))
            focused = true
        }
    }

    private var skip: some View {
        Button("Skip") {
            flow.nameText = ""
            flow.next()
        }
        .buttonStyle(TextLinkButtonStyle(role: .body))
        .frame(maxWidth: .infinity, minHeight: 48)
        .padding(.top, -6)
    }
}

/// Step 4 "How active are you now?", kept and used (owner 08/10/2026): "I mostly sit" starts gentle and
/// shorter. A scale, so no icons (icon-va-chong-nham-chan.md §3a).
struct ActivityLevelView: View {
    let flow: OnboardingFlow

    var body: some View {
        OnboardingStepScaffold(title: OnboardingCopy.title(.activity), coach: flow.coachLine,
                               blockedReason: flow.continueBlockedReason, onContinue: flow.next) {
            NotebookChoiceList(items: ActivityAnswer.allCases, title: OnboardingCopy.title,
                               isSelected: { flow.answers.activity == $0 }, onTap: { flow.answers.activity = $0 })
        }
    }
}

/// Step 5: standing up from a chair without hands. A three-step scale, no icons.
struct ChairStrengthView: View {
    let flow: OnboardingFlow

    var body: some View {
        OnboardingStepScaffold(title: OnboardingCopy.title(.chair), coach: flow.coachLine,
                               blockedReason: flow.continueBlockedReason, onContinue: flow.next) {
            NotebookChoiceList(items: ChairAnswer.allCases, title: OnboardingCopy.title,
                               isSelected: { flow.answers.chair == $0 }, onTap: { flow.answers.chair = $0 })
        }
    }
}

/// Step 6 "Any sore spots?": drawn body cards, two columns, "None of these" on its own.
struct SoreSpotsView: View {
    let flow: OnboardingFlow

    var body: some View {
        OnboardingStepScaffold(title: OnboardingCopy.title(.soreSpots), coach: flow.coachLine, onContinue: flow.next) {
            BodyLimitChips(limits: BodyLimitChips.soreSpots, selected: flow.answers.limits, onToggle: flow.toggleLimit,
                           noneChosen: flow.noSoreSpots, onNone: flow.chooseNoSoreSpots)
        }
    }
}

/// Step 7 "Anything else we should know?": the everyday limits, with the doctor note pinned right above
/// Continue so it is always in view (1.4.1, D4).
struct AnythingElseView: View {
    let flow: OnboardingFlow

    var body: some View {
        OnboardingStepScaffold(title: OnboardingCopy.title(.anythingElse), coach: flow.coachLine,
                               onContinue: flow.next) {
            BodyLimitChips(limits: BodyLimitChips.everyday, selected: flow.answers.limits, onToggle: flow.toggleLimit,
                           noneChosen: flow.noOtherLimits, onNone: flow.chooseNoOtherLimits)
        } aboveContinue: {
            DoctorNote()
        }
    }
}
