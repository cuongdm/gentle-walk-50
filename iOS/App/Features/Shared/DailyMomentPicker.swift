import SwiftUI

/// "What's a good moment for your daily walk?" Four moments as a 2 × 2 grid of tiles and the reminder
/// time on one line (owner 01/10: four full-width cards and a two-line time block made the screen
/// long). The time can be typed (tap it), while − / + go to the next quarter hour (owner 30/09/2026).
/// One column at accessibility text sizes. Used on S16, beside "Allow reminders", and in Me.
struct DailyMomentPicker: View {
    let moment: DailyMoment
    let minutes: Int
    let onChoose: (DailyMoment) -> Void
    let onStep: (Int) -> Void
    let onSet: (Int) -> Void
    /// The question as the title; S16 puts it in the card's own header with an icon.
    var showsQuestion = true

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if showsQuestion {
                Text("What's a good moment for your daily walk?").typeRole(.cardTitle).foregroundStyle(Palette.text)
            }
            let columns = typeSize.isAccessibilitySize ? [GridItem(.flexible())] : [GridItem(.flexible(), spacing: 8), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(DailyMoment.allCases) { value in
                    MomentTile(title: OnboardingCopy.title(value), isSelected: moment == value) { onChoose(value) }
                }
            }
            HStack(spacing: 10) {
                Text("One gentle reminder a day, at:").typeRole(.caption).foregroundStyle(Palette.textMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                StepButton(symbol: "minus", label: "Earlier") { onStep(-1) }
                DatePicker(selection: timeBinding, displayedComponents: .hourAndMinute) {
                    Text("Reminder time")
                }
                .labelsHidden()
                .datePickerStyle(.compact)
                .fixedSize()
                StepButton(symbol: "plus", label: "Later") { onStep(1) }
            }
            .cardStyle(padding: 10)
        }
    }

    /// Minutes after midnight as a time of today, for the picker.
    private var timeBinding: Binding<Date> {
        Binding(
            get: { Calendar.current.startOfDay(for: .now).addingTimeInterval(TimeInterval(minutes * 60)) },
            set: { date in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
                onSet((parts.hour ?? 0) * 60 + (parts.minute ?? 0))
            })
    }

    static func time(_ minutes: Int) -> String {
        let date = Calendar.current.date(bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: .now) ?? .now
        return date.formatted(date: .omitted, time: .shortened)
    }
}

/// A daily moment: a tile with a tick when chosen, two lines at most.
private struct MomentTile: View {
    let title: LocalizedStringResource
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 6) {
                Text(title).typeRole(.body).fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Palette.primary : Palette.textMuted)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(Palette.text)
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
            .background {
                RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
                    .fill(isSelected ? Palette.secondary.opacity(0.12) : Palette.surface)
            }
            .overlay {
                RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
                    .strokeBorder(isSelected ? Palette.primary : Palette.textMuted.opacity(0.3), lineWidth: isSelected ? 3 : 1.5)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

private struct StepButton: View {
    let symbol: String
    let label: LocalizedStringResource
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .typeRole(.cardTitle)
                .foregroundStyle(Palette.onStrongFill)
                .frame(width: 56, height: 56)
                .background(Palette.secondary, in: .circle)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
    }
}
