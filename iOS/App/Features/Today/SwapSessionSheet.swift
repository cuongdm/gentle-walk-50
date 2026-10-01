import SwiftUI

/// "Try something else today": the other kinds and five gentle minutes. Whatever she picks still
/// counts for today (milestone 10).
struct SwapSessionSheet: View {
    let options: [TodaySwapOption]
    let onPick: (TodaySwapOption) -> Void
    /// "See all sessions" at the foot: the full list, for anything not offered here.
    var onSeeAll: (() -> Void)?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ClosableHeader(title: String(localized: "Try something else today"),
                               subtitle: String(localized: "It still counts for today."), onClose: { dismiss() })
                ForEach(options) { option in
                    SessionCard(title: option.title, detail: nil, art: option.art, isLocked: option.isLocked) {
                        onPick(option)
                    }
                }
                if let onSeeAll {
                    Button("See all sessions", action: onSeeAll)
                        .buttonStyle(.secondaryAction)
                        .padding(.top, 4)
                }
            }
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        .screenBackground()
        .presentationDetents([.large])
    }
}
