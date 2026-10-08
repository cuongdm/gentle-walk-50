import SwiftUI
import GentleWalkCore

/// The upright chair and stretch players' frame: End · position · Sound, the move bar, the clip, the
/// move's details in a scroll area, the spoken line, Back · Pause · Skip, and Break · This hurts.
/// The controls and the safety row are never squeezed; the details scroll instead. On an iPhone SE the
/// clip is held smaller so the details keep room, and at the largest text sizes the position, the move
/// bar and the spoken line move into the scroll area, so nothing is cut to "…" (review C, 09/10/2026).
struct MovePlayerPortrait<Video: View, Details: View>: View {
    /// "Move 4 of 5", "Stretch 2 of 4".
    let position: String?
    var positionWeight: Font.Weight = .regular
    let progress: SessionTimeline.MoveProgress?
    let next: String?
    let caption: String?
    let captionStyle: CaptionBar.Style
    let isPaused: Bool
    let onEnd: () -> Void
    let onSound: () -> Void
    let onBack: () -> Void
    let onPause: () -> Void
    let onSkip: () -> Void
    let onBreak: () -> Void
    let onHurts: () -> Void
    /// The clip, given the tallest it may be (nil: as tall as its width allows).
    @ViewBuilder let video: (_ maxHeight: CGFloat?) -> Video
    @ViewBuilder let details: () -> Details

    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var height: CGFloat = 800

    private var isLargeText: Bool { typeSize.isAccessibilitySize }

    private var clipMaxHeight: CGFloat? {
        if isLargeText { return 120 }
        return isCompact ? 112 : nil
    }

    private var isCompact: Bool { height < PlayerChrome.compactHeight }

    var body: some View {
        VStack(spacing: isCompact ? 8 : 10) {
            HStack {
                EndSessionButton(action: onEnd)
                Spacer()
                if !isLargeText, let position { positionText(position) }
                SoundButton(action: onSound).dynamicTypeSize(...PlayerChrome.typeLimit)
            }
            if !isLargeText, let progress {
                MoveProgressHeader(progress: progress, next: next)
            }
            video(clipMaxHeight)
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    // Largest sizes: the move, its clock and the spoken line first; where it sits in the
                    // set after them.
                    details()
                    if isLargeText {
                        CaptionBar(caption: caption, style: captionStyle)
                        if let position { positionText(position) }
                        if let progress { MoveProgressHeader(progress: progress, next: next) }
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            // The spoken line stays in view above the controls, as plain text (review U3).
            if !isLargeText { CaptionBar(caption: caption, style: captionStyle) }
            PlayerControlRow(isPaused: isPaused, onBack: onBack, onPause: onPause, onSkip: onSkip,
                             pauseSize: isCompact ? 64 : 76)
            WorkoutSafetyBar(showsVoice: false, onBreak: onBreak, onHurts: onHurts)
        }
        .padding(.horizontal, Metrics.screenMargin)
        .padding(.bottom, 8)
        .readableColumn()
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height = $0 }
        .screenBackground()
    }

    private func positionText(_ text: String) -> some View {
        Text(verbatim: text).typeRole(.caption).fontWeight(positionWeight).foregroundStyle(Palette.text)
            .fixedSize(horizontal: false, vertical: true)
    }
}
