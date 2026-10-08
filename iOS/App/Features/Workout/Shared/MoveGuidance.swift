import SwiftUI
import GentleWalkCore

/// One segment per move of the block, filled as each is done (competitor idea 2, 30/09/2026), with
/// "Next: Seated knee lift" under it (idea 1). Read from the timeline, so Back and Skip update it.
struct MoveProgressHeader: View {
    let progress: SessionTimeline.MoveProgress
    /// The move after this one; nil on the last move.
    let next: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            SegmentedMoveBar(progress: progress)
            Text(verbatim: next.map { String(localized: "Next: \($0)") } ?? String(localized: "Last move"))
                .typeRole(.caption).fontWeight(.semibold)
                .foregroundStyle(Palette.textMuted)
                .lineLimit(2)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(accessibilityText))
    }

    private var accessibilityText: String {
        let position = String(localized: "Move \(min(progress.index + 1, progress.count)) of \(progress.count)")
        guard let next else { return position + ", " + String(localized: "Last move") }
        return position + ", " + String(localized: "Next: \(next)")
    }
}

/// The name for "Next: …": the move after `index`, or "<name>, once more" when the same move comes
/// round again (a stretch set repeats a pose back to back; review M5, 02/10/2026). Nil on the last.
enum FollowingMove {
    static func label(ids: [String?], index: Int, name: (String) -> String?) -> String? {
        let after = index + 1
        guard ids.indices.contains(after), let id = ids[after], let next = name(id) else { return nil }
        let current = ids.indices.contains(index) ? ids[index] : nil
        return current == id ? String(localized: "\(next), once more") : next
    }
}

struct SegmentedMoveBar: View {
    let progress: SessionTimeline.MoveProgress

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<progress.count, id: \.self) { index in
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Palette.secondary.opacity(0.22))
                        Capsule().fill(Palette.secondary).frame(width: proxy.size.width * fill(index))
                    }
                }
                .frame(height: 8)
            }
        }
        .animation(.linear(duration: 0.25), value: progress)
    }

    private func fill(_ index: Int) -> Double {
        if index < progress.index { return 1 }
        if index == progress.index { return progress.fraction }
        return 0
    }
}

/// "One hand on the chair" on a sky label and "2 × 8" beside it: today's step on the support and rep
/// ladders (steady program task 4.11). Dark ink on sky in both appearances ("label on sky" pair).
struct LadderLabels: View {
    let support: LocalizedStringResource?
    let reps: String?

    var body: some View {
        HStack(spacing: 8) {
            if let support {
                Label { Text(support) } icon: { Image(systemName: "hand.raised.fill") }
                    .typeRole(.body).fontWeight(.semibold)
                    .foregroundStyle(Palette.onLightFill)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Palette.sky, in: .capsule)
            }
            if let reps {
                Text(verbatim: reps)
                    .typeRole(.body).fontWeight(.semibold)
                    .foregroundStyle(Palette.onLightFill)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Palette.sky, in: .capsule)
                    .accessibilityLabel(Text(verbatim: String(localized: "Today: \(reps)")))
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// Speaker button opening the Sound sheet (56 pt target).
struct SoundButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "speaker.wave.2")
                .typeRole(.body).fontWeight(.semibold)
                .foregroundStyle(Palette.text)
                .frame(width: Metrics.minTouchTarget, height: Metrics.minTouchTarget)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Sound"))
    }
}

/// "Watch on your TV" in three steps with the phone's Screen Mirroring (competitor idea 3).
struct WatchOnTVSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ClosableHeader(title: String(localized: "Watch on your TV"),
                               subtitle: String(localized: "Works with a TV that supports AirPlay. The coach's voice plays on the TV too."),
                               onClose: { dismiss() })
                TVStep(number: 1, symbol: "hand.draw", text: "Swipe down from the top-right corner of your phone.")
                TVStep(number: 2, symbol: "rectangle.on.rectangle", text: "Tap Screen Mirroring: the two overlapping rectangles.")
                TVStep(number: 3, symbol: "tv", text: "Choose your TV, then turn your phone on its side.")
                Button("Got it") { dismiss() }.buttonStyle(.primaryAction)
            }
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        .screenBackground()
        .presentationDetents([.medium, .large])
    }
}

private struct TVStep: View {
    let number: Int
    let symbol: String
    let text: LocalizedStringResource

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text(verbatim: "\(number)")
                .typeRole(.body).fontWeight(.bold)
                .foregroundStyle(Palette.onStrongFill)
                .frame(width: 36, height: 36)
                .background(Palette.primary, in: .circle)
                .dynamicTypeSize(...DynamicTypeSize.xxLarge)
                .accessibilityHidden(true)
            Text(text).typeRole(.body).foregroundStyle(Palette.text)
            Spacer(minLength: 0)
            Image(systemName: symbol).typeRole(.cardTitle).foregroundStyle(Palette.secondary).accessibilityHidden(true)
        }
        .cardStyle(padding: 14)
        .accessibilityElement(children: .combine)
    }
}
