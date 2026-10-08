import SwiftUI
import GentleWalkCore

/// What the 12-week plan screen shows, read once from the app.
struct ProgramSnapshot: Equatable {
    var position: ProgramPosition?
    /// Weeks of the checks done this round (0 = the first check), for the seven marks.
    var checkWeeks: [Int]
    var checkStatus: SelfCheckStatus
}

/// Pushed from Today's program strip (option A, task 4.4).
struct ProgramScreen: View {
    let app: AppModel

    var body: some View {
        ProgramView(snapshot: snapshot, onSelfCheck: app.openSelfCheck)
            .navigationBarTitleDisplayMode(.inline)
    }

    private var snapshot: ProgramSnapshot {
        let position = app.programState().map { ProgramCalendar.position($0.programRound, on: app.now(), calendar: app.calendar) }
        return ProgramSnapshot(position: position, checkWeeks: app.progress.selfChecks.map(\.week),
                               checkStatus: app.today?.checkCard ?? SelfCheckStatus.none)
    }
}

/// "Your 12-week plan": the four stages with the current one outlined, the seven 2-week checks, and what
/// the plan is (general fitness, compared only with herself). Design screen 3.
struct ProgramView: View {
    let snapshot: ProgramSnapshot
    let onSelfCheck: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ScreenHeader(title: "Your 12-week plan",
                             subtitle: "Stronger legs and better balance, at your own pace. Reps go up only when you're ready.")
                if case .week(let week, _) = snapshot.position {
                    Text(verbatim: String(localized: "You're in week \(week) of \(ProgramCalendar.weeks).")).typeRole(.body)
                        .fontWeight(.semibold).foregroundStyle(Palette.text)
                }
                ProgramStageList(current: currentStage)
                SelfCheckDots(doneWeeks: snapshot.checkWeeks, status: snapshot.checkStatus, onStart: onSelfCheck)
                Text("\(AppBrand.name) is for general fitness. It isn't medical advice.")
                    .typeRole(.caption).foregroundStyle(Palette.textMuted)
            }
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        .screenBackground()
    }

    private var currentStage: ProgramStage? {
        if case .week(_, let stage) = snapshot.position { return stage }
        return nil
    }
}

/// Four stages: name, weeks and what happens; the current one outlined in green.
struct ProgramStageList: View {
    let current: ProgramStage?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(ProgramStage.allCases, id: \.rawValue) { stage in
                let isCurrent = stage == current
                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: String(localized: "Stage \(stage.rawValue) · Weeks \(stage.weeks.lowerBound)–\(stage.weeks.upperBound)"))
                        .typeRole(.caption).foregroundStyle(Palette.textMuted)
                    Text(stage.title).typeRole(.cardTitle).foregroundStyle(Palette.text)
                    Text(stage.summary).typeRole(.body).foregroundStyle(Palette.text)
                    if isCurrent {
                        Text("You're here").typeRole(.caption).fontWeight(.semibold).foregroundStyle(Palette.text)
                    }
                }
                .cardStyle()
                .overlay {
                    if isCurrent {
                        RoundedRectangle(cornerRadius: Metrics.cardRadius).strokeBorder(Palette.secondary, lineWidth: 2.5)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(isCurrent ? .isSelected : [])
            }
        }
    }
}

/// Seven marks for the 2-week checks (weeks 0, 2 … 12), filled once done, and Start when one is ready.
struct SelfCheckDots: View {
    let doneWeeks: [Int]
    let status: SelfCheckStatus
    let onStart: () -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    static let weeks = Array(stride(from: 0, through: ProgramCalendar.weeks, by: 2))

    /// Seven in a row; two rows of four at accessibility sizes (one row was wider than the screen).
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 6), count: typeSize.isAccessibilitySize ? 4 : Self.weeks.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your 2-week checks").typeRole(.cardTitle).foregroundStyle(Palette.text)
            Text("30 seconds of sit-to-stands, counted by you. You compare only with yourself.")
                .typeRole(.body).foregroundStyle(Palette.text)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Self.weeks, id: \.self) { week in
                    let done = isDone(week)
                    VStack(spacing: 4) {
                        Image(systemName: done ? "checkmark.circle.fill" : "circle")
                            .typeRole(.cardTitle)
                            .foregroundStyle(done ? Palette.secondary : Palette.textMuted)
                        Text(verbatim: "\(week)").typeRole(.caption).foregroundStyle(Palette.text)
                            .lineLimit(1).minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(Text(verbatim: done ? String(localized: "Week \(week), done") : String(localized: "Week \(week)")))
                }
            }
            Text("Week").typeRole(.caption).foregroundStyle(Palette.textMuted).accessibilityHidden(true)
            switch status {
            case .invite, .due, .overdue:
                Button("Start my check", action: onStart).buttonStyle(.secondaryAction)
            default:
                EmptyView()
            }
        }
        .cardStyle()
    }

    /// A check counts for the nearest mark at or before its week (a check in week 3 fills week 2).
    private func isDone(_ week: Int) -> Bool {
        doneWeeks.contains { $0 == week || ($0 > week && $0 < week + 2) }
    }
}
