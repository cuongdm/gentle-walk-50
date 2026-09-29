import SwiftUI

/// "▶ Video" on a session that has a filmed coach; sessions without it are voice and pictures,
/// so one mark is enough.
struct VideoBadge: View {
    var body: some View {
        Label("Video", systemImage: "play.fill")
            .typeRole(.caption)
            .fontWeight(.bold)
            .foregroundStyle(Palette.onStrongFill)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Palette.secondary, in: .capsule)
            .accessibilityLabel(Text("With video"))
    }
}
