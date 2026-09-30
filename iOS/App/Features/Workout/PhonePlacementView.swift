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

/// S09 Phone placement: shown before the first session, later only from "How?". Each choice is one
/// card with its picture inside, alternating sides (picture · words, words · picture, …), so the
/// three fit on one screen without loose pictures floating between cards (owner, 30/09/2026).
struct PhonePlacementView: View {
    let onDone: (PhonePlacement) -> Void
    @State private var choice = PhonePlacement.saved()

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ScreenHeader(title: "Where will your phone be?")
                ForEach(Array(PhonePlacement.allCases.enumerated()), id: \.element.id) { index, placement in
                    PlacementCard(placement: placement, isSelected: choice == placement,
                                  pictureLeads: index.isMultiple(of: 2)) { choice = placement }
                }
                Label("Your screen can lock. The voice keeps going.", systemImage: "lock.fill")
                    .typeRole(.body)
                    .foregroundStyle(Palette.text)
                    .padding(.top, 4)
                if typeSize.isAccessibilitySize { gotIt }
            }
            .padding(Metrics.screenMargin)
            .readableColumn()
        }
        .scrollBounceBehavior(.basedOnSize)
        .pinnedActions(!typeSize.isAccessibilitySize) { gotIt }
        .screenBackground()
    }

    private var gotIt: some View {
        Button("Got it") {
            UserDefaults.standard.set(choice.rawValue, forKey: PhonePlacement.defaultsKey)
            UserDefaults.standard.set(true, forKey: PhonePlacement.seenKey)
            onDone(choice)
        }
        .buttonStyle(.primaryAction)
    }
}

/// One placement: the coach showing where the phone goes, and the words, side by side; the tick
/// sits on the picture's corner so it is in the same place whichever side the picture is on.
/// Picture above the words at accessibility text sizes.
private struct PlacementCard: View {
    let placement: PhonePlacement
    let isSelected: Bool
    let pictureLeads: Bool
    let action: () -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        Button(action: action) {
            Group {
                if typeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 10) { picture; words }
                } else {
                    HStack(spacing: 14) {
                        if pictureLeads { picture }
                        words
                        if !pictureLeads { picture }
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
                    .fill(isSelected ? Palette.secondary.opacity(0.1) : Palette.surface)
            }
            .overlay {
                RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
                    .strokeBorder(isSelected ? Palette.primary : Palette.textMuted.opacity(0.25), lineWidth: isSelected ? 3 : 1)
            }
            .contentShape(.rect(cornerRadius: Metrics.cardRadius))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var picture: some View {
        ArtImage(art: placement.art, height: 118, fallbackSymbol: placement.symbol)
            .frame(width: 118)
            .overlay(alignment: .topTrailing) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .typeRole(.cardTitle)
                    .foregroundStyle(isSelected ? Palette.primary : Palette.textMuted)
                    .background(Palette.surface, in: .circle)
                    .padding(6)
                    .dynamicTypeSize(...DynamicTypeSize.xxLarge)
            }
            .accessibilityHidden(true)
    }

    private var words: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(placement.title).typeRole(.body).fontWeight(.semibold)
            Text(placement.subtitle).typeRole(.caption).foregroundStyle(Palette.textMuted)
        }
        .foregroundStyle(Palette.text)
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
