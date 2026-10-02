import SwiftUI

/// S10b Outdoor prep. Screen 1: four optional ticks and a hot-weather note. Screen 2 (first time
/// only): the map question; "Use my location" opens Apple's While Using dialog, "Just count my
/// steps" never asks again.
struct OutdoorPrepView: View {
    let asksLocation: Bool
    /// Apple's location dialog; returns once she has answered.
    let onRequestLocation: () async -> Void
    let onDone: (_ useLocation: Bool?) -> Void
    /// Not ready to go out after all: back, nothing starts (review 02/10/2026).
    var onClose: () -> Void = {}
    @State private var step = 1
    @State private var ticked: Set<Int> = []
    @State private var asking = false

    var body: some View {
        ScrollView {
            Group {
            if step == 1 {
                BeforeYouGo(ticked: $ticked) {
                    if asksLocation { step = 2 } else { onDone(nil) }
                }
            } else {
                OutdoorLocationAskView(onUseLocation: {
                    guard !asking else { return }
                    asking = true
                    Task {
                        await onRequestLocation()
                        onDone(true)
                    }
                }, onStepsOnly: { onDone(false) })
            }
            }
            .readableColumn()
        }
        // Its own row above the picture (on the picture it was hard to read).
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack {
                Spacer()
                Button("Close", action: onClose).buttonStyle(.smallTextLink)
            }
            .padding(.horizontal, Metrics.screenMargin)
            .background(Palette.bg)
        }
        .screenBackground()
    }
}

private struct BeforeYouGo: View {
    @Binding var ticked: Set<Int>
    let onContinue: () -> Void

    private let items: [LocalizedStringResource] = ["Water with you", "Sturdy shoes", "Phone charged", "One ear free to hear traffic"]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ArtImage(art: .momentReadyDoor, height: 150, fallbackSymbol: "shoe.2.fill")
            ScreenHeader(title: "Before you head out")
            ForEach(items.indices, id: \.self) { index in
                SelectableCard(title: items[index], isSelected: ticked.contains(index)) {
                    if ticked.contains(index) { ticked.remove(index) } else { ticked.insert(index) }
                }
            }
            Label("On hot days, walk early or late and rest in the shade. Stop if you feel dizzy or unwell.",
                  systemImage: "sun.max.fill")
                .typeRole(.body)
                .foregroundStyle(Palette.text)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Palette.sun.opacity(0.18), in: .rect(cornerRadius: Metrics.cardRadius))
            Button("Continue", action: onContinue).buttonStyle(.primaryAction)
        }
        .padding(Metrics.screenMargin)
    }
}

/// "Want a map of your walk?" — the only place location permission is asked.
struct OutdoorLocationAskView: View {
    let onUseLocation: () -> Void
    let onStepsOnly: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ArtImage(art: .mapPark, height: 160, fallbackSymbol: "map")
            ScreenHeader(title: "Want a map of your walk?")
            Text("With your location on, we can measure your distance and show your route afterwards. It's only used while you're walking and stays on this phone.")
                .typeRole(.body)
                .foregroundStyle(Palette.text)
            Button("Use my location", action: onUseLocation).buttonStyle(.primaryAction)
            Button("Just count my steps", action: onStepsOnly).buttonStyle(.secondaryAction)
        }
        .padding(Metrics.screenMargin)
    }
}
