import SwiftUI

/// Full-screen landscape video (task 4.7). Exit and the counter stay; Break and This hurts never
/// hide; Back · Pause · Skip hide after 5 seconds and come back with a tap. No double tap, no pinch.
struct FullScreenVideoView: View {
    let fileName: String?
    let counter: String
    let caption: String?
    let isPaused: Bool
    let onExit: () -> Void
    let onBack: () -> Void
    let onPause: () -> Void
    let onSkip: () -> Void
    let onBreak: () -> Void
    let onHurts: () -> Void

    @State private var controlsVisible = true
    @State private var hideTask: Task<Void, Never>?
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOver
    @Environment(\.accessibilitySwitchControlEnabled) private var switchControl
    /// VoiceOver and Switch Control users cannot find a hidden control: it never hides for them (review I13).
    private var keepsControls: Bool { voiceOver || switchControl }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ExerciseVideo(fileName: fileName)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(.rect)
                .onTapGesture { showControls() }
                .accessibilityElement()
                .accessibilityLabel(Text("Exercise video"))
                .accessibilityHint(Text("Shows the playback buttons"))
                .accessibilityAddTraits(.isButton)
                .accessibilityAction { showControls() }
            VStack {
                HStack(alignment: .top) {
                    Button(action: onExit) {
                        Label("Exit full screen", systemImage: "arrow.down.right.and.arrow.up.left")
                            .typeRole(.body).fontWeight(.semibold)
                            .foregroundStyle(Palette.text)
                            .padding(.horizontal, 16)
                            .frame(minHeight: Metrics.minTouchTarget)
                            .background(Palette.surface.opacity(0.92), in: .capsule)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Text(verbatim: counter)
                        .typeRole(.stat)
                        .foregroundStyle(Palette.text)
                        .padding(.horizontal, 16)
                        .background(Palette.surface.opacity(0.92), in: .rect(cornerRadius: 16))
                }
                Spacer()
                if controlsVisible || keepsControls {
                    PlayerControlRow(isPaused: isPaused, onBack: onBack, onPause: onPause, onSkip: onSkip)
                        .padding(8)
                        .background(Palette.surface.opacity(0.92), in: .rect(cornerRadius: 20))
                        .frame(maxWidth: 420)
                        .transition(.opacity)
                }
                if verticalSizeClass == .compact {
                    // Landscape: caption along the bottom, Break and This hurts at the bottom right.
                    HStack(alignment: .bottom, spacing: 16) {
                        CaptionBar(caption: caption)
                        WorkoutSafetyBar(showsVoice: false, onBreak: onBreak, onHurts: onHurts)
                            .frame(width: 260)
                    }
                } else {
                    VStack(spacing: 12) {
                        CaptionBar(caption: caption)
                        WorkoutSafetyBar(showsVoice: false, onBreak: onBreak, onHurts: onHurts)
                    }
                }
            }
            .padding(Metrics.screenMargin)
        }
        .animation(.easeInOut(duration: 0.25), value: controlsVisible)
        .onAppear { scheduleHide() }
        .onDisappear { hideTask?.cancel() }
    }

    private func showControls() {
        controlsVisible = true
        scheduleHide()
    }

    private func scheduleHide() {
        hideTask?.cancel()
        guard !keepsControls else { return }
        hideTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(5))
            guard !Task.isCancelled else { return }
            controlsVisible = false
        }
    }
}
