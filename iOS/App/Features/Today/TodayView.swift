import SwiftUI
import GentleWalkCore

/// S17 Today, in the order she uses it (owner 01/10/2026: the screen read as a flat list of equal
/// blocks): greeting and active days, today's session with the check-in inside it (the one big
/// card), notices, then the journey, the week and the short extras as a row.
struct TodayView: View {
    let model: TodayModel
    let actions: TodayActions

    @State private var showsSwap = false
    /// Picked in the swap sheet; acted on once the sheet has gone, so two covers never overlap.
    @State private var pendingSwap: PendingSwap?

    private enum PendingSwap { case start(WorkoutRequest), allSessions }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // Greeting and one line (days · week · Plan ›), so Start sits in the upper half of an
                // iPhone SE (plan 08/10/2026 task 1.8).
                TodayHeadline(greeting: model.greeting, activeDays: model.activeDays, progress: model.treeProgress,
                              strip: model.programStrip,
                              onOpenPlan: model.programStrip?.kind == .finished ? actions.onProgramFinished : actions.onOpenProgram,
                              onPickUp: actions.onPickUpProgram)
                if let welcome = model.welcomeBack {
                    Text(verbatim: welcome).typeRole(.body).foregroundStyle(Palette.text)
                }
                if let lastWeek = model.lastWeekLine {
                    Text(verbatim: lastWeek).typeRole(.body).foregroundStyle(Palette.text)
                }
                // A check that is due comes first with the one green button; the session card's Start
                // steps back to an outlined button (one main button per screen).
                if checkIsDue, let status = model.checkCard, let title = model.checkTitle {
                    SelfCheckCard(status: status, title: title, isMain: true, onStart: actions.onSelfCheck,
                                  onLater: actions.onSelfCheckLater)
                }
                TodaySessionCard(session: model.session, detail: model.sessionDetail, goalLine: model.goalLine,
                                 trialEnded: model.showsTrialEndedNote,
                                 isSeated: model.isSeatedWalk, startIsSecondary: checkIsDue,
                                 checkIn: model.showsCheckIn && model.session.kind != .rest
                                    ? .init(selected: model.checkedIn, note: model.checkInNote, onSelect: model.checkIn) : nil,
                                 onStart: { if let request = model.request { actions.onStart(request) } },
                                 onSeePlans: actions.onSeePlans,
                                 onPickAnother: model.swapOptions.isEmpty ? actions.onSeeAllSessions : { showsSwap = true },
                                 onStillOpen: model.stillOpenRequest.map { request in { actions.onStart(request) } })
                if !checkIsDue, let status = model.checkCard, let title = model.checkTitle {
                    SelfCheckCard(status: status, title: title, onStart: actions.onSelfCheck, onLater: actions.onSelfCheckLater)
                }
                if let ends = model.trialEndingDate {
                    TrialEndingCard(date: ends, price: actions.yearlyPrice, onManage: actions.onManagePlan)
                }
                if let card = model.specialCard {
                    SpecialCard(card: card, actions: actions, reminderMinutes: model.reminderMinutes)
                }
                JourneyMiniCard(title: model.journeyTitle, line: model.journeyLine, progress: model.journeyProgress,
                                journeyID: model.journeyID, onOpen: actions.onOpenJourney)
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
        .sheet(isPresented: $showsSwap, onDismiss: actOnPendingSwap) {
            SwapSessionSheet(options: model.swapOptions, onPick: { option in
                if option.isLocked {
                    showsSwap = false
                    actions.onSeePlans()
                } else {
                    pendingSwap = .start(option.request)
                    showsSwap = false
                }
            }, onSeeAll: {
                pendingSwap = .allSessions
                showsSwap = false
            })
        }
    }

    private var checkIsDue: Bool {
        switch model.checkCard {
        case .due?, .overdue?: true
        default: false
        }
    }

    private func actOnPendingSwap() {
        guard let pending = pendingSwap else { return }
        pendingSwap = nil
        switch pending {
        case .start(let request): actions.onStart(request)
        case .allSessions: actions.onSeeAllSessions()
        }
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
    /// "Keep it seated" on the moved-up card (plan 08/10/2026 task 0.5).
    var onKeepEasierLevel: () -> Void = {}
    // Personalisation cards (milestone 4).
    /// A move set aside: Me has "Bring it back".
    var onOpenMe: () -> Void = {}
    /// A busy day: a gentle stretch instead of the planned session.
    var onStretchInstead: () -> Void = {}
    /// "Move your reminder to 9:15?": yes with the time, or keep it.
    var onMoveReminder: (Int) -> Void = { _ in }
    var onKeepReminder: () -> Void = {}
    /// "Try the longer walk today?"
    var onLongerWalk: () -> Void = {}
    /// Steady program: the 12-week plan, the 2-week self-check, "Pick up at week N", the finish screen.
    var onOpenProgram: () -> Void = {}
    var onSelfCheck: () -> Void = {}
    var onSelfCheckLater: () -> Void = {}
    var onPickUpProgram: () -> Void = {}
    var onProgramFinished: () -> Void = {}
}

/// "Good morning, Margaret", then one line: the tree ring, "13 active days · Week 3 of 12 · Plan ›"
/// (plan 08/10/2026 task 1.8: the hero and the program strip were 180 pt before the session card).
/// No picture: today's session is the first thing under it (owner 01/10/2026).
struct TodayHeadline: View {
    let greeting: String
    let activeDays: Int
    let progress: Double
    /// The 12-week plan; nil before the first session (then the line shows the tree level).
    let strip: ProgramStripState?
    let onOpenPlan: () -> Void
    let onPickUp: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: greeting).typeRole(.screenTitle).foregroundStyle(Palette.text)
                .accessibilityAddTraits(.isHeader)
            if let strip {
                Button(action: onOpenPlan) {
                    // One line: with the word "Plan" where it fits, a chevron alone on an iPhone SE,
                    // wrapped only at large text sizes.
                    ViewThatFits(in: .horizontal) {
                        line(showsPlanWord: true)
                        line(showsPlanWord: false)
                        HStack(spacing: 8) {
                            ActiveDaysRing(progress: progress, size: 24)
                            (Text(verbatim: "\(summary) · ") + Text("Plan") + Text(verbatim: " ›"))
                                .typeRole(.body).fontWeight(.semibold)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .foregroundStyle(Palette.text)
                    .frame(minHeight: Metrics.minTouchTarget)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(verbatim: "\(summary), ") + Text("Plan"))
                .accessibilityAddTraits(.isButton)
                .accessibilityHint(Text("Opens your 12-week plan"))
                if let week = strip.pickUpWeek {
                    Button(String(localized: "Pick up at week \(week)"), action: onPickUp)
                        .buttonStyle(PillButtonStyle(isSelected: true))
                }
            } else {
                ActiveDaysLine(count: activeDays, progress: progress)
            }
        }
    }

    /// "13 active days · Week 3 of 12"
    private var summary: String { "\(Plural.activeDays(activeDays)) · \(strip?.title ?? "")" }

    private func line(showsPlanWord: Bool) -> some View {
        HStack(spacing: 8) {
            ActiveDaysRing(progress: progress, size: 24)
            Text(verbatim: summary).typeRole(.body).fontWeight(.semibold).fixedSize()
            Spacer(minLength: 4)
            HStack(spacing: 4) {
                if showsPlanWord { Text("Plan") }
                Image(systemName: "chevron.right").accessibilityHidden(true)
            }
            .typeRole(.body).fontWeight(.semibold)
            .fixedSize()
        }
    }
}

/// A small tree ring filling towards the next level, "13 active days", and the level's name.
struct ActiveDaysLine: View {
    let count: Int
    let progress: Double

    var body: some View {
        HStack(spacing: 10) {
            ActiveDaysRing(progress: progress)
            Text(verbatim: "\(Plural.activeDays(count)) · \(String(localized: TreeLevel.level(activeDays: count).title))")
                .typeRole(.body).fontWeight(.semibold)
                .foregroundStyle(Palette.text)
        }
        .accessibilityElement(children: .combine)
    }
}

/// The ring that fills towards the next tree level, with a leaf in the middle.
struct ActiveDaysRing: View {
    let progress: Double
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 30

    init(progress: Double, size: CGFloat = 30) {
        self.progress = progress
        _size = ScaledMetric(wrappedValue: size, relativeTo: .body)
    }

    var body: some View {
        ZStack {
            Circle().stroke(Palette.secondary.opacity(0.2), lineWidth: 4)
            Circle()
                .trim(from: 0, to: max(0.03, min(1, progress)))
                .stroke(Palette.secondary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Image(systemName: "leaf.fill")
                .font(.system(size: size * 0.4))
                .foregroundStyle(Palette.secondary)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

/// "How do your joints feel today?" · Achy · Okay · Great, one line inside the session card, Okay
/// chosen until she says otherwise (it is the session as planned). Her answer retitles the card.
struct CheckInRow: View {
    let selected: CheckIn?
    /// Why a choice is already made (D16); otherwise what the answer does.
    var note: String? = nil
    let onSelect: (CheckIn) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // A question she answers: body text, not a muted caption; the line under it says why
            // (clarity review D6, restored by review M1, 02/10/2026).
            Text("How do your joints feel today?").typeRole(.body).foregroundStyle(Palette.text)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) { buttons }
                VStack(spacing: 8) { buttons }
            }
            if let note {
                Text(verbatim: note).typeRole(.caption).foregroundStyle(Palette.text)
            } else {
                Text("We'll set today's session to match.").typeRole(.caption).foregroundStyle(Palette.textMuted)
            }
        }
    }

    @ViewBuilder private var buttons: some View {
        option(.achy, "Achy")
        option(.okay, "Okay")
        option(.great, "Great")
    }

    private func option(_ value: CheckIn, _ title: LocalizedStringResource) -> some View {
        let isOn = (selected ?? .okay) == value
        return Button { onSelect(value) } label: { Text(title) }
            .buttonStyle(PillButtonStyle(isSelected: isOn, fills: true))
            .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

/// Today's session: the biggest card, with Start.
struct TodaySessionCard: View {
    let session: TodaySession
    let detail: String?
    /// Her goal, when today's session serves it (P4).
    var goalLine: String? = nil
    let trialEnded: Bool
    /// A seated walk shows a seated figure, not a walking one (clarity review D6).
    var isSeated = false
    /// A 2-week check is due above: Start is the outlined button (task 1.8).
    var startIsSecondary = false
    /// The check-in, while today's session is still to do.
    var checkIn: CheckInChoice?
    let onStart: () -> Void
    let onSeePlans: () -> Void
    /// "Pick a different session": the swap sheet, or All sessions when there is nothing to swap
    /// (one link for what were "Try something else" and "Browse all sessions", owner 01/10/2026).
    var onPickAnother: (() -> Void)?
    /// Done for today: the planned session is still here if she'd like it.
    var onStillOpen: (() -> Void)?

    @Environment(\.dynamicTypeSize) private var typeSize

    struct CheckInChoice {
        let selected: CheckIn?
        var note: String? = nil
        let onSelect: (CheckIn) -> Void
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: session.title).typeRole(.cardTitle).fontWeight(.bold)
                    if let detail { Text(verbatim: detail).typeRole(.body) }
                    if let goalLine {
                        // Ink, with the leaf in green: only text-on-paper pairs are checked for contrast.
                        Label { Text(verbatim: goalLine) } icon: { Image(systemName: "leaf.fill").foregroundStyle(Palette.secondary) }
                            .typeRole(.caption).fontWeight(.semibold).foregroundStyle(Palette.text)
                    }
                }
                .foregroundStyle(session.kind == .done ? Palette.onStrongFill : Palette.text)
                Spacer(minLength: 0)
                // At accessibility sizes the title needs the width (it broke word by word).
                if session.kind == .rest, !typeSize.isAccessibilitySize {
                    // A rest day is a good day: the coach resting, not a moon icon (review M15,
                    // pattern of Gentler Streak's "Day to Rest and Recover").
                    ArtImage(art: .walkerRest, height: 96, fallbackSymbol: "moon.zzz.fill").frame(width: 84)
                } else if !typeSize.isAccessibilitySize {
                    Image(systemName: symbol)
                        .typeRole(.stat)
                        .fontWeight(.regular)
                        .foregroundStyle(session.kind == .done ? Palette.onStrongFill : Palette.secondary)
                        .accessibilityHidden(true)
                }
            }
            if trialEnded {
                HStack {
                    Text("Your trial has ended").typeRole(.body).foregroundStyle(Palette.text)
                    Spacer()
                    Button("See Pro plans", action: onSeePlans).buttonStyle(.smallTextLink)
                }
            }
            if let checkIn {
                CheckInRow(selected: checkIn.selected, note: checkIn.note, onSelect: checkIn.onSelect)
            }
            if session.kind != .done && session.kind != .rest {
                if startIsSecondary {
                    Button("Start", action: onStart).buttonStyle(.secondaryAction)
                } else {
                    Button("Start", action: onStart).buttonStyle(.primaryAction)
                }
            }
            if let onStillOpen {
                Button("Today's session is still here if you'd like it", action: onStillOpen)
                    .buttonStyle(.smallTextLink)
                    .foregroundStyle(Palette.onStrongFill)
                    .multilineTextAlignment(.leading)
            }
            if let onPickAnother {
                // Done for today: All sessions stays one tap away (it was only at the foot of Today).
                Button(pickAnotherTitle, action: onPickAnother)
                    .buttonStyle(.smallTextLink)
                    .foregroundStyle(session.kind == .done ? Palette.onStrongFill : Palette.text)
                    .frame(maxWidth: .infinity)
                    // The 56 pt touch area keeps its size; only the empty space around the words shrinks.
                    .padding(.vertical, -8)
                    .padding(.bottom, -6)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(session.kind == .done ? Palette.secondary : Palette.surface, in: .rect(cornerRadius: Metrics.cardRadius))
    }

    private var pickAnotherTitle: LocalizedStringResource {
        switch session.kind {
        case .done: "See all sessions"
        // Rest is the plan; moving a little is an invitation, never a task.
        case .rest: "Like to move a little? Pick a short session"
        default: "Pick a different session"
        }
    }

    private var symbol: String {
        switch (session.kind, session.main) {
        case (.done, _): "checkmark.seal.fill"
        case (.rest, _): "moon.zzz.fill"
        case (_, .chair): "chair.fill"
        case (_, .stretch): "figure.flexibility"
        default: isSeated ? "figure.seated.side" : "figure.walk"
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
            Button("How to cancel", action: onManage).buttonStyle(.secondaryAction)
        }
        .foregroundStyle(Palette.text)
        .cardStyle()
        .overlay { RoundedRectangle(cornerRadius: Metrics.cardRadius).strokeBorder(Palette.sun, lineWidth: 2) }
    }
}
