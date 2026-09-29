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
}

/// "Where are you walking today?" · Indoors · Outdoors · Walking pad.
struct PlaceSelector: View {
    @Binding var place: WorkoutPlace

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Where are you walking today?").typeRole(.cardTitle).foregroundStyle(Palette.text)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: Metrics.touchSpacing) { tiles }
                VStack(spacing: Metrics.touchSpacing) { tiles }
            }
        }
    }

    @ViewBuilder private var tiles: some View {
        PlaceTile(title: "Indoors", symbol: "house.fill", isSelected: place == .indoors) { place = .indoors }
        PlaceTile(title: "Outdoors", symbol: "tree.fill", isSelected: place == .outdoors) { place = .outdoors }
        PlaceTile(title: "Walking pad", symbol: "figure.walk.treadmill", isSelected: place == .pad) { place = .pad }
    }
}

private struct PlaceTile: View {
    let title: LocalizedStringResource
    let symbol: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: symbol).typeRole(.cardTitle).accessibilityHidden(true)
                Text(title).typeRole(.body).fontWeight(.semibold).multilineTextAlignment(.center)
            }
            .foregroundStyle(Palette.text)
            .frame(maxWidth: .infinity, minHeight: 88)
            .padding(.horizontal, 6)
            .background(Palette.surface, in: .rect(cornerRadius: Metrics.cardRadius))
            .overlay {
                RoundedRectangle(cornerRadius: Metrics.cardRadius)
                    .strokeBorder(isSelected ? Palette.primary : Palette.textMuted.opacity(0.25), lineWidth: isSelected ? 3 : 1)
            }
            .contentShape(.rect(cornerRadius: Metrics.cardRadius))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// Seated · In place, the suggested one labelled "Suggested".
struct LevelSelector: View {
    @Binding var level: WalkLevel
    let suggested: WalkLevel

    var body: some View {
        HStack(spacing: Metrics.touchSpacing) {
            option(.seated)
            option(.inPlace)
        }
    }

    private func option(_ value: WalkLevel) -> some View {
        Button { level = value } label: {
            VStack(spacing: 2) {
                Text(value.title)
                if value == suggested {
                    Text("Suggested").typeRole(.caption)
                }
            }
        }
        .buttonStyle(PillButtonStyle(isSelected: level == value))
        .frame(maxWidth: .infinity)
        .accessibilityAddTraits(level == value ? .isSelected : [])
    }
}

/// Stretch day: Seated (default) · Standing, holding the chair.
struct StretchVariantSelector: View {
    @Binding var standing: Bool

    var body: some View {
        VStack(spacing: Metrics.touchSpacing) {
            SelectableCard(title: "Seated", symbol: "chair.fill", isSelected: !standing) { standing = false }
            SelectableCard(title: "Standing, holding the chair", symbol: "figure.stand", isSelected: standing) { standing = true }
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
                    Image(systemName: row.symbol)
                        .typeRole(.cardTitle)
                        .foregroundStyle(Palette.secondary)
                        .frame(width: 48, height: 48)
                        .background(Palette.secondary.opacity(0.12), in: .rect(cornerRadius: 12))
                        .accessibilityHidden(true)
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
