import SwiftUI
import GentleWalkCore

/// S10 Workout preview: title by check-in, where you're walking, level, the list of parts with
/// Swap on chair moves, Start now and Remind me later.
struct WorkoutPreviewView: View {
    @Bindable var model: WorkoutPreviewModel
    let onStart: (WorkoutRequest) -> Void
    let onRemindLater: () -> Void
    /// When the reminder would come; nil hides the button (clarity review D10).
    var remindAt: Date? = nil
    var onClose: () -> Void = {}

    @Environment(\.dynamicTypeSize) private var typeSize
    /// Start stays in view at the bottom; at accessibility sizes it sits at the end of the list.
    private var pinsActions: Bool { !typeSize.isAccessibilitySize }
    /// The choices carry their own paintings; only a day without choices (chair moves) gets one on top,
    /// and only for a short list, so a long one is not pushed under Start (plan 08/10/2026 task 1.12).
    private var showsHero: Bool { !model.showsPlaceQuestion && model.day.main != .stretch && model.rows.count <= 4 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ClosableHeader(title: model.title, subtitle: model.subtitle, onClose: onClose)
                if showsHero {
                    ArtImage(art: heroArt, height: 140)
                }
                if model.showsPlaceQuestion {
                    PlaceSelector(place: $model.place)
                }
                if model.showsLevelSelector {
                    LevelSelector(level: $model.level, suggested: model.suggestedLevel)
                }
                if model.day.main == .stretch {
                    StretchVariantSelector(standing: $model.standingStretch)
                }
                SegmentList(rows: model.rows, onSwap: model.swap)
                if model.place == .outdoors && model.isWalkDay {
                    Text("After your walk, you can do your chair moves at home from All sessions.")
                        .typeRole(.body)
                        .foregroundStyle(Palette.text)
                }
                if !pinsActions { actions }
            }
            .padding(Metrics.screenMargin)
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity)
        }
        .pinnedActions(pinsActions) { actions }
        .screenBackground()
    }

    @ViewBuilder private var actions: some View {
        Button("Start now") { onStart(model.request) }.buttonStyle(.primaryAction)
        if let remindAt {
            Button(String(localized: "Remind me at \(remindAt.formatted(date: .omitted, time: .shortened))"), action: onRemindLater)
                .buttonStyle(.smallTextLink)
        }
    }

    /// The coach in the place and kind of session picked, so the picture follows the choices.
    private var heroArt: Art {
        switch model.day.main {
        case .chair: return .walkerSeatedMarch
        case .stretch: return model.standingStretch ? .walkerCalfStretch : .walkerRest
        default:
            return switch model.place {
            case .outdoors: .sceneOutdoors
            case .pad: .sceneWalkingPad
            case .indoors: model.level == .seated ? .walkerSeatedMarch : .sceneLivingRoom
            }
        }
    }
}

/// Two or three choices side by side as picture tiles; stacked cards at accessibility text sizes.
struct ChoiceRow<Tiles: View, Cards: View>: View {
    @ViewBuilder let tiles: () -> Tiles
    @ViewBuilder let cards: () -> Cards
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if typeSize.isAccessibilitySize {
            VStack(spacing: Metrics.touchSpacing) { cards() }
        } else {
            HStack(alignment: .top, spacing: 10) { tiles() }
        }
    }
}

/// "Where are you walking today?" · Indoors · Outdoors · Walking pad, each with its painting.
struct PlaceSelector: View {
    @Binding var place: WorkoutPlace

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Where are you walking today?").typeRole(.cardTitle).foregroundStyle(Palette.text)
            ChoiceRow {
                PictureTile(art: .sceneLivingRoom, title: "Indoors", isSelected: place == .indoors) { place = .indoors }
                PictureTile(art: .sceneOutdoors, title: "Outdoors", isSelected: place == .outdoors) { place = .outdoors }
                PictureTile(art: .sceneWalkingPad, title: "Walking pad", isSelected: place == .pad) { place = .pad }
            } cards: {
                PictureChoiceCard(art: .sceneLivingRoom, title: "Indoors", isSelected: place == .indoors) { place = .indoors }
                PictureChoiceCard(art: .sceneOutdoors, title: "Outdoors", isSelected: place == .outdoors) { place = .outdoors }
                PictureChoiceCard(art: .sceneWalkingPad, title: "Walking pad", isSelected: place == .pad) { place = .pad }
            }
        }
    }
}

/// "How will you walk today?" · Seated (in a chair) · In place (standing, marching on the spot);
/// the suggested one says so (clarity review D9: the tiles had no question and "In place" was jargon).
struct LevelSelector: View {
    @Binding var level: WalkLevel
    let suggested: WalkLevel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How will you walk today?").typeRole(.cardTitle).foregroundStyle(Palette.text)
            ChoiceRow {
                tile(.seated, art: .walkerSeatedMarch)
                tile(.inPlace, art: .walkerMarch)
            } cards: {
                card(.seated, art: .walkerSeatedMarch)
                card(.inPlace, art: .walkerMarch)
            }
        }
    }

    private func subtitle(_ value: WalkLevel) -> LocalizedStringResource {
        switch (value, value == suggested) {
        case (.seated, true): "In a chair · suggested for you"
        case (.seated, false): "In a chair"
        case (_, true): "Standing, on the spot · suggested for you"
        default: "Standing, on the spot"
        }
    }

    private func tile(_ value: WalkLevel, art: Art) -> some View {
        PictureTile(art: art, title: value.title, subtitle: subtitle(value), isSelected: level == value) { level = value }
    }

    private func card(_ value: WalkLevel, art: Art) -> some View {
        PictureChoiceCard(art: art, title: value.title, subtitle: subtitle(value), isSelected: level == value) { level = value }
    }
}

/// Stretch day: Seated (default) · Standing, holding the chair.
struct StretchVariantSelector: View {
    @Binding var standing: Bool

    var body: some View {
        ChoiceRow {
            PictureTile(art: .walkerRest, title: "Seated", isSelected: !standing) { standing = false }
            PictureTile(art: .walkerBehindChair, title: "Standing, holding the chair", isSelected: standing) { standing = true }
        } cards: {
            PictureChoiceCard(art: .walkerRest, title: "Seated", isSelected: !standing) { standing = false }
            PictureChoiceCard(art: .walkerBehindChair, title: "Standing, holding the chair", isSelected: standing) { standing = true }
        }
    }
}

/// The parts of the session in order, with Swap on chair moves.
struct SegmentList: View {
    let rows: [PreviewRow]
    let onSwap: (String) -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(spacing: 0) {
            ForEach(rows) { row in
                HStack(spacing: 12) {
                    // At accessibility sizes: no icon, and Swap under the name, so no word breaks.
                    if !typeSize.isAccessibilitySize { IconChip(symbol: row.symbol) }
                    VStack(alignment: .leading, spacing: 0) {
                        Text(verbatim: row.title).typeRole(.body).fontWeight(.semibold)
                        Text(verbatim: row.detail).typeRole(.caption).foregroundStyle(Palette.textMuted)
                        if typeSize.isAccessibilitySize { swap(row) }
                    }
                    .foregroundStyle(Palette.text)
                    Spacer(minLength: 0)
                    if !typeSize.isAccessibilitySize { swap(row) }
                }
                .padding(.vertical, 8)
                .accessibilityElement(children: .combine)
                if row.id != rows.last?.id { Divider() }
            }
        }
        .cardStyle(padding: 12)
    }

    @ViewBuilder private func swap(_ row: PreviewRow) -> some View {
        if let id = row.swappableExerciseID {
            // A real button, 56 pt, not a small link (task 1.12).
            Button("Swap") { onSwap(id) }.buttonStyle(PillButtonStyle())
                .accessibilityLabel(Text("Swap \(row.title)"))
        }
    }
}
