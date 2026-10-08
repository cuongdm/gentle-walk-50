import SwiftUI
import GentleWalkCore

/// S02 "What would you like from this?" — pick up to 2 (the answers are not all feelings, review D23).
struct GoalView: View {
    let flow: OnboardingFlow

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScreenHeader(title: "What would you like from this?", subtitle: "Pick up to 2.")
            ForEach(Array(Goal.allCases.enumerated()), id: \.element.rawValue) { index, goal in
                SelectableCard(title: OnboardingCopy.title(goal), symbol: OnboardingCopy.symbol(goal),
                               tint: OnboardingCopy.tint(goal), isSelected: flow.answers.goals.contains(goal)) { flow.toggleGoal(goal) }
                    .reveal(delay: 0.05 * Double(index))
            }
            if flow.showsGoalLimit {
                Label("You can pick 2. Tap one to change it.", systemImage: "info.circle")
                    .typeRole(.body).foregroundStyle(Palette.text)
            }
            if let last = flow.answers.goals.last {
                CoachNote(text: OnboardingCopy.note(last))
            }
            ContinueButton(hint: flow.hint, dimmed: flow.answers.goals.isEmpty, action: flow.next)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: flow.answers.goals)
    }
}

/// S03 "What's made it hard before?" — any that fit, no judgment.
struct BarriersView: View {
    let flow: OnboardingFlow

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScreenHeader(title: "What's made it hard before?", subtitle: "Pick any that fit. No judgment.")
            ForEach(Array(Barrier.allCases.enumerated()), id: \.element.rawValue) { index, barrier in
                SelectableCard(title: OnboardingCopy.title(barrier), isSelected: flow.answers.barriers.contains(barrier)) {
                    flow.toggleBarrier(barrier)
                }
                .reveal(delay: 0.05 * Double(index))
            }
            if let first = flow.answers.barriers.first {
                CoachNote(text: OnboardingCopy.note(first))
            }
            ContinueButton(action: flow.next)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: flow.answers.barriers)
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
                .reveal(.rise)
            ScreenHeader(title: copy.title).reveal(delay: 0.2)
            Text(copy.body).typeRole(.body).foregroundStyle(Palette.text).reveal(delay: 0.35)
            Text("Next, a few questions about your day.").typeRole(.body).foregroundStyle(Palette.textMuted)
                .padding(.top, 4)
                .reveal(delay: 0.55)
            if showsContinue { ContinueButton(action: onContinue) }
        }
    }
}

/// S05a "What should we call you?" — optional, with Skip. Once she types, the coach says hello.
struct NameView: View {
    @Bindable var flow: OnboardingFlow
    @FocusState private var focused: Bool

    private var trimmedName: String { flow.nameText.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ScreenHeader(title: "What should we call you?", subtitle: "We use it to say hello. You can skip it.")
            TextField(text: $flow.nameText, prompt: Text(LocalizedStringResource("name.example", defaultValue: "Margaret",
                                                                                     comment: "Example first name in the empty name field; a common name in each language."))) { Text("Your name") }
                .typeRole(.cardTitle)
                .textContentType(.givenName)
                .submitLabel(.continue)
                .focused($focused)
                .padding(.horizontal, 16)
                .frame(minHeight: Metrics.rowHeight)
                .background(Palette.surface, in: .rect(cornerRadius: 16))
                .overlay { RoundedRectangle(cornerRadius: 16).strokeBorder(Palette.textMuted.opacity(0.4), lineWidth: 1) }
                .onSubmit(flow.next)
            if !trimmedName.isEmpty {
                CoachNote(text: "Nice to meet you, \(trimmedName).")
            }
            ContinueButton(action: flow.next)
            Button("Skip") {
                flow.nameText = ""
                flow.next()
            }
            .buttonStyle(.textLink)
            .frame(maxWidth: .infinity)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: trimmedName.isEmpty)
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
            ScreenHeader(title: "How active are you now?", subtitle: "So we start you at a comfortable level.")
            ForEach(Array(ActivityAnswer.allCases.enumerated()), id: \.element.rawValue) { index, answer in
                SelectableCard(title: OnboardingCopy.title(answer), isSelected: flow.answers.activity == answer) {
                    flow.answers.activity = answer
                }
                .reveal(delay: 0.05 * Double(index))
            }
            if flow.answers.activity != nil {
                CoachNote(text: OnboardingCopy.activityNote)
            }
            ContinueButton(hint: flow.hint, dimmed: flow.answers.activity == nil, action: flow.next)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: flow.answers.activity)
    }
}

/// S05c: getting up from a chair without hands.
struct ChairStrengthView: View {
    @Bindable var flow: OnboardingFlow

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ScreenHeader(title: "Getting up from a chair without using your hands is…",
                         subtitle: "It helps us pick your first chair moves.")
            ForEach(Array(ChairAnswer.allCases.enumerated()), id: \.element.rawValue) { index, answer in
                SelectableCard(title: OnboardingCopy.title(answer), isSelected: flow.answers.chair == answer) {
                    flow.answers.chair = answer
                }
                .reveal(delay: 0.05 * Double(index))
            }
            // "Noted." — no score, no comparison (review D24), now in the coach's voice.
            if flow.answers.chair != nil {
                CoachNote(text: OnboardingCopy.chairNote)
            }
            ContinueButton(hint: flow.hint, dimmed: flow.answers.chair == nil, action: flow.next)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: flow.answers.chair)
    }
}

/// S06 "Anything we should go easy on?" — the choices in two short groups (`BodyLimitChips`) and a
/// clear note to check with a doctor (1.4.1), pinned with Continue so it is always in view. The big
/// picture went (owner 01/10: a third of the screen saying nothing); a small figure beside the title
/// now shows the areas she picked (03/10/2026).
struct BodyLimitsView: View {
    let flow: OnboardingFlow
    /// Continue is pinned at the bottom by the container, except at accessibility sizes.
    var showsContinue = true
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                ScreenHeader(title: "Anything we should go easy on?", subtitle: "We'll only show moves that fit.")
                // The chosen areas glow on a small figure (redesign 03/10/2026); hidden at
                // accessibility sizes, where the words need the width.
                if !typeSize.isAccessibilitySize {
                    BodyGlowFigure(limits: flow.answers.limits).frame(width: 70, height: 126)
                }
            }
            BodyLimitChips(selected: flow.answers.limits, onToggle: flow.toggleLimit,
                           noneChosen: flow.noLimitsChosen, onNone: flow.chooseNoLimits)
            if showsContinue {
                DoctorNote()
                ContinueButton(action: flow.next)
            }
        }
    }
}

/// "Check with your doctor first" (1.4.1): small, always next to Continue on S06. 06/10/2026: a fall or
/// fainting in the past year added (PAR-Q+ question 3, World Falls Guidelines 2022). A reminder only:
/// nothing is asked or stored.
struct DoctorNote: View {
    var body: some View {
        Label("If you have a heart condition, recent surgery, a fall or fainting in the past year, or you've been told to limit exercise, check with your doctor first.",
              systemImage: "stethoscope")
            .typeRole(.caption)
            .foregroundStyle(Palette.text)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
