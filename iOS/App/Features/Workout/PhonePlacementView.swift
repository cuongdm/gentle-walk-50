import SwiftUI

/// Where the phone sits during a walk (S09). Remembered on this phone only (UserDefaults, CA92.1).
enum PhonePlacement: String, CaseIterable, Identifiable, Sendable {
    case pocket, chest, table
    var id: String { rawValue }

    static let defaultsKey = "phonePlacement"
    static let seenKey = "phonePlacementSeen"

    var title: LocalizedStringResource {
        switch self {
        case .pocket: "In my pocket"
        case .chest: "Held to my chest"
        case .table: "On the table"
        }
    }

    var subtitle: LocalizedStringResource {
        switch self {
        case .pocket: "Best for walking."
        case .chest: "Great if you have no pockets."
        case .table: "Just listen and follow along."
        }
    }

    var symbol: String {
        switch self {
        case .pocket: "iphone.gen3"
        case .chest: "figure.stand"
        case .table: "iphone.gen3.radiowaves.left.and.right"
        }
    }

    var art: Art {
        switch self {
        case .pocket: .phonePocket
        case .chest: .phoneChest
        case .table: .phoneTable
        }
    }

    static func saved(in defaults: UserDefaults = .standard) -> PhonePlacement {
        defaults.string(forKey: defaultsKey).flatMap(PhonePlacement.init) ?? .pocket
    }
}

/// S09 Phone placement: shown before the first session, later only from "How?".
struct PhonePlacementView: View {
    let onDone: (PhonePlacement) -> Void
    @State private var choice = PhonePlacement.saved()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ScreenHeader(title: "Where will your phone be?")
                ForEach(PhonePlacement.allCases) { placement in
                    VStack(spacing: 8) {
                        ArtImage(art: placement.art, height: 130, fallbackSymbol: placement.symbol)
                        SelectableCard(title: placement.title, subtitle: placement.subtitle,
                                       isSelected: choice == placement) { choice = placement }
                    }
                }
                Label("Your screen can lock. The voice keeps going.", systemImage: "lock.fill")
                    .typeRole(.body)
                    .foregroundStyle(Palette.text)
                Button("Got it") {
                    UserDefaults.standard.set(choice.rawValue, forKey: PhonePlacement.defaultsKey)
                    UserDefaults.standard.set(true, forKey: PhonePlacement.seenKey)
                    onDone(choice)
                }
                .buttonStyle(.primaryAction)
            }
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        .screenBackground()
    }
}
