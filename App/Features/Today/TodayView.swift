import SwiftUI
import GentleWalkCore

/// S17 Today: greeting and active days, check-in, today's session (the biggest card), a special
/// card when one applies, journey mini card, the week and Extras.
struct TodayView: View {
    let model: TodayModel
    let actions: TodayActions

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                TodayGreeting(greeting: model.greeting, activeDays: model.activeDays)
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
                                 onSeePlans: actions.onSeePlans)
                if let card = model.specialCard {
                    SpecialCard(card: card, actions: actions)
                }
                JourneyMiniCard(line: model.journeyLine, progress: model.journeyProgress, onOpen: actions.onOpenJourney)
                WeekStrip(days: model.week, isPro: model.isPro, line: model.weekLine)
                if !model.extras.isEmpty {
                    ExtrasRow(extras: model.extras, isPro: model.isPro, onStart: actions.onStart, onLocked: actions.onSeePlans)
                }
            }
            .padding(Metrics.screenMargin)
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .screenBackground()
    }
}

/// What Today can ask the app to do.
struct TodayActions {
    var yearlyPrice: String?
    var onStart: (WorkoutRequest) -> Void
    var onSeePlans: () -> Void
    var onManagePlan: () -> Void
    var onOpenJourney: () -> Void
    var onConnectHealth: () -> Void
    var onDismissCard: () -> Void
    var onFewerReminders: (Bool) -> Void
}

/// "Good morning, Margaret" · leaf "13 active days".
struct TodayGreeting: View {
    let greeting: String
    let activeDays: Int

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .firstTextBaseline) { title; Spacer(); days }
            VStack(alignment: .leading, spacing: 6) { title; days }
        }
    }

    private var title: some View {
        Text(verbatim: greeting).typeRole(.screenTitle).foregroundStyle(Palette.text).accessibilityAddTraits(.isHeader)
    }

    private var days: some View {
        Label(Plural.activeDays(activeDays), systemImage: "leaf.fill")
            .typeRole(.body).fontWeight(.semibold)
            .foregroundStyle(Palette.text)
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
