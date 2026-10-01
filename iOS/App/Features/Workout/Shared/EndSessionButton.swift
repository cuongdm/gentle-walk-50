import SwiftUI

/// "✕ End" at the top left of every player: a small bordered capsule, so it reads as the way out at a
/// glance (it was an underlined word), without competing with Pause, Break or This hurts. Not red:
/// red is This hurts. The touch area is 56 pt; "End this session?" still asks before anything ends
/// (owner 01/10/2026).
struct EndSessionButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("End", systemImage: "xmark")
                .typeRole(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Palette.text)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Palette.surface, in: .capsule)
                .overlay { Capsule().strokeBorder(Palette.textMuted.opacity(0.45), lineWidth: 1.5) }
                .frame(minHeight: Metrics.minTouchTarget)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("End session"))
    }
}
