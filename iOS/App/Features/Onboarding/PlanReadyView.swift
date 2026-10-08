import SwiftUI
import GentleWalkCore

/// S07 "Your plan" (Claude Design "Your plan", plan 08/10/2026 task 2.10): made from her answers, in one
/// screen on an iPhone SE: her main goal in a line, the 12 weeks in one card (minutes, her week, where
/// she starts, her limits), Day 1 in its own card with "Hear your coach · 10 seconds" (the real first
/// lines), and two "why" lines. No fake "Creating your plan 98%". "See my options" is pinned.
struct PlanReadyView: View {
    @Bindable var flow: OnboardingFlow
    let voiceSource: VoiceSource
    let voiceLines: [VoiceLine]
    /// Screenshots of the playing state (`onboarding-plan-coach`).
    var playsCoachOnAppear = false

    @State private var preview: CoachPreviewPlayer?
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        let profile = flow.profile
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Group {
                        if let name = profile.displayName {
                            Text("Your plan, \(name)")
                        } else {
                            Text("Your plan")
                        }
                    }
                    .typeRole(.screenTitle)
                    .foregroundStyle(Palette.text)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                    // Her main goal said back: the plan is made from her answers.
                    Text(OnboardingCopy.planLine(profile.primaryGoal))
                        .typeRole(.body).foregroundStyle(Palette.textMuted)
                }
                PlanCard(startLevel: profile.startLevel, limits: flow.answers.limits).reveal(delay: 0.05)
                DayOneCard(preview: preview).reveal(delay: 0.35)
                WhyThisWorks(keys: profile.whyKeys).reveal(delay: 0.6)
                if typeSize.isAccessibilitySize { seeOptions }
            }
            .padding(.horizontal, Metrics.screenMargin)
            .padding(.bottom, 16)
            .readableColumn()
        }
        .scrollBounceBehavior(.basedOnSize)
        .pinnedActions(!typeSize.isAccessibilitySize) { seeOptions }
        .onAppear {
            if preview == nil { preview = CoachPreviewPlayer(voiceSource: voiceSource, lines: voiceLines) }
            if playsCoachOnAppear { preview?.play() }
        }
        // Leaving the screen (Back, or on to the paywall) stops the coach.
        .onDisappear { preview?.stop() }
    }

    private var seeOptions: some View {
        ContinueButton(title: "See my options", action: flow.next)
    }
}

/// The 12 weeks: minutes a day, her week (a walk each weekday, Saturday and Sunday to rest), where she
/// starts and the limits she gave.
struct PlanCard: View {
    let startLevel: WalkLevel
    let limits: Set<BodyLimit>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline) { weeks; Spacer(minLength: 8); minutes }
                VStack(alignment: .leading, spacing: 2) { weeks; minutes }
            }
            SampleWeekRow()
            // Where she starts and her limits, as one line (two at most on an iPhone SE).
            Group {
                if limitsLine.isEmpty {
                    Text("Starts \(Text(startLevel.title).bold())")
                } else {
                    Text("Starts \(Text(startLevel.title).bold())\u{00A0}· \(limitsLine)")
                }
            }
            .typeRole(.caption)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(Palette.text)
        .cardStyle(padding: 14)
    }

    /// "Easy on knees · No floor moves" in the plan's order; empty without limits.
    private var limitsLine: String {
        OnboardingCopy.limitOrder.filter(limits.contains).map { String(localized: OnboardingCopy.summary($0)) }
            // A no-break space keeps each "·" at the end of a line, never at the start of the next.
            .joined(separator: "\u{00A0}· ")
    }

    private var weeks: some View {
        Text("12 weeks").font(.system(.title2, design: .serif, weight: .bold))
    }

    private var minutes: some View {
        Text("5–10 min a day").typeRole(.body)
    }
}

/// Day 1, the one thing she does next: the first walk, and the coach she will hear. Outlined in green
/// with a "Day 1" tab on its top edge; the card itself is not a button.
struct DayOneCard: View {
    let preview: CoachPreviewPlayer?
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                if !typeSize.isAccessibilitySize {
                    ArtImage(art: .walkerSeatedMarch, height: 48, fallbackSymbol: "figure.seated.side").frame(width: 48)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your first walk · \(5) min").typeRole(.body).fontWeight(.semibold)
                    Text("Seated · march in your chair").typeRole(.caption).foregroundStyle(Palette.textMuted)
                }
            }
            .accessibilityElement(children: .combine)
            if let preview { HearCoachButton(preview: preview) }
        }
        .padding(.top, 4)
        .foregroundStyle(Palette.text)
        .cardStyle(padding: 10)
        .overlay {
            RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
                .strokeBorder(Palette.primary, lineWidth: 2)
        }
        .overlay(alignment: .topLeading) {
            Text("Day 1")
                .typeRole(.caption).fontWeight(.bold)
                .foregroundStyle(Palette.onStrongFill)
                .padding(.horizontal, 12)
                .padding(.vertical, 2)
                .background(Palette.primary, in: .capsule)
                .padding(.leading, 16)
                .alignmentGuide(.top) { $0.height / 2 }
                .accessibilityHidden(true)
        }
        .padding(.top, 10)
    }
}

/// "Hear your coach · 10 s": a play button in the card; "Stop" while it plays, "Play again" after.
struct HearCoachButton: View {
    let preview: CoachPreviewPlayer

    private var isPlaying: Bool { preview.state == .playing || preview.state == .loading }

    var body: some View {
        Button(action: preview.toggle) {
            HStack(spacing: 12) {
                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Palette.onStrongFill)
                    .frame(width: 36, height: 36)
                    .background(Palette.primary, in: .circle)
                    .contentTransition(.symbolEffect(.replace))
                Text(label).typeRole(.body).fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if !isPlaying {
                    Text("10 s").typeRole(.caption).foregroundStyle(Palette.textMuted)
                } else {
                    VoiceWave()
                }
            }
            .foregroundStyle(Palette.text)
            .padding(.horizontal, 10)
            .frame(minHeight: Metrics.minTouchTarget)
            .background(Palette.sun.opacity(0.14), in: .rect(cornerRadius: Metrics.buttonRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Metrics.buttonRadius, style: .continuous)
                    .strokeBorder(Palette.textMuted.opacity(0.35), lineWidth: 1.5)
            }
            .contentShape(.rect(cornerRadius: Metrics.buttonRadius))
        }
        .buttonStyle(PressableCardStyle())
        .sensoryFeedback(.selection, trigger: isPlaying)
        .accessibilityLabel(Text(isPlaying ? "Stop the coach" : "Hear your coach, 10 seconds"))
    }

    private var label: LocalizedStringResource {
        switch preview.state {
        case .loading, .playing: "Stop"
        case .finished: "Play again"
        case .idle: "Hear your coach"
        }
    }
}

/// Five soft bars that rise and fall while the coach speaks (still with Reduce Motion).
private struct VoiceWave: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var up = false

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { index in
                Capsule().fill(Palette.secondary)
                    .frame(width: 3, height: up ? [10, 18, 14, 20, 9][index] : [16, 8, 20, 10, 14][index])
            }
        }
        .frame(height: 22)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.45).repeatForever(autoreverses: true), value: up)
        .onAppear { up = true }
        .accessibilityHidden(true)
    }
}

/// Her week as it starts (free plan): a walk each weekday, Saturday and Sunday to rest, with the day
/// letters over a small icon each.
struct SampleWeekRow: View {
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.colorScheme) private var scheme

    private var letters: [String] {
        // Monday first, as the week reads in the plan.
        let symbols = Calendar.current.veryShortStandaloneWeekdaySymbols
        return (0..<7).map { symbols[($0 + 1) % 7] }
    }

    var body: some View {
        // Seven days do not fit across at accessibility sizes: they wrap into rows (review U2).
        let layout = typeSize.isAccessibilitySize ? AnyLayout(FlowLayout(spacing: 10)) : AnyLayout(HStackLayout(spacing: 0))
        layout {
            ForEach(0..<7, id: \.self) { index in
                let rest = index >= 5
                VStack(spacing: 3) {
                    Text(verbatim: letters[index]).typeRole(.caption).fontWeight(.semibold)
                    (rest ? AppIcon.rest : AppIcon.walk).image
                        .resizable().scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(rest ? Palette.sky : ChoiceInk.glyph(scheme))
                }
                .foregroundStyle(rest ? Palette.textMuted : Palette.text)
                .frame(maxWidth: typeSize.isAccessibilitySize ? nil : .infinity)
                .reveal(.pop, delay: 0.15 + 0.06 * Double(index))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("A walk each weekday. Saturday and Sunday are rest days."))
    }
}

struct LimitChips: View {
    let limits: Set<BodyLimit>

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(OnboardingCopy.limitOrder.filter(limits.contains), id: \.rawValue) { limit in
                Text(OnboardingCopy.summary(limit))
                    .typeRole(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Palette.text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Palette.textMuted.opacity(0.15), in: .capsule)
            }
        }
    }
}

/// Two "why" lines with a check each, no card (task 2.10).
struct WhyThisWorks: View {
    let keys: [WhyKey]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(keys.enumerated()), id: \.offset) { _, key in
                Label {
                    Text(OnboardingCopy.why(key)).typeRole(.body)
                } icon: {
                    Image(systemName: "checkmark").fontWeight(.bold).foregroundStyle(Palette.secondary)
                }
                .foregroundStyle(Palette.text)
            }
        }
    }
}
