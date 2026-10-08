import SwiftUI
import UIKit
import GentleWalkCore

// Progress, lower half (plan 08/10/2026 task 3.7, owner: "toàn chữ, nhìn rất ngán"), after Claude Design
// ProgressMore.dc.html: empty states with a small picture, one line and one action; "Hands on the chair"
// as a three-step ladder; Everyday wins as a grid of icon cards with a clear chosen state; All-day steps
// with its footprints picture and an outlined button.

extension EverydayWinItem {
    /// Each win's own picture (one symbol, one meaning); a win added later falls back to the wins icon.
    var icon: AppIcon {
        switch id {
        case "win.1": .winSofa
        case "win.2": .winGroceries
        case "win.3": .winStore
        case "win.4": .winStairs
        case "win.5": .grandkids
        case "win.6": .winShelf
        case "win.7": .winMailbox
        case "win.8": .winShow
        default: .everydayWins
        }
    }
}

/// A picture on a watercolour wash: the spot art of an empty state or a card's leading icon.
struct ProgressSpot: View {
    enum Picture { case art(Art), icon(AppIcon) }
    let picture: Picture
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 60
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Group {
            switch picture {
            case .art(let art):
                if art.isBundled {
                    Image(art.rawValue).resizable().scaledToFit().padding(.top, size * 0.08)
                } else {
                    AppIcon.walk.image.resizable().scaledToFit().padding(size * 0.22).foregroundStyle(ChoiceInk.glyph(scheme))
                }
            case .icon(let icon):
                icon.image.resizable().scaledToFit().padding(size * 0.24).foregroundStyle(ChoiceInk.glyph(scheme))
            }
        }
        .frame(width: size, height: size * (isArt ? 1.15 : 1))
        .background {
            // The painted figures carry light paper edges: they sit on art paper in dark mode too.
            if isArt { WashShape(variant: 1).fill(Palette.artPaper) }
            WashShape(variant: 1).fill(RadialGradient(colors: [Palette.sun.opacity(0.14), Palette.sun.opacity(0.42)],
                                                      center: UnitPoint(x: 0.36, y: 0.3), startRadius: 0, endRadius: size * 0.8))
        }
        .accessibilityHidden(true)
    }

    private var isArt: Bool { if case .art = picture { true } else { false } }
}

/// A spot picture beside its words; the picture goes above them at accessibility text sizes, so the
/// words keep the whole width (they broke inside words beside it).
struct ProgressSpotRow<Content: View>: View {
    let picture: ProgressSpot.Picture
    @ViewBuilder let content: Content

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        let layout = typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
                                                  : AnyLayout(HStackLayout(alignment: .center, spacing: 14))
        layout {
            ProgressSpot(picture: picture)
            VStack(alignment: .leading, spacing: 6) { content }
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .cardStyle(padding: 14)
    }
}

/// The same empty-state layout everywhere: picture, title, one line and at most one action.
struct ProgressEmptyCard: View {
    let picture: ProgressSpot.Picture
    let title: LocalizedStringResource
    let line: LocalizedStringResource
    var action: (title: LocalizedStringResource, run: () -> Void)?

    var body: some View {
        ProgressSpotRow(picture: picture) {
            Text(title).typeRole(.cardTitle).foregroundStyle(Palette.text).accessibilityAddTraits(.isHeader)
            Text(line).typeRole(.body).foregroundStyle(Palette.text).fixedSize(horizontal: false, vertical: true)
            if let action {
                Button(action.title, action: action.run).buttonStyle(OutlinedPillButtonStyle())
            }
        }
    }
}

/// A smaller outlined action inside a card (Claude Design: 2 pt green border, leading, never full width).
struct OutlinedPillButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private static let shape = RoundedRectangle(cornerRadius: Metrics.minTouchTarget / 2, style: .continuous)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .typeRole(.body)
            .fontWeight(.semibold)
            .multilineTextAlignment(.leading)
            .foregroundStyle(Palette.text)
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .frame(minHeight: Metrics.minTouchTarget)
            .background(configuration.isPressed ? Palette.primary.opacity(0.1) : .clear, in: Self.shape)
            .overlay { Self.shape.strokeBorder(Palette.primary, lineWidth: Metrics.secondaryBorder) }
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .contentShape(Self.shape)
    }
}

// MARK: - Hands on the chair

/// The support ladder as three steps: Two hands → One hand → Fingertips, a dot for each balance move on
/// the step it is on, a hand picture per step, one summary line, and "Each move" for the list (Pro).
/// Free: every move on two hands, with the one Pro line.
struct HandsLadderCard: View {
    let levels: [String: SupportLevel]
    let isPro: Bool
    let content: ContentBundle?
    let onSeePlans: () -> Void

    @State private var showsMoves = false

    private var summary: SupportLadderSummary { SupportLadderSummary(levels: isPro ? levels : [:]) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and "Each move" on one line, or the link under the title at large text sizes.
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline) { title.fixedSize(); Spacer(minLength: 8); eachMove }
                VStack(alignment: .leading, spacing: 4) { title; eachMove }
            }
            HandsLadder(summary: summary)
            Text(verbatim: summaryLine).typeRole(.body).foregroundStyle(Palette.text).fixedSize(horizontal: false, vertical: true)
            if !isPro {
                Button("See Pro plans", action: onSeePlans).buttonStyle(.smallTextLink)
            }
        }
        .cardStyle()
        .sheet(isPresented: $showsMoves) { HandsEachMoveSheet(rows: rows) }
    }

    private var title: some View {
        Text("Hands on the chair").typeRole(.cardTitle).foregroundStyle(Palette.text)
    }

    @ViewBuilder private var eachMove: some View {
        if isPro, !rows.isEmpty {
            Button("Each move") { showsMoves = true }.buttonStyle(.smallTextLink)
        }
    }

    /// "All 8 balance moves: two hands for now. …" or "3 of 8 moves need less hand on the chair now. …"
    private var summaryLine: String {
        let total = summary.total
        let lighter = summary.count(.oneHand) + summary.count(.fingertips)
        let start = lighter == 0
            ? String(localized: "All \(total) balance moves: two hands for now.")
            : String(localized: "\(lighter) of \(total) moves need less hand on the chair now.")
        let end = isPro ? String(localized: "You move up a step after holding steady twice in a row.")
                        : String(localized: "With Pro, less hand on the chair as you get steadier.")
        return "\(start) \(end)"
    }

    fileprivate struct Row: Identifiable { let id: String; let name: String; let level: SupportLevel }

    fileprivate var rows: [Row] {
        SupportLadder.exercises.sorted().compactMap { id in
            guard let name = content?.exercises.first(where: { $0.id == id })?.name else { return nil }
            return Row(id: id, name: name, level: levels[id] ?? .twoHands)
        }
    }
}

/// The three steps, rising left to right; a dot per move above the step it is on. At accessibility text
/// sizes the steps become rows, lowest first, so the words are never cut.
private struct HandsLadder: View {
    let summary: SupportLadderSummary
    @ScaledMetric(relativeTo: .body) private var unit: CGFloat = 32
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        Group {
            if typeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(SupportLevel.allCases, id: \.self) { level in
                        VStack(alignment: .leading, spacing: 6) {
                            HandsStep(level: level, occupied: summary.count(level) > 0, minHeight: 0)
                            MoveDots(count: summary.count(level))
                        }
                    }
                }
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(SupportLevel.allCases, id: \.self) { level in
                        VStack(spacing: 6) {
                            MoveDots(count: summary.count(level))
                            HandsStep(level: level, occupied: summary.count(level) > 0,
                                      minHeight: unit * (2.2 + Double(level.rawValue)))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: SupportLevel.allCases.map {
            "\(String(localized: $0.shortLabel)): \(summary.count($0))"
        }.joined(separator: ". ")))
    }
}

/// Up to four dots a row.
private struct MoveDots: View {
    let count: Int
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(12), spacing: 4), count: 4), spacing: 4) {
            ForEach(0..<count, id: \.self) { _ in
                Circle().fill(ChoiceInk.chosen(scheme)).frame(width: 12, height: 12)
            }
        }
        .frame(width: 60)
        .frame(height: count == 0 ? 0 : nil)
    }
}

/// One step: green when a move stands on it, paper when not; fingertips dashed until reached.
private struct HandsStep: View {
    let level: SupportLevel
    let occupied: Bool
    let minHeight: CGFloat
    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 22

    private static let shape = UnevenRoundedRectangle(topLeadingRadius: 14, bottomLeadingRadius: 6, bottomTrailingRadius: 6,
                                                      topTrailingRadius: 14, style: .continuous)

    var body: some View {
        VStack(spacing: 6) {
            hands.frame(height: iconSize)
            Text(level.shortLabel).typeRole(.caption).fontWeight(occupied ? .bold : .semibold)
                .multilineTextAlignment(.center).lineLimit(2).minimumScaleFactor(0.8)
        }
        .foregroundStyle(occupied ? Palette.onStrongFill : Palette.text)
        .padding(.top, 10).padding(.horizontal, 4)
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .top)
        .background {
            if occupied {
                Self.shape.fill(LinearGradient(colors: [Palette.secondary.opacity(0.85), Palette.secondary],
                                               startPoint: .top, endPoint: .bottom))
                    .shadow(color: Palette.secondary.opacity(0.25), radius: 7, y: 4)
            } else {
                Self.shape.fill(Palette.surfaceBottom)
                if level == .fingertips {
                    Self.shape.strokeBorder(Palette.textMuted.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                }
            }
        }
    }

    @ViewBuilder private var hands: some View {
        switch level {
        case .twoHands:
            HStack(spacing: 2) {
                AppIcon.supportHand.image.resizable().scaledToFit().scaleEffect(x: -1)
                AppIcon.supportHand.image.resizable().scaledToFit()
            }
        case .oneHand: AppIcon.supportHand.image.resizable().scaledToFit()
        case .fingertips: AppIcon.supportFingertips.image.resizable().scaledToFit()
        }
    }
}

/// "Each move": every balance move and its step today.
private struct HandsEachMoveSheet: View {
    let rows: [HandsLadderCard.Row]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ClosableHeader(title: String(localized: "Hands on the chair"), onClose: { dismiss() })
                ForEach(rows) { row in
                    HStack(alignment: .firstTextBaseline) {
                        Text(verbatim: row.name).typeRole(.body).foregroundStyle(Palette.text)
                        Spacer(minLength: 8)
                        Text(row.level.shortLabel).typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
                            .multilineTextAlignment(.trailing)
                    }
                    .accessibilityElement(children: .combine)
                    if row.id != rows.last?.id { Divider() }
                }
                Text("Less hand on the chair once you've held steady twice in a row.")
                    .typeRole(.caption).foregroundStyle(Palette.textMuted)
            }
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        .screenBackground()
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Everyday wins

/// Everyday wins as a two-column grid of icon cards (one column at accessibility sizes). Chosen: tinted
/// fill, 3 pt border, bold words and a filled check (never colour alone); VoiceOver says "Selected".
struct EverydayWinsGrid: View {
    let wins: [EverydayWinItem]
    let checked: Set<String>
    let onToggle: (String) -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Everyday wins").typeRole(.cardTitle).foregroundStyle(Palette.text)
                Text("Tap the ones you can do now.").typeRole(.caption).foregroundStyle(Palette.textMuted)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10, alignment: .top),
                                     count: typeSize.isAccessibilitySize ? 1 : 2), spacing: 10) {
                ForEach(wins) { win in
                    WinCard(win: win, isChosen: checked.contains(win.id), onTap: { onToggle(win.id) })
                }
            }
            let done = wins.filter { checked.contains($0.id) }.count
            if done > 0 {
                Text("\(done) of \(wins.count) so far. They're yours to keep.").typeRole(.body).foregroundStyle(Palette.text)
            }
        }
        .cardStyle()
        .sensoryFeedback(.selection, trigger: checked)
    }
}

private struct WinCard: View {
    let win: EverydayWinItem
    let isChosen: Bool
    let onTap: () -> Void

    @Environment(\.colorScheme) private var scheme
    private static let shape = RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                AppIconChip(icon: win.icon, selected: isChosen)
                Text(verbatim: win.text).typeRole(.body).fontWeight(isChosen ? .bold : .regular)
                    .foregroundStyle(Palette.text).multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
            .background {
                if isChosen { ChosenFill(cornerRadius: Metrics.cardRadius) } else {
                    Self.shape.fill(LinearGradient(colors: [Palette.surfaceTop, Palette.surfaceBottom], startPoint: .top, endPoint: .bottom))
                }
            }
            .overlay {
                Self.shape.strokeBorder(isChosen ? ChoiceInk.chosen(scheme) : Palette.textMuted.opacity(0.3),
                                        lineWidth: isChosen ? 3 : 1.5)
            }
            .overlay(alignment: .topTrailing) {
                if isChosen { ChosenCheck().padding(8).transition(.scale.combined(with: .opacity)) }
            }
            .contentShape(Self.shape)
        }
        .buttonStyle(PressableCardStyle())
        .animation(.easeOut(duration: 0.2), value: isChosen)
        .accessibilityAddTraits(isChosen ? .isSelected : [])
    }
}

// MARK: - All-day steps

/// Average daily steps this week vs last week, from Apple Health; before Health, the footprints, one
/// line and an outlined "Connect Apple Health".
struct AllDayStepsCard: View {
    let steps: StepsSummary?
    let connected: Bool
    let onConnect: () -> Void

    var body: some View {
        if let steps, connected {
            ProgressSpotRow(picture: .icon(.steps)) {
                Text("All-day steps").typeRole(.cardTitle)
                Text("\(Int(steps.thisWeek).formatted()) a day this week").typeRole(.body).fontWeight(.semibold)
                Text("Last week: \(Int(steps.lastWeek).formatted()) a day").typeRole(.body)
            }
            .foregroundStyle(Palette.text)
        } else {
            ProgressEmptyCard(picture: .icon(.steps), title: "All-day steps",
                              line: "See your everyday steps here. Your journey moves either way.",
                              action: ("Connect Apple Health", onConnect))
        }
    }
}
