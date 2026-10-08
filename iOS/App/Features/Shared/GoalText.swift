import Foundation
import GentleWalkCore

/// Her main goal echoed across the app (P4, plan 4.3): one short line on Today only when today's session
/// serves it, one on Complete, the goal on Progress, and the Everyday wins that fit it first. Never a
/// promise about health (copy rules, docs/design/steady-claims.md); onboarding owns the goal itself.
enum GoalText {
    /// The goal that leads: the first one she picked ("Not sure yet" leads nothing). Old profiles may
    /// hold several goals; new ones hold one.
    static func main(of goals: [Goal]) -> Goal? { goals.first { $0 != .notSure } }

    /// What today's session holds, as far as the goal lines care.
    struct SessionFit: Equatable {
        var isWalk: Bool
        var hasSitToStand: Bool
        var hasSteadySet: Bool
    }

    /// Under the session card's title; nil when the session does not serve the goal (never a stretch
    /// to make it fit).
    static func todayLine(_ goal: Goal?, session: SessionFit) -> String? {
        switch goal {
        case .chairs? where session.hasSitToStand: String(localized: "For getting up from chairs")
        case .steadier? where session.hasSteadySet: String(localized: "For steadier feet")
        case .moreEnergy? where session.isWalk, .grandkids? where session.isWalk:
            String(localized: "For more energy, one walk at a time")
        case .lessPain?: String(localized: "Gentle on your joints")
        case .loseWeight?: String(localized: "Minutes moved add up")
        default: nil
        }
    }

    /// One line on Complete (when there is no other comparison to show).
    static func completeLine(_ goal: Goal?) -> String? {
        switch goal {
        case .chairs?: String(localized: "One more session for getting up from chairs.")
        case .steadier?: String(localized: "One more session toward steadier feet.")
        case .lessPain?: String(localized: "Gentle movement, done your way.")
        case .loseWeight?: String(localized: "Your minutes keep adding up.")
        case .moreEnergy?: String(localized: "One more session for your energy.")
        case .grandkids?: String(localized: "One more session for keeping up with the grandkids.")
        case .notSure?, nil: nil
        }
    }

    /// Everyday wins that speak to the goal, first (`wins.json` ids).
    static func winOrder(_ goal: Goal?) -> [String] {
        switch goal {
        case .chairs?: ["win.1", "win.8"]
        case .steadier?: ["win.4", "win.8", "win.6"]
        case .lessPain?: ["win.6", "win.1"]
        case .loseWeight?, .moreEnergy?: ["win.3", "win.7", "win.2"]
        case .grandkids?: ["win.5", "win.2", "win.3"]
        case .notSure?, nil: []
        }
    }

    /// The wins with those for her goal first, the rest in their own order.
    static func sorted<Item>(_ wins: [Item], id: (Item) -> String, goal: Goal?) -> [Item] {
        let order = winOrder(goal)
        let ranked = wins.enumerated().map { (rank: order.firstIndex(of: id($0.element)) ?? order.count, offset: $0.offset, item: $0.element) }
        return ranked.sorted { ($0.rank, $0.offset) < ($1.rank, $1.offset) }.map(\.item)
    }
}
