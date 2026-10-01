import SwiftUI
import GentleWalkCore

/// S07 "Your plan is ready": one plan card (length, her week, limits, Day 1), why it will work with
/// the first journey, and the daily moment. No fake "Creating your plan 98%". "When would you like to
/// start?" was removed (owner 30/09/2026): it did nothing, and the first walk follows right away.
/// Kept to about one screen: the Continue button is pinned by the container (review I16).
struct PlanReadyView: View {
    @Bindable var flow: OnboardingFlow
    var showsContinue = true

    var body: some View {
        let profile = flow.profile
        VStack(alignment: .leading, spacing: 14) {
            if let name = profile.displayName {
                ScreenHeaderText(title: String(localized: "Your plan, \(name)"))
            } else {
                ScreenHeader(title: "Your plan")
            }
            PlanCard(startLevel: profile.startLevel, limits: flow.answers.limits)
            WhyThisWorks(keys: profile.whyKeys)
            DailyMomentPicker(moment: flow.moment, minutes: flow.reminderMinutes,
                              onChoose: flow.chooseMoment, onStep: flow.stepTime(by:), onSet: flow.setTime(minutes:))
            if showsContinue {
                ContinueButton(title: "See my options", action: flow.next)
            }
        }
    }
}

/// Length, rest days and level, the sample week, her limits and Day 1, in one card.
struct PlanCard: View {
    let startLevel: WalkLevel
    let limits: Set<BodyLimit>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("5–10 min a day").typeRole(.cardTitle)
            Text("2 rest days a week · starting \(Text(startLevel.title).bold())").typeRole(.body)
            SampleWeekRow()
            if !limits.isEmpty {
                LimitChips(limits: limits)
            }
            Divider()
            Text("Day 1: first walk · 5 min · seated").typeRole(.body).fontWeight(.semibold)
            FirstJourneyMini()
        }
        .foregroundStyle(Palette.text)
        .cardStyle()
    }
}

/// Her week as it starts (free plan): a walk each weekday, Saturday and Sunday to rest, with the day
/// letters; one line says what Pro adds (clarity review D2: the Pro week looked like her plan). The
/// tiles are not buttons, so they are lower than a touch target.
struct SampleWeekRow: View {
    @Environment(\.dynamicTypeSize) private var typeSize

    private var letters: [String] {
        // Monday first, as the week reads in the plan.
        let symbols = Calendar.current.veryShortStandaloneWeekdaySymbols
        return (0..<7).map { symbols[($0 + 1) % 7] }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Seven tiles do not fit across at accessibility sizes: they wrap into rows (review U2).
            let layout = typeSize.isAccessibilitySize ? AnyLayout(FlowLayout(spacing: 6)) : AnyLayout(HStackLayout(spacing: 6))
            layout {
                ForEach(0..<7, id: \.self) { index in
                    let rest = index >= 5
                    VStack(spacing: 4) {
                        Text(verbatim: letters[index]).typeRole(.caption).fontWeight(.semibold)
                        Image(systemName: rest ? "moon.zzz" : "figure.walk").accessibilityHidden(true)
                    }
                    .foregroundStyle(rest ? Palette.textMuted : Palette.text)
                    .padding(.horizontal, typeSize.isAccessibilitySize ? 12 : 0)
                    .frame(maxWidth: typeSize.isAccessibilitySize ? nil : .infinity, minHeight: 48)
                    .background(rest ? Palette.surface.opacity(0.5) : Palette.surface, in: .rect(cornerRadius: 12))
                }
            }
            Text("With Gentle Walk Pro, your week mixes walks, chair moves and stretches.")
                .typeRole(.caption).foregroundStyle(Palette.textMuted)
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
        VStack(alignment: .leading, spacing: 8) {
            Text("Why this will work for you").typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
            ForEach(Array(keys.enumerated()), id: \.offset) { _, key in
                Label {
                    Text(OnboardingCopy.why(key)).typeRole(.caption)
                } icon: {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Palette.secondary)
                }
                .foregroundStyle(Palette.text)
            }
        }
        .cardStyle()
    }
}

/// The first journey, as the last line of the plan card.
struct FirstJourneyMini: View {
    var body: some View {
        HStack(spacing: 12) {
            ArtImage(name: Art.coverName(journeyID: "jr.ny"), height: 48, fallbackSymbol: "map").frame(width: 60)
            VStack(alignment: .leading, spacing: 2) {
                Text("Your first journey: Central Park to Brooklyn Bridge").typeRole(.caption).fontWeight(.semibold)
                Text("Every walk in the app moves you along.").typeRole(.caption).foregroundStyle(Palette.textMuted)
            }
            .foregroundStyle(Palette.text)
        }
    }
}

/// "What's a good moment for your daily walk?" Four moments as a 2 × 2 grid of tiles and the reminder
/// time on one line (owner 01/10: four full-width cards and a two-line time block made the plan screen
/// long). The time can be typed (tap it), while − / + go to the next quarter hour (owner 30/09/2026).
/// One column at accessibility text sizes.
struct DailyMomentPicker: View {
    let moment: DailyMoment
    let minutes: Int
    let onChoose: (DailyMoment) -> Void
    let onStep: (Int) -> Void
    let onSet: (Int) -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What's a good moment for your daily walk?").typeRole(.cardTitle).foregroundStyle(Palette.text)
            let columns = typeSize.isAccessibilitySize ? [GridItem(.flexible())] : [GridItem(.flexible(), spacing: 8), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(DailyMoment.allCases) { value in
                    MomentTile(title: OnboardingCopy.title(value), isSelected: moment == value) { onChoose(value) }
                }
            }
            HStack(spacing: 10) {
                Text("One gentle reminder a day, at:").typeRole(.caption).foregroundStyle(Palette.textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                StepButton(symbol: "minus", label: "Earlier") { onStep(-1) }
                DatePicker(selection: timeBinding, displayedComponents: .hourAndMinute) {
                    Text("Reminder time")
                }
                .labelsHidden()
                .datePickerStyle(.compact)
                .fixedSize()
                StepButton(symbol: "plus", label: "Later") { onStep(1) }
            }
            .cardStyle(padding: 10)
        }
    }

    /// Minutes after midnight as a time of today, for the picker.
    private var timeBinding: Binding<Date> {
        Binding(
            get: { Calendar.current.startOfDay(for: .now).addingTimeInterval(TimeInterval(minutes * 60)) },
            set: { date in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
                onSet((parts.hour ?? 0) * 60 + (parts.minute ?? 0))
            })
    }

    static func time(_ minutes: Int) -> String {
        let date = Calendar.current.date(bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: .now) ?? .now
        return date.formatted(date: .omitted, time: .shortened)
    }
}

/// A daily moment: a tile with a tick when chosen, two lines at most.
private struct MomentTile: View {
    let title: LocalizedStringResource
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 6) {
                Text(title).typeRole(.body).fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Palette.primary : Palette.textMuted)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(Palette.text)
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
            .background {
                RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
                    .fill(isSelected ? Palette.secondary.opacity(0.12) : Palette.surface)
            }
            .overlay {
                RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
                    .strokeBorder(isSelected ? Palette.primary : Palette.textMuted.opacity(0.3), lineWidth: isSelected ? 3 : 1.5)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
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
