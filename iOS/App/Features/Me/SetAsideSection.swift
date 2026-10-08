import SwiftUI

/// "Moves set aside" in Me → Your plan (P3, plan 4.5): moves that hurt twice in four weeks rest for four
/// weeks; each one comes back by itself on its day, or now with "Bring it back".
struct SetAsideSection: View {
    let moves: [SetAsideMove]
    let onBringBack: (String) -> Void

    var body: some View {
        SettingsCard(title: "Moves set aside") {
            ForEach(moves) { move in
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .center, spacing: 12) { label(move); Spacer(minLength: 8); button(move).fixedSize() }
                    // Stacked (large text): the pill may wrap; a fixed size pushed the whole screen past its margins.
                    VStack(alignment: .leading, spacing: 8) { label(move); button(move) }
                }
            }
        }
    }

    private func label(_ move: SetAsideMove) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: move.name).typeRole(.body).fontWeight(.semibold)
            Text("Back on \(move.back.formatted(.dateTime.month(.abbreviated).day()))")
                .typeRole(.caption).foregroundStyle(Palette.textMuted)
        }
        .accessibilityElement(children: .combine)
    }

    private func button(_ move: SetAsideMove) -> some View {
        Button("Bring it back") { onBringBack(move.id) }
            .buttonStyle(PillButtonStyle())
    }
}
