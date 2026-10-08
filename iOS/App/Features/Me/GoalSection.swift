import SwiftUI
import GentleWalkCore

/// Me → "Your goal": her one main goal, changeable at any time (plan 08/10/2026 task 2.13; the goal
/// step says "You can change it later in Me", and Program finished points here, D13).
struct GoalSection: View {
    let goal: Goal
    let onChange: () -> Void

    var body: some View {
        SettingsCard(title: "Your goal", actionTitle: "Change", action: onChange) {
            HStack(spacing: 12) {
                AppIconChip(icon: OnboardingCopy.icon(goal))
                Text(OnboardingCopy.title(goal)).typeRole(.body)
            }
            .accessibilityElement(children: .combine)
        }
    }
}

/// The goal list from onboarding, in a sheet; Save keeps the new one.
struct GoalEditor: View {
    @State var goal: Goal
    let onSave: (Goal) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(title: OnboardingCopy.title(.goal), subtitle: "Pick the one that matters most.")
                NotebookChoiceList(items: OnboardingCopy.goalOrder, title: OnboardingCopy.title, icon: OnboardingCopy.icon,
                                   isSelected: { $0 == goal }, onTap: { goal = $0 })
                Button("Save") {
                    onSave(goal)
                    dismiss()
                }
                .buttonStyle(.primaryAction)
            }
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        .screenBackground()
    }
}
