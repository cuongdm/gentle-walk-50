import SwiftUI
import GentleWalkCore

// Me → "Your goal" is a row of `MeView` (her goal's icon and words); it opens this editor. The goal step
// says "You can change it later in Me", and Program finished points here (plan 08/10/2026 task 2.13, D13).

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
