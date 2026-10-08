import SwiftUI

/// S10b Outdoor prep (`OutdoorPrepFlow`): 1. four optional ticks and a hot-weather tip; 2. the first
/// time only, how to measure the walk; 3. after "Map and distance", one button before Apple's
/// location dialog (HIG pre-alert, 5.1.1(iv); plan 08/10/2026 task 1.17). Continue is pinned, so every
/// step fits an iPhone SE (task 1.13); at accessibility sizes it ends the page.
struct OutdoorPrepView: View {
    let asksLocation: Bool
    /// Apple's location dialog; returns whether location is allowed once she has answered.
    let onRequestLocation: () async -> Bool
    let onDone: (_ useLocation: Bool?) -> Void
    /// Not ready to go out after all: back, nothing starts (review 02/10/2026).
    var onClose: () -> Void = {}
    /// Screenshots start on a later step.
    var startStep: OutdoorPrepFlow.Step = .ready

    @State private var flow: OutdoorPrepFlow?
    @State private var ticked: Set<Int> = []
    @Environment(\.dynamicTypeSize) private var typeSize

    private var pins: Bool { !typeSize.isAccessibilitySize }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let flow {
                    switch flow.step {
                    case .ready: BeforeYouGo(ticked: $ticked)
                    case .measure: MeasureChoiceView(measure: Binding(get: { flow.measure }, set: { flow.measure = $0 }))
                    case .locationPrompt: LocationPromptView()
                    }
                }
                if !pins { continueButton }
            }
            .padding(.horizontal, Metrics.screenMargin)
            .padding(.bottom, Metrics.screenMargin)
            .readableColumn()
        }
        .scrollBounceBehavior(.basedOnSize)
        // Its own row above the picture (on the picture it was hard to read).
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack {
                Spacer()
                Button("Close", action: onClose).buttonStyle(.smallTextLink)
            }
            .padding(.horizontal, Metrics.screenMargin)
            .background(Palette.bg)
        }
        .pinnedActions(pins) { continueButton }
        .screenBackground()
        .task {
            guard flow == nil else { return }
            let new = OutdoorPrepFlow(asksLocation: asksLocation || startStep != .ready)
            if startStep != .ready { new.readyDone() }
            if startStep == .locationPrompt { new.measureDone() }
            flow = new
        }
    }

    private var continueButton: some View {
        Button("Continue") {
            guard let flow, !flow.isAsking else { return }
            switch flow.step {
            case .ready: finish(flow.readyDone())
            case .measure: finish(flow.measureDone())
            case .locationPrompt:
                Task { onDone(await flow.requestLocation(onRequestLocation)) }
            }
        }
        .buttonStyle(.primaryAction)
    }

    private func finish(_ outcome: OutdoorPrepFlow.Outcome) {
        if case .finished(let useLocation) = outcome { onDone(useLocation) }
    }
}

/// Step 1: the picture, four ticks (56 pt rows) and the hot-weather tip in two lines.
private struct BeforeYouGo: View {
    @Binding var ticked: Set<Int>

    private let items: [LocalizedStringResource] = ["Water with you", "Sturdy shoes", "Phone charged", "One ear free to hear traffic"]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ArtImage(art: .momentReadyDoor, height: 110, fallbackSymbol: "shoe.2.fill")
            ScreenHeader(title: "Before you head out")
            VStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { index in
                    CheckRow(title: items[index], isOn: ticked.contains(index)) {
                        if ticked.contains(index) { ticked.remove(index) } else { ticked.insert(index) }
                    }
                    if index != items.indices.last { Divider() }
                }
            }
            .cardStyle(padding: 8)
            Label("On hot days, walk early or late. Stop if you feel dizzy.", systemImage: "sun.max.fill")
                .typeRole(.body)
                .foregroundStyle(Palette.text)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Palette.sun.opacity(0.18), in: .rect(cornerRadius: Metrics.cardRadius))
        }
    }
}

/// One optional tick in the checklist: a 56 pt row, the tick on the right.
private struct CheckRow: View {
    let title: LocalizedStringResource
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title).typeRole(.body).fontWeight(.semibold).multilineTextAlignment(.leading)
                Spacer(minLength: 8)
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .typeRole(.cardTitle)
                    .foregroundStyle(isOn ? Palette.primary : Palette.textMuted)
                    .contentTransition(.symbolEffect(.replace))
                    .accessibilityHidden(true)
            }
            .foregroundStyle(Palette.text)
            .padding(.horizontal, 8)
            .frame(minHeight: Metrics.minTouchTarget)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
    }
}

/// Step 2, first time only: "How should we measure your walk?" Map and distance, or steps only.
struct MeasureChoiceView: View {
    @Binding var measure: OutdoorPrepFlow.Measure

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ArtImage(art: .mapPark, height: 110, fallbackSymbol: "map")
            ScreenHeader(title: "How should we measure your walk?")
            SelectableCard(title: "Map and distance", subtitle: "Uses your location while you walk",
                           symbol: "map.fill", isSelected: measure == .map) { measure = .map }
            SelectableCard(title: "Steps only", subtitle: "No location needed",
                           symbol: "shoeprints.fill", isSelected: measure == .steps) { measure = .steps }
            Text("You can change this in Me.").typeRole(.caption).foregroundStyle(Palette.textMuted)
        }
    }
}

/// Step 3, after "Map and distance": what comes next, with one button (no "Allow", no second way out:
/// "Don't Allow" in Apple's dialog means steps only).
struct LocationPromptView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ArtImage(art: .mapPark, height: 110, fallbackSymbol: "map")
            ScreenHeader(title: "Next, iPhone asks about location",
                         subtitle: "Only while you walk. It stays on this phone.")
        }
    }
}
