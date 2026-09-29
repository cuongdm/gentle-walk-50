import Foundation
import GentleWalkCore

/// Everything S15 shows, worked out once from the completion result.
struct CompleteContent: Equatable {
    enum Variant: Equatable { case regular, firstWalk, stretch, outdoors }

    var variant: Variant
    var title: String
    var subtitle: String?
    var minutes: Int
    /// Middle stat: journey miles for this session ("+0.6 mi"), or real miles outdoors ("0.9 mi").
    var milesText: String
    var milesLabel: String
    var activeDays: Int
    var comparison: String?
    var journeyLine: String?
    var journeyProgress: Double
    var destination: String?
    var newPostcard: Journey.Stop?
    var reachedLevel: TreeLevel?
    var shareLine: String

    init(result: CompletionResult, request: WorkoutRequest, minutes: Int, name: String?, content: ContentBundle,
         comparison: String? = nil) {
        self.minutes = minutes
        activeDays = result.activeDays
        reachedLevel = result.reachedLevel
        newPostcard = result.unlockedStops.last
        self.comparison = request.day.main == .stretch ? nil : comparison

        if request.isFirstWalk {
            variant = .firstWalk
            title = String(localized: "That's your first walk!")
            subtitle = String(localized: "Five minutes. You showed up, and that's the hardest part.")
        } else if request.place == .outdoors {
            variant = .outdoors
            title = name.map { String(localized: "Lovely walk, \($0)!") } ?? String(localized: "Lovely walk!")
        } else if request.day.main == .stretch {
            variant = .stretch
            title = name.map { String(localized: "Nice and easy, \($0).") } ?? String(localized: "Nice and easy.")
        } else {
            variant = .regular
            title = name.map { String(localized: "You did it, \($0)!") } ?? String(localized: "You did it!")
        }

        let miles = Self.miles(result.sessionMiles)
        if variant == .outdoors {
            milesText = miles
            milesLabel = String(localized: "walked")
        } else {
            milesText = String(localized: "+\(miles)")
            milesLabel = String(localized: "on your journey")
        }

        let journey = content.journeys.first { $0.id == result.journeyID }
        if let journey, let last = journey.stops.last, last.mile > 0 {
            destination = last.name
            let left = max(0, last.mile - result.routeMiles)
            journeyProgress = min(1, result.routeMiles / last.mile)
            journeyLine = result.journeyComplete
                ? String(localized: "You made it to \(last.name)!")
                : String(localized: "\(Self.miles(left)) to \(last.name)")
        } else {
            journeyProgress = 0
        }

        let place = destination ?? String(localized: "the next stop")
        let minutesText = Duration.seconds(minutes * 60).formatted(.units(allowed: [.minutes], width: .wide))
        switch (name, variant) {
        case (let name?, .outdoors): shareLine = String(localized: "\(name) walked \(miles) today.")
        case (nil, .outdoors): shareLine = String(localized: "A \(miles) walk today.")
        case (let name?, _): shareLine = String(localized: "\(name) walked \(minutesText) today, on the way to \(place).")
        case (nil, _): shareLine = String(localized: "\(minutesText) of walking today, on the way to \(place).")
        }
    }

    /// "2.6 mi" in the user's units; `trimmed` drops a trailing ".0" ("5 mi").
    static func miles(_ value: Double, trimmed: Bool = false) -> String {
        let digits: ClosedRange<Int> = trimmed ? 0...1 : 1...1
        return Measurement(value: value, unit: UnitLength.miles)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(digits))))
    }
}

extension TreeLevel {
    var title: LocalizedStringResource {
        switch self {
        case .seed: "Seed"
        case .sprout: "Sprout"
        case .sapling: "Sapling"
        case .tree: "Tree"
        }
    }

    var symbol: String {
        switch self {
        case .seed: "circle.dotted"
        case .sprout: "leaf"
        case .sapling: "leaf.fill"
        case .tree: "tree.fill"
        }
    }
}
