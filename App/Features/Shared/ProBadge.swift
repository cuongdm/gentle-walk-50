import SwiftUI

/// Marks paid content (2.3.2): a small "Pro" tag with a lock. The card itself is never greyed out.
struct ProBadge: View {
    var body: some View {
        Label("Pro", systemImage: "lock.fill")
            .typeRole(.caption)
            .fontWeight(.bold)
            .foregroundStyle(Palette.onLightFill)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Palette.sun, in: .capsule)
            .accessibilityLabel(Text("Pro, locked"))
    }
}
