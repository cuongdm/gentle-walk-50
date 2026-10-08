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
        // Its own row above the picture (on the picture it was hard to read). Not on the one-button screen
        // before Apple's location dialog (App Review M-2): there "Don't Allow" means steps only.
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack {
                Spacer()
                if flow?.step != .locationPrompt {
                    Button("Close", action: onClose).buttonStyle(.smallTextLink)
                }
            }
            .frame(minHeight: Metrics.minTouchTarget)
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

/// Step 1: the picture, four optional ticks on notebook paper, each with its picture (water, shoes, phone,
/// ear; plan 08/10/2026 task 3.8), and the hot-weather tip in two lines.
private struct BeforeYouGo: View {
    @Binding var ticked: Set<Int>

    /// The four things to have, in order (the index is what `ticked` keeps).
    private enum Item: Int, CaseIterable {
        case water, shoes, phone, ear

        var title: LocalizedStringResource {
            switch self {
            case .water: "Water with you"
            case .shoes: "Sturdy shoes"
            case .phone: "Phone charged"
            case .ear: "One ear free to hear traffic"
            }
        }

        var icon: AppIcon {
            switch self {
            case .water: .water
            case .shoes: .shoes
            case .phone: .phoneCharged
            case .ear: .listen
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ArtImage(art: .momentReadyDoor, height: 110, fallbackSymbol: "shoe.2.fill")
            ScreenHeader(title: "Before you head out")
            NotebookChoiceList(items: Item.allCases, title: \.title, icon: \.icon,
                               isSelected: { ticked.contains($0.rawValue) }) { item in
                if ticked.contains(item.rawValue) { ticked.remove(item.rawValue) } else { ticked.insert(item.rawValue) }
            }
            Label { Text("On hot days, walk early or late. Stop if you feel dizzy.") } icon: { AppIconGlyph(icon: .hotDay) }
                .typeRole(.body)
                .foregroundStyle(Palette.text)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Palette.sun.opacity(0.18), in: .rect(cornerRadius: Metrics.cardRadius))
        }
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
                           icon: .outdoors, isSelected: measure == .map) { measure = .map }
            SelectableCard(title: "Steps only", subtitle: "No location needed",
                           icon: .steps, isSelected: measure == .steps) { measure = .steps }
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
            ScreenHeader(title: "Next, iPhone asks about location")
            // The two promises as icon lines (task 3.8), the same words as before.
            VStack(alignment: .leading, spacing: 8) {
                IconCardRow(icon: .outdoors, alignment: .center) { Text("Only while you walk.").typeRole(.body) }
                IconCardRow(icon: .privacy, alignment: .center) { Text("It stays on this phone.").typeRole(.body) }
            }
            .foregroundStyle(Palette.text)
        }
    }
}
