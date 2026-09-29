import SwiftUI
import GentleWalkCore

/// S17 Today: greeting and active days, check-in, today's session (the biggest card), a special
/// card when one applies, journey mini card, the week and Extras.
struct TodayView: View {
    let model: TodayModel
    let actions: TodayActions

    @State private var showsSwap = false
    /// Picked in the swap sheet; started once the sheet has gone, so two covers never overlap.
    @State private var pendingSwap: WorkoutRequest?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                TodayHero(greeting: model.greeting, activeDays: model.activeDays, progress: model.treeProgress)
                if let ends = model.trialEndingDate {
                    TrialEndingCard(date: ends, price: actions.yearlyPrice, onManage: actions.onManagePlan)
                }
                if let welcome = model.welcomeBack {
                    Text(verbatim: welcome).typeRole(.body).foregroundStyle(Palette.text)
                }
                if model.showsCheckIn {
                    CheckInRow(selected: model.checkedIn, onSelect: model.checkIn)
                }
                TodaySessionCard(session: model.session, detail: model.sessionDetail, trialEnded: model.trialEnded,
                                 onStart: { if let request = model.request { actions.onStart(request) } },
                                 onSeePlans: actions.onSeePlans,
                                 onSomethingElse: model.swapOptions.isEmpty ? nil : { showsSwap = true })
                if let card = model.specialCard {
                    SpecialCard(card: card, actions: actions)
                }
                JourneyMiniCard(line: model.journeyLine, progress: model.journeyProgress, journeyID: model.journeyID,
                                onOpen: actions.onOpenJourney)
                WeekStrip(days: model.week, isPro: model.isPro, line: model.weekLine)
                if !model.extras.isEmpty {
                    ExtrasRow(extras: model.extras, isPro: model.isPro, onStart: actions.onStart, onLocked: actions.onSeePlans,
                              onSeeAll: actions.onSeeAllSessions)
                }
            }
            .padding(Metrics.screenMargin)
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .screenBackground()
        .sheet(isPresented: $showsSwap, onDismiss: startPendingSwap) {
            SwapSessionSheet(options: model.swapOptions) { option in
                if option.isLocked {
                    showsSwap = false
                    actions.onSeePlans()
                } else {
                    pendingSwap = option.request
                    showsSwap = false
                }
            }
        }
    }

    private func startPendingSwap() {
        guard let request = pendingSwap else { return }
        pendingSwap = nil
        actions.onStart(request)
    }
}

/// What Today can ask the app to do.
struct TodayActions {
    var yearlyPrice: String?
    var onStart: (WorkoutRequest) -> Void
    var onSeePlans: () -> Void
    var onManagePlan: () -> Void
    var onOpenJourney: () -> Void
    var onSeeAllSessions: () -> Void = {}
    var onConnectHealth: () -> Void
    var onDismissCard: () -> Void
    var onFewerReminders: (Bool) -> Void
}

/// "Good morning, Margaret" with the active-days ring (filling towards the next tree level) beside
/// it, then a big painting of the coach at home.
struct TodayHero: View {
    let greeting: String
    let activeDays: Int
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // The badge sits beside the greeting, never on the painting (it would cover her face).
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: 12) { title; Spacer(minLength: 0); badge }
                VStack(alignment: .leading, spacing: 10) { title; badge }
            }
            // About a fifth of the screen, 190 pt at most, so Start stays in view on an iPhone SE.
            ArtImage.flexible(.sceneLivingRoom, minHeight: 120, maxHeight: 190, fallbackSymbol: "figure.walk")
                .containerRelativeFrame(.vertical, alignment: .top) { height, _ in min(190, max(120, height * 0.22)) }
        }
    }

    private var title: some View {
        Text(verbatim: greeting).typeRole(.screenTitle).foregroundStyle(Palette.text)
            .accessibilityAddTraits(.isHeader)
    }

    private var badge: some View {
        HStack(spacing: 10) {
            ActiveDaysRing(count: activeDays, progress: progress)
            Text(verbatim: Plural.activeDaysLabel(activeDays))
                .typeRole(.body).fontWeight(.semibold)
                .foregroundStyle(Palette.text)
                .fixedSize()
        }
        .padding(.vertical, 8)
        .padding(.leading, 8)
        .padding(.trailing, 14)
        .background(Palette.surface, in: .capsule)
        .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: Plural.activeDays(activeDays)))
    }
}

/// The number of active days inside a ring that fills towards the next tree level.
struct ActiveDaysRing: View {
    let count: Int
    let progress: Double
    @ScaledMetric(relativeTo: .title) private var size: CGFloat = 56

    var body: some View {
        ZStack {
            Circle().stroke(Palette.secondary.opacity(0.2), lineWidth: 7)
            Circle()
                .trim(from: 0, to: max(0.03, min(1, progress)))
                .stroke(Palette.secondary, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(verbatim: "\(count)").typeRole(.cardTitle).fontWeight(.bold)
                .foregroundStyle(Palette.text)
                .minimumScaleFactor(0.6)
        }
        .frame(width: size, height: size)
    }
}

/// "How do your joints feel today?" · Achy · Okay · Great.
struct CheckInRow: View {
    let selected: CheckIn?
    let onSelect: (CheckIn) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How do your joints feel today?").typeRole(.cardTitle).foregroundStyle(Palette.text)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: Metrics.touchSpacing) { buttons }
                VStack(spacing: Metrics.touchSpacing) { buttons }
            }
        }
    }

    @ViewBuilder private var buttons: some View {
        option(.achy, "Achy", Palette.sky)
        option(.okay, "Okay", Palette.surface)
        option(.great, "Great", Palette.sun)
    }

    private func option(_ value: CheckIn, _ title: LocalizedStringResource, _ fill: Color) -> some View {
        Button { onSelect(value) } label: {
            Text(title)
                .typeRole(.body).fontWeight(.bold)
                // Sky and sun stay light in dark mode (dark ink); the plain card follows the theme.
                .foregroundStyle(value == .okay ? Palette.text : Palette.onLightFill)
                .frame(maxWidth: .infinity, minHeight: 64)
                .background(fill, in: .rect(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(selected == value ? Palette.primary : Palette.textMuted.opacity(0.3), lineWidth: selected == value ? 3 : 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected == value ? .isSelected : [])
    }
}

/// Today's session: the biggest card, with Start.
struct TodaySessionCard: View {
    let session: TodaySession
    let detail: String?
    let trialEnded: Bool
    let onStart: () -> Void
    let onSeePlans: () -> Void
    /// "Try something else" (milestone 10); nil when there is nothing to swap.
    var onSomethingElse: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: session.title).typeRole(.cardTitle).fontWeight(.bold)
                    if let detail { Text(verbatim: detail).typeRole(.body) }
                }
                .foregroundStyle(session.kind == .done ? Palette.onStrongFill : Palette.text)
                Spacer(minLength: 0)
                Image(systemName: symbol)
                    .font(.system(size: 36))
                    .foregroundStyle(session.kind == .done ? Palette.onStrongFill : Palette.secondary)
                    .accessibilityHidden(true)
            }
            if trialEnded {
                HStack {
                    Text("Your trial has ended").typeRole(.body).foregroundStyle(Palette.text)
                    Spacer()
                    Button("See plans", action: onSeePlans).buttonStyle(.smallTextLink)
                }
            }
            if session.kind != .done && session.kind != .rest {
                Button("Start", action: onStart).buttonStyle(.primaryAction)
            }
            if let onSomethingElse {
                Button("Try something else", action: onSomethingElse)
                    .buttonStyle(.smallTextLink)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(session.kind == .done ? Palette.secondary : Palette.surface, in: .rect(cornerRadius: Metrics.cardRadius))
    }

    private var symbol: String {
        switch (session.kind, session.main) {
        case (.done, _): "checkmark.seal.fill"
        case (.rest, _): "moon.zzz.fill"
        case (_, .chair): "chair.fill"
        case (_, .stretch): "figure.flexibility"
        default: "figure.walk"
        }
    }
}

/// "Your free trial ends on Oct 11. You'll be billed $39.99 unless you cancel." · Manage.
struct TrialEndingCard: View {
    let date: Date
    let price: String?
    let onManage: () -> Void

    var body: some View {
        let day = date.formatted(.dateTime.month(.abbreviated).day())
        VStack(alignment: .leading, spacing: 8) {
            Text("Your free trial ends on \(day).").typeRole(.cardTitle)
            if let price {
                Text("You'll be billed \(price) unless you cancel.").typeRole(.body)
            }
            Button("Manage", action: onManage).buttonStyle(.secondaryAction)
        }
        .foregroundStyle(Palette.text)
        .cardStyle()
        .overlay { RoundedRectangle(cornerRadius: Metrics.cardRadius).strokeBorder(Palette.sun, lineWidth: 2) }
    }
}
