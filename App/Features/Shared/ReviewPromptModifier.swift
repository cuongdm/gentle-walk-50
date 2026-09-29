import StoreKit
import SwiftUI
import GentleWalkCore

/// Asks for an App Store rating with Apple's own dialog (task 6.11, 5.6.1): only when
/// `ReviewPromptPolicy` allowed a milestone, after Complete has settled, never from a button.
private struct ReviewPromptModifier: ViewModifier {
    let milestone: ReviewMilestone?
    let onAsked: (ReviewMilestone) -> Void
    @Environment(\.requestReview) private var requestReview

    func body(content: Content) -> some View {
        content.task(id: milestone) {
            guard let milestone else { return }
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            requestReview()
            onAsked(milestone)
        }
    }
}

extension View {
    func reviewPrompt(_ milestone: ReviewMilestone?, onAsked: @escaping (ReviewMilestone) -> Void) -> some View {
        modifier(ReviewPromptModifier(milestone: milestone, onAsked: onAsked))
    }
}
