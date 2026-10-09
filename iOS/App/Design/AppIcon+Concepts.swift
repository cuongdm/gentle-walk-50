import GentleWalkCore

/// Which `AppIcon` stands for each thing the screens show (plan 08/10/2026 task 3.2): one place, so a
/// session kind, a reminder moment or a Today notice always gets the same picture. `AppIconConceptTests`
/// keeps one meaning per picture.
extension AppIcon {
    /// The kind of today's session; a seated walk shows the armchair, not a walking figure.
    static func session(_ main: PlannedDay.Main?, seated: Bool) -> AppIcon {
        switch main {
        case .chair: .chair
        case .stretch: .stretch
        case .longWalk: .longWalk
        case .walk, nil: seated ? .seated : .walk
        }
    }

    /// Reminder moments (S16, Me): the coffee cup, the plate, the TV, the clock.
    static func moment(_ moment: DailyMoment) -> AppIcon {
        switch moment {
        case .coffee: .coffee
        case .lunch: .lunch
        case .tv: .eveningTV
        case .custom: .time
        }
    }

    /// A notice on Today, by what it is about.
    static func special(_ card: TodaySpecialCard) -> AppIcon {
        switch card {
        // A move set aside after she reported pain: the same hand as "This hurts".
        case .pain, .setAside: .hurts
        case .shorter, .movedDown: .levelDown
        case .movedUp: .levelUp
        // A stage of the 12-week program ended: the program's calendar.
        case .stageDone: .program
        case .connectHealth: .health
        case .busyDay: .steps
        case .moveReminder, .fewerReminders: .reminder
        case .longerWalk: .longWalk
        }
    }
}
