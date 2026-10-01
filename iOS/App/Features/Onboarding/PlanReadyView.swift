import SwiftUI
import GentleWalkCore

/// S07 "Your plan is ready": one plan card (length, her week, limits, Day 1) and why it will work.
/// No fake "Creating your plan 98%". "When would you like to start?" was removed (owner 30/09/2026),
/// and the daily moment moved to S16, where the reminder is asked for (owner 01/10/2026), so the
/// plan fits one screen. The Continue button is pinned by the container (review I16).
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
