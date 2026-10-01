import SwiftUI
import GentleWalkCore

/// "Up next" before the 3-2-1, for a session she has not previewed (the First Walk, chair moves
/// after an outdoor walk): what it is, how long, what to have ready, and "I'm ready" when she is.
/// Nothing plays and nothing counts until then (owner 01/10/2026: Continue on phone placement went
/// straight into the count). "Not yet" closes it; the First Walk then waits on Today.
struct WorkoutReadyView: View {
    let request: WorkoutRequest
    let minutes: Int
    let onReady: () -> Void
    let onNotYet: () -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 14) {
                    if !typeSize.isAccessibilitySize {
                        ArtImage(art: art, height: 110, fallbackSymbol: "figure.walk")
                            .frame(width: 110)
                            .accessibilityHidden(true)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Up next").typeRole(.caption).fontWeight(.semibold).foregroundStyle(Palette.textMuted)
                        Text(verbatim: request.isFirstWalk ? String(localized: "Your first walk") : request.title)
                            .typeRole(.screenTitle).foregroundStyle(Palette.text)
                            .accessibilityAddTraits(.isHeader)
                        Text(verbatim: summary).typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
                    }
                }
                .padding(.top, 8)
                HaveReadyCard(needsChair: needsChair, placement: PhonePlacement.saved())
                ThenStrip()
                if typeSize.isAccessibilitySize { actions }
            }
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        .scrollBounceBehavior(.basedOnSize)
        .pinnedActions(!typeSize.isAccessibilitySize) { actions }
        .screenBackground()
    }

    @ViewBuilder private var actions: some View {
        Button("I'm ready", action: onReady).buttonStyle(.primaryAction)
        VStack(spacing: 0) {
            Button("Not yet", action: onNotYet).buttonStyle(.textLink)
            Text(request.isFirstWalk ? "Your first walk waits for you on Today." : "You'll find it later in All sessions.")
                .typeRole(.caption).foregroundStyle(Palette.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    /// "5 min · Seated" for a walk, "5 min · With your chair" for chair moves.
    private var summary: String {
        let kind: String = switch request.day.main {
        case .chair: String(localized: "With your chair")
        case .stretch: String(localized: "Gentle stretches")
        default: String(localized: request.level.title)
        }
        return String(localized: "\(minutes) min · \(kind)")
    }

    private var needsChair: Bool {
        request.level == .seated || request.day.main == .chair || request.day.main == .stretch || request.day.chairMoves > 0
    }

    private var art: Art {
        switch request.day.main {
        case .chair: .walkerSeatedMarch
        case .stretch: .walkerRest
        default:
            switch request.place {
            case .outdoors: .sceneOutdoors
            case .pad: .sceneWalkingPad
            case .indoors: request.level == .seated ? .walkerSeatedMarch : .sceneLivingRoom
            }
        }
    }
}

/// "Have ready" as picture tiles, two or three words each, read at a glance (owner 01/10/2026:
/// less to read on every screen).
private struct HaveReadyCard: View {
    let needsChair: Bool
    let placement: PhonePlacement

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Have ready").typeRole(.cardTitle).foregroundStyle(Palette.text)
                .accessibilityAddTraits(.isHeader)
            let columns = Array(repeating: GridItem(.flexible(), spacing: 8, alignment: .top),
                                count: typeSize.isAccessibilitySize ? 2 : 4)
            LazyVGrid(columns: columns, spacing: 12) {
                if needsChair { ReadyTile(symbol: "chair.fill", title: "Sturdy chair") }
                ReadyTile(symbol: "figure.arms.open", title: "Room to move")
                ReadyTile(symbol: "waterbottle.fill", title: "Water")
                ReadyTile(symbol: placement.symbol, title: placement.shortTitle)
                    .accessibilityLabel(Text("Phone: \(placement.title)"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

/// "Then": 3, 2, 1 → follow the voice → pause anytime, one row of pictures with arrows: what
/// "I'm ready" starts (owner 01/10/2026: the screen has to say it).
private struct ThenStrip: View {
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Then").typeRole(.cardTitle).foregroundStyle(Palette.text)
                .accessibilityAddTraits(.isHeader)
            let layout = typeSize.isAccessibilitySize ? AnyLayout(VStackLayout(alignment: .leading, spacing: 10))
                : AnyLayout(HStackLayout(alignment: .top, spacing: 4))
            layout {
                ReadyTile(symbol: "timer", title: "3, 2, 1")
                arrow
                ReadyTile(symbol: "speaker.wave.2.fill", title: "Follow the voice")
                arrow
                ReadyTile(symbol: "pause.fill", title: "Pause anytime")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }

    @ViewBuilder private var arrow: some View {
        if !typeSize.isAccessibilitySize {
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Palette.textMuted)
                .padding(.top, 18)
                .accessibilityHidden(true)
        }
    }
}

/// An icon in a soft circle over a short label.
private struct ReadyTile: View {
    let symbol: String
    let title: LocalizedStringResource

    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .title3) private var size: CGFloat = 52

    var body: some View {
        let layout = typeSize.isAccessibilitySize ? AnyLayout(HStackLayout(spacing: 12))
            : AnyLayout(VStackLayout(spacing: 6))
        layout {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(Palette.secondary)
                .frame(width: size, height: size)
                .background(Palette.secondary.opacity(0.14), in: .circle)
                .accessibilityHidden(true)
            Text(title).typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
                .multilineTextAlignment(typeSize.isAccessibilitySize ? .leading : .center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: typeSize.isAccessibilitySize ? .leading : .center)
        .accessibilityElement(children: .combine)
    }
}

extension PhonePlacement {
    /// Two words under the phone icon on the "Have ready" tile.
    var shortTitle: LocalizedStringResource {
        switch self {
        case .pocket: "In pocket"
        case .chest: "On chest"
        case .table: "On table"
        }
    }
}
