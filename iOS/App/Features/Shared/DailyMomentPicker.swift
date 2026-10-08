import SwiftUI

/// "What's a good moment for your daily walk?" Four moments on one sheet of notebook paper, each with its
/// picture (coffee, plate, TV, clock; `claude-design/Reminder.dc.html`, plan 08/10/2026 task 3.8), and the
/// reminder time on one line. The time can be typed (tap it), while − / + go to the next quarter hour
/// (owner 30/09/2026). Used on S16 ("Set my reminder") and in Me.
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
            // One sheet of paper: the four moments, then "Reminder at − 8:30 AM +" as its last line
            // (`claude-design/Reminder.dc.html`; two cards did not fit an iPhone SE above "Set my reminder").
            VStack(alignment: .leading, spacing: 0) {
                NotebookChoiceList(items: DailyMoment.allCases, title: OnboardingCopy.title, icon: AppIcon.moment,
                                   isSelected: { $0 == moment }, onTap: onChoose, showsPaper: false)
                // At accessibility sizes the words, the time and − / + each get a row (the one row ran off
                // the screen at XXL, plan 08/10/2026 task 1.13).
                Group {
                    if typeSize.isAccessibilitySize {
                        VStack(alignment: .leading, spacing: 8) {
                            timeLabel
                            timePicker
                            HStack(spacing: 12) { earlier; later }
                        }
                    } else {
                        // "Reminder at" on the line where it fits; on a small phone on its own line above
                        // − time + (it was dropped there, and the time read as unlabelled, review A).
                        ViewThatFits(in: .horizontal) {
                            HStack(spacing: 8) {
                                timeLabel.fixedSize()
                                Spacer(minLength: 4)
                                earlier
                                timePicker
                                later
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                timeLabel
                                HStack(spacing: 12) {
                                    earlier
                                    timePicker
                                    later
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .padding(.vertical, 6)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 2)
            .background { CardPaper() }
        }
    }

    private var timeLabel: some View {
        Text("Reminder at").typeRole(.body).fontWeight(.semibold).foregroundStyle(Palette.text)
    }

    private var earlier: some View { StepButton(symbol: "minus", label: "Earlier time") { onStep(-1) } }
    private var later: some View { StepButton(symbol: "plus", label: "Later time") { onStep(1) } }

    private var timePicker: some View {
        DatePicker(selection: timeBinding, displayedComponents: .hourAndMinute) {
            Text("Reminder time")
        }
        .labelsHidden()
        .datePickerStyle(.compact)
        .fixedSize()
    }

    /// Minutes after midnight as a time of today, for the picker.
    private var timeBinding: Binding<Date> {
        Binding(
            get: { Calendar.current.date(bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: .now) ?? .now },
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

/// A round − or + of 56 pt (reminder time, sound levels); faded when it cannot go further.
struct StepButton: View {
    let symbol: String
    let label: LocalizedStringResource
    let action: () -> Void
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .typeRole(.cardTitle)
                .foregroundStyle(Palette.onStrongFill)
                .frame(width: 56, height: 56)
                .background(Palette.secondary, in: .circle)
                .opacity(isEnabled ? 1 : 0.4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
    }
}
