import SwiftUI
import GentleWalkCore

/// S07 "Your plan is ready": plan card, sample week, limits, why it will work, first journey,
/// Day 1, when to start and the daily moment. No fake "Creating your plan 98%".
struct PlanReadyView: View {
    @Bindable var flow: OnboardingFlow

    var body: some View {
        let profile = flow.profile
        VStack(alignment: .leading, spacing: 18) {
            if let name = profile.displayName {
                ScreenHeaderText(title: String(localized: "Your plan, \(name)"))
            } else {
                ScreenHeader(title: "Your plan")
            }
            PlanCard(startLevel: profile.startLevel)
            SampleWeekRow()
            if !flow.answers.limits.isEmpty {
                LimitChips(limits: flow.answers.limits)
            }
            WhyThisWorks(keys: profile.whyKeys)
            FirstJourneyMini()
            DayOneCard()
            StartTimePicker(choice: $flow.startChoice)
            DailyMomentPicker(moment: flow.moment, minutes: flow.reminderMinutes,
                              onChoose: flow.chooseMoment, onAdjust: flow.adjustTime(byMinutes:))
            ContinueButton(title: "See my options", action: flow.next)
        }
    }
}

struct PlanCard: View {
    let startLevel: WalkLevel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("5–10 min a day").typeRole(.cardTitle)
            Text("2 rest days a week").typeRole(.body)
            Text("Starting level: \(Text(startLevel.title))").typeRole(.body)
            Text("Walks, chair moves and gentle stretches, in turn.").typeRole(.caption).foregroundStyle(Palette.textMuted)
        }
        .foregroundStyle(Palette.text)
        .cardStyle()
    }
}

/// Walk · Stretch · Walk · Chair · Walk · Rest · Rest, labelled as part of Pro (the free plan has
/// a walk every weekday).
struct SampleWeekRow: View {
    private let days: [(LocalizedStringResource, String)] = [
        ("Walk", "figure.walk"), ("Stretch", "figure.flexibility"), ("Walk", "figure.walk"), ("Chair", "chair.fill"),
        ("Walk", "figure.walk"), ("Rest", "moon.zzz"), ("Rest", "moon.zzz"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                ForEach(0..<7, id: \.self) { index in
                    VStack(spacing: 4) {
                        Image(systemName: days[index].1).accessibilityHidden(true)
                        Text(days[index].0).typeRole(.caption).lineLimit(1).minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(Palette.text)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(Palette.surface, in: .rect(cornerRadius: 12))
                }
            }
            Text("With Gentle Walk Pro").typeRole(.caption).foregroundStyle(Palette.textMuted)
        }
        .accessibilityElement(children: .combine)
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

struct WhyThisWorks: View {
    let keys: [WhyKey]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Why this will work for you").typeRole(.cardTitle).foregroundStyle(Palette.text)
            ForEach(Array(keys.enumerated()), id: \.offset) { _, key in
                Label {
                    Text(OnboardingCopy.why(key)).typeRole(.body)
                } icon: {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Palette.secondary)
                }
                .foregroundStyle(Palette.text)
            }
        }
        .cardStyle()
    }
}

struct FirstJourneyMini: View {
    var body: some View {
        HStack(spacing: 14) {
            IllustrationPlaceholder(symbol: "map", tint: Palette.secondary, height: 72).frame(width: 96)
            VStack(alignment: .leading, spacing: 2) {
                Text("Your first journey: Central Park to Brooklyn Bridge").typeRole(.body).fontWeight(.semibold)
                Text("Every walk in the app moves you along.").typeRole(.caption).foregroundStyle(Palette.textMuted)
            }
            .foregroundStyle(Palette.text)
        }
        .cardStyle()
    }
}

struct DayOneCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Day 1").typeRole(.caption).foregroundStyle(Palette.textMuted)
            Text("First walk · 5 min · seated").typeRole(.cardTitle)
            Text("Warm-up march · 2 min").typeRole(.body)
            Text("Easy intervals · 2 min").typeRole(.body)
            Text("Cool-down · 1 min").typeRole(.body)
        }
        .foregroundStyle(Palette.text)
        .cardStyle()
    }
}

/// "When would you like to start?" · Right now (default) · Tomorrow · Pick a time.
struct StartTimePicker: View {
    @Binding var choice: StartChoice

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("When would you like to start?").typeRole(.cardTitle).foregroundStyle(Palette.text)
            FlowLayout(spacing: Metrics.touchSpacing) {
                option(.now, "Right now")
                option(.tomorrow, "Tomorrow")
                option(.pickTime, "Pick a time")
            }
        }
    }

    private func option(_ value: StartChoice, _ title: LocalizedStringResource) -> some View {
        Button { choice = value } label: { Text(title) }
            .buttonStyle(PillButtonStyle(isSelected: choice == value))
            .accessibilityAddTraits(choice == value ? .isSelected : [])
    }
}

/// "What's a good moment for your daily walk?" with a time changed by − / + (no slider).
struct DailyMomentPicker: View {
    let moment: DailyMoment
    let minutes: Int
    let onChoose: (DailyMoment) -> Void
    let onAdjust: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What's a good moment for your daily walk?").typeRole(.cardTitle).foregroundStyle(Palette.text)
            ForEach(DailyMoment.allCases) { value in
                SelectableCard(title: OnboardingCopy.title(value), isSelected: moment == value) { onChoose(value) }
            }
            HStack(spacing: 16) {
                StepButton(symbol: "minus", label: "15 minutes earlier") { onAdjust(-15) }
                Text(verbatim: Self.time(minutes))
                    .typeRole(.cardTitle)
                    .foregroundStyle(Palette.text)
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel(Text("Reminder time \(Self.time(minutes))"))
                StepButton(symbol: "plus", label: "15 minutes later") { onAdjust(15) }
            }
            .cardStyle(padding: 10)
        }
    }

    static func time(_ minutes: Int) -> String {
        let date = Calendar.current.date(bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: .now) ?? .now
        return date.formatted(date: .omitted, time: .shortened)
    }
}

private struct StepButton: View {
    let symbol: String
    let label: LocalizedStringResource
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .typeRole(.cardTitle)
                .foregroundStyle(Palette.onStrongFill)
                .frame(width: 56, height: 56)
                .background(Palette.secondary, in: .circle)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
    }
}
