import SwiftUI
import GentleWalkCore

/// S10 Workout preview: title by check-in, where you're walking, level, the list of parts with
/// Swap on chair moves, Start now and Remind me later.
struct WorkoutPreviewView: View {
    @Bindable var model: WorkoutPreviewModel
    let onStart: (WorkoutRequest) -> Void
    let onRemindLater: () -> Void
    var onClose: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                    Button("Close", action: onClose).buttonStyle(.smallTextLink)
                }
                ArtImage(art: heroArt, height: 170)
                ScreenHeaderText(title: model.title, subtitle: model.subtitle)
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
                    Text("Your chair moves will be waiting when you're home.")
                        .typeRole(.body)
                        .foregroundStyle(Palette.text)
                }
                Button("Start now") { onStart(model.request) }.buttonStyle(.primaryAction)
                Button("Remind me later", action: onRemindLater).buttonStyle(.secondaryAction)
            }
            .padding(Metrics.screenMargin)
        }
        .screenBackground()
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

/// "Where are you walking today?" · Indoors · Outdoors · Walking pad, each with its painting.
struct PlaceSelector: View {
    @Binding var place: WorkoutPlace

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Where are you walking today?").typeRole(.cardTitle).foregroundStyle(Palette.text)
            PictureChoiceCard(art: .sceneLivingRoom, title: "Indoors", subtitle: "Walk in place at home",
                              isSelected: place == .indoors) { place = .indoors }
            PictureChoiceCard(art: .sceneOutdoors, title: "Outdoors", subtitle: "Optional, on a walk outside",
                              isSelected: place == .outdoors) { place = .outdoors }
            PictureChoiceCard(art: .sceneWalkingPad, title: "Walking pad",
                              isSelected: place == .pad) { place = .pad }
        }
    }
}

/// Seated · In place, the suggested one labelled "Suggested".
struct LevelSelector: View {
    @Binding var level: WalkLevel
    let suggested: WalkLevel

    var body: some View {
        VStack(spacing: Metrics.touchSpacing) {
            option(.seated, art: .walkerSeatedMarch)
            option(.inPlace, art: .walkerMarch)
        }
    }

    private func option(_ value: WalkLevel, art: Art) -> some View {
        PictureChoiceCard(art: art, title: value.title, subtitle: value == suggested ? "Suggested" : nil,
                          isSelected: level == value) { level = value }
    }
}

/// Stretch day: Seated (default) · Standing, holding the chair.
struct StretchVariantSelector: View {
    @Binding var standing: Bool

    var body: some View {
        VStack(spacing: Metrics.touchSpacing) {
            PictureChoiceCard(art: .walkerRest, title: "Seated", isSelected: !standing) { standing = false }
            PictureChoiceCard(art: .walkerBehindChair, title: "Standing, holding the chair", isSelected: standing) { standing = true }
        }
    }
}

/// The parts of the session in order, with Swap on chair moves.
struct SegmentList: View {
    let rows: [PreviewRow]
    let onSwap: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(rows) { row in
                HStack(spacing: 12) {
                    IconChip(symbol: row.symbol)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(verbatim: row.title).typeRole(.body).fontWeight(.semibold)
                        Text(verbatim: row.detail).typeRole(.caption).foregroundStyle(Palette.textMuted)
                    }
                    .foregroundStyle(Palette.text)
                    Spacer(minLength: 0)
                    if let id = row.swappableExerciseID {
                        Button("Swap") { onSwap(id) }.buttonStyle(.smallTextLink)
                            .accessibilityLabel(Text("Swap \(row.title)"))
                    }
                }
                .padding(.vertical, 8)
                .accessibilityElement(children: .combine)
                if row.id != rows.last?.id { Divider() }
            }
        }
        .cardStyle(padding: 12)
    }
}
