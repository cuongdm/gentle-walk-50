import SwiftUI
import GentleWalkCore

/// The self-check cover: one screen per step (design screens 5 and 6).
struct SelfCheckFlowView: View {
    let model: SelfCheckFlowModel
    let onNotToday: () -> Void
    let onSave: () -> Void
    let onClose: () -> Void

    var body: some View {
        Group {
            switch model.step {
            case .intro:
                SelfCheckIntroView(onReady: model.ready, onNotToday: {
                    model.close()
                    onNotToday()
                })
            case .timer:
                SelfCheckTimerView(model: model)
            case .count:
                SelfCheckCountView(model: model, onSave: onSave)
            case .stopped:
                SelfCheckStoppedView(onClose: onClose)
            case .saved(let delta):
                SelfCheckSavedView(count: model.count, line: SelfCheckFlowModel.deltaLine(delta, isFirst: model.history.isEmpty),
                                   onClose: onClose)
            }
        }
        .onDisappear { model.close() }
    }
}

/// The fixed lines of every self-check screen (Task 1.3, docs/design/steady-claims.md).
struct SelfCheckDisclaimer: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("This is not a medical test.")
            Text("You compare only with yourself.")
        }
        .typeRole(.caption)
        .foregroundStyle(Palette.textMuted)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Before the 30 seconds: four safety points, the three steps, "I'm ready" and "Not today" (task 4.6).
struct SelfCheckIntroView: View {
    let onReady: () -> Void
    let onNotToday: () -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        ScrollView {
            // How it works first, then four short safety points, all above the pinned "I'm ready" on
            // an iPhone SE (plan 08/10/2026 task 1.7).
            VStack(alignment: .leading, spacing: 10) {
                ScreenHeader(title: "Your 2-week check")
                HStack(alignment: .center, spacing: 12) {
                    Text("How many times can you stand up from your chair in 30 seconds?")
                        .typeRole(.body).foregroundStyle(Palette.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if !typeSize.isAccessibilitySize {
                        ArtImage(art: .walkerSeatedMarch, height: 84, fallbackSymbol: "chair.fill").frame(width: 84)
                    }
                }
                // One card: the three steps, then the four safety points.
                VStack(alignment: .leading, spacing: 4) {
                    Text("How it works").typeRole(.cardTitle)
                    Text("1. Stand up fully, then sit down.")
                    Text("2. Keep going for 30 seconds.")
                    Text("3. Count each time you stand.")
                    Divider().padding(.vertical, 6)
                    Text("Before you start").typeRole(.cardTitle)
                    SafetyPoint(symbol: "chair.fill", text: "Sturdy chair, no wheels, by a wall")
                    SafetyPoint(symbol: "shoeprints.fill", text: "Sit near the front, feet flat")
                    SafetyPoint(symbol: "hand.raised.fill", text: "Cross arms or push up, both fine")
                    SafetyPoint(symbol: "exclamationmark.circle.fill", text: "Stop if it hurts or you feel dizzy")
                }
                .typeRole(.body)
                .foregroundStyle(Palette.text)
                .cardStyle(padding: 12)
                SelfCheckDisclaimer()
                if typeSize.isAccessibilitySize { actions }
            }
            .padding(.horizontal, Metrics.screenMargin)
            .padding(.top, 8)
            .padding(.bottom, Metrics.screenMargin)
            .readableColumn()
        }
        .pinnedActions(!typeSize.isAccessibilitySize) { actions }
        .screenBackground()
    }

    @ViewBuilder private var actions: some View {
        Button("I'm ready", action: onReady).buttonStyle(.primaryAction)
        Button("Not today", action: onNotToday).buttonStyle(.textLink).frame(maxWidth: .infinity)
    }
}

private struct SafetyPoint: View {
    let symbol: String
    let text: LocalizedStringResource

    var body: some View {
        Label { Text(text).typeRole(.body) } icon: {
            Image(systemName: symbol).foregroundStyle(Palette.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

/// The 30 seconds: a large clock, "Stop early" and This hurts always in view (task 4.8). The clock is
/// worked out from the start time each tick; nothing animates (Reduce Motion needs no change).
struct SelfCheckTimerView: View {
    let model: SelfCheckFlowModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 0)
            TimelineView(.periodic(from: .now, by: 0.25)) { context in
                SelfCheckClock(phase: model.timerPhase(at: context.date))
            }
            Spacer(minLength: 0)
            VStack(spacing: Metrics.touchSpacing) {
                Button("Stop early", action: model.stopEarly).buttonStyle(.secondaryAction)
                Button("This hurts", action: model.hurts).buttonStyle(.dangerAction)
            }
            SelfCheckDisclaimer()
        }
        .padding(Metrics.screenMargin)
        .readableColumn()
        .screenBackground()
        // Waits for the end of the 30 seconds once the audio has started (a new start restarts the wait).
        .task(id: model.startedAt) {
            guard let ends = model.timerEnds else { return }
            try? await Task.sleep(for: .seconds(max(0, ends.timeIntervalSinceNow)))
            if !Task.isCancelled { model.timerFinished() }
        }
    }
}

/// "Get ready", 3-2-1, then the seconds left and "Stand up and sit down".
private struct SelfCheckClock: View {
    let phase: SelfCheckFlowModel.TimerPhase

    var body: some View {
        VStack(spacing: 12) {
            Text(verbatim: big)
                .typeRole(.timer)
                .monospacedDigit()
                .foregroundStyle(Palette.text)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            Text(verbatim: caption).typeRole(.cardTitle).foregroundStyle(Palette.text).multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var big: String {
        switch phase {
        case .getReady(0): "0:30"
        case .getReady(let n): "\(n)"
        case .counting(let left): Duration.seconds(left).formatted(.time(pattern: .minuteSecond))
        case .done: "0:00"
        }
    }

    private var caption: String {
        switch phase {
        case .getReady(0): String(localized: "Get ready")
        case .getReady: String(localized: "Starting in")
        case .counting: String(localized: "Stand up and sit down, at your own pace")
        case .done: String(localized: "Stop")
        }
    }
}

/// Her count: − and + of 72 pt around a large number, hands or not, "Last time", Save (task 4.9).
struct SelfCheckCountView: View {
    let model: SelfCheckFlowModel
    let onSave: () -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ScreenHeader(title: "How many times did you stand up?")
                CountStepper(count: model.count, onMinus: model.decrement, onPlus: model.increment)
                if let last = model.lastTime {
                    Text(verbatim: String(localized: "Last time: \(last)")).typeRole(.body).foregroundStyle(Palette.text)
                        .frame(maxWidth: .infinity)
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("Did you push up with your hands?").typeRole(.cardTitle).foregroundStyle(Palette.text)
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 8) { handsOptions }
                        VStack(spacing: 8) { handsOptions }
                    }
                    Text("We only compare checks done the same way.").typeRole(.caption).foregroundStyle(Palette.textMuted)
                }
                SelfCheckDisclaimer()
                if typeSize.isAccessibilitySize { actions }
            }
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        .pinnedActions(!typeSize.isAccessibilitySize) { actions }
        .screenBackground()
    }

    @ViewBuilder private var handsOptions: some View {
        option(true, "Yes, with my hands")
        option(false, "No, without my hands")
    }

    private func option(_ value: Bool, _ title: LocalizedStringResource) -> some View {
        let isOn = model.usedHands == value
        // One line side by side; at accessibility sizes stacked and free to wrap ("Yes, with my han…" was cut).
        return Button { model.setUsedHands(value) } label: { Text(title).multilineTextAlignment(.center) }
            .buttonStyle(PillButtonStyle(isSelected: isOn, fills: !typeSize.isAccessibilitySize))
            .frame(maxWidth: typeSize.isAccessibilitySize ? .infinity : nil)
            .accessibilityAddTraits(isOn ? .isSelected : [])
    }

    @ViewBuilder private var actions: some View {
        Button("Save", action: onSave).buttonStyle(.primaryAction).disabled(!model.canSave)
        Button("Do the 30 seconds again", action: model.again).buttonStyle(.textLink).frame(maxWidth: .infinity)
    }
}

/// − 8 + : big round buttons either side of the number; VoiceOver reads it as an adjustable value.
private struct CountStepper: View {
    let count: Int
    let onMinus: () -> Void
    let onPlus: () -> Void

    @ScaledMetric(relativeTo: .largeTitle) private var scaled: CGFloat = 72
    /// 72 pt, growing with the text size up to 88 pt: larger, − n + was wider than the screen.
    private var size: CGFloat { min(scaled, 88) }

    var body: some View {
        HStack(spacing: 16) {
            round("minus", label: "One less", action: onMinus)
            Text(verbatim: "\(count)").typeRole(.timer).monospacedDigit().foregroundStyle(Palette.text)
                .lineLimit(1).minimumScaleFactor(0.5)
                .frame(minWidth: size * 1.2)
            round("plus", label: "One more", action: onPlus)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Times you stood up"))
        .accessibilityValue(Text(verbatim: "\(count)"))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: onPlus()
            case .decrement: onMinus()
            @unknown default: break
            }
        }
    }

    private func round(_ symbol: String, label: LocalizedStringResource, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundStyle(Palette.onStrongFill)
                .frame(width: size, height: size)
                .background(Palette.primary, in: .circle)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
    }
}

/// This hurts during the check: nothing saved, said calmly.
struct SelfCheckStoppedView: View {
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            ArtImage(art: .walkerRest, height: 180).frame(maxWidth: 220).accessibilityHidden(true)
            VStack(spacing: 8) {
                Text("Good call to stop.").typeRole(.screenTitle).foregroundStyle(Palette.text).accessibilityAddTraits(.isHeader)
                Text("Nothing was saved. Rest now, and try another day if you feel like it.")
                    .typeRole(.body).foregroundStyle(Palette.text).multilineTextAlignment(.center)
            }
            Spacer()
            Button("Close", action: onClose).buttonStyle(.primaryAction)
        }
        .padding(Metrics.screenMargin)
        .readableColumn()
        .screenBackground()
    }
}

/// Saved: her number and how it compares with her own first check (never with anyone else).
struct SelfCheckSavedView: View {
    let count: Int
    let line: String
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            ArtImage(art: .walkerCelebrate, height: 180).frame(maxWidth: 220).accessibilityHidden(true)
            VStack(spacing: 8) {
                Text(verbatim: String(localized: "Saved: \(count)")).typeRole(.screenTitle).foregroundStyle(Palette.text)
                    .accessibilityAddTraits(.isHeader)
                if !line.isEmpty {
                    Text(verbatim: line).typeRole(.body).foregroundStyle(Palette.text).multilineTextAlignment(.center)
                }
                Text("You'll find it on Progress.").typeRole(.body).foregroundStyle(Palette.textMuted)
            }
            Spacer()
            SelfCheckDisclaimer()
            Button("Done", action: onClose).buttonStyle(.primaryAction)
        }
        .padding(Metrics.screenMargin)
        .readableColumn()
        .screenBackground()
    }
}
