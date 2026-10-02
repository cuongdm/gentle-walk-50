import Foundation
import GentleWalkCore

/// Everything S15 shows, worked out once from the completion result.
struct CompleteContent: Equatable {
    enum Variant: Equatable { case regular, firstWalk, stretch, outdoors, stoppedForPain }

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

    /// - Parameter stoppedForPain: ended from This hurts → Stop for today: a calm screen, no cheer
    ///   (it celebrated a session she stopped because it hurt; review 02/10/2026).
    init(result: CompletionResult, request: WorkoutRequest, minutes: Int, name: String?, content: ContentBundle,
         comparison: String? = nil, stoppedForPain: Bool = false) {
        self.minutes = minutes
        activeDays = result.activeDays
        reachedLevel = result.reachedLevel
        newPostcard = result.unlockedStops.last
        self.comparison = request.day.main == .stretch ? nil : comparison

        if stoppedForPain {
            variant = .stoppedForPain
            title = String(localized: "Good call to stop.")
            subtitle = String(localized: "Today still counts. Rest now, and take it easy.")
        } else if request.isFirstWalk {
            variant = .firstWalk
            title = String(localized: "That's your first walk!")
            // The real minutes: she may have ended it early (it always said five; review 02/10/2026).
            subtitle = String(localized: "\(Plural.minutes(minutes)). You showed up, and that's the hardest part.")
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
        if variant == .outdoors || (variant == .stoppedForPain && request.place == .outdoors) {
            milesText = miles
            milesLabel = String(localized: "walked")
        } else {
            milesText = String(localized: "+\(miles)")
            milesLabel = String(localized: "on your journey")
        }

        let journey = content.journeys.first { $0.id == result.journeyID }
        if let journey, let last = journey.stops.last, last.mile > 0 {
            destination = last.name
            journeyProgress = min(1, result.routeMiles / last.mile)
            journeyLine = result.journeyComplete
                ? String(localized: "You made it to \(last.name)!")
                : JourneyText.progress(routeMiles: result.routeMiles, journey: journey,
                                       limit: result.routeLimit)
        } else {
            journeyProgress = 0
        }

        let place = destination ?? String(localized: "the next stop")
        let minutesText = Duration.seconds(minutes * 60).formatted(.units(allowed: [.minutes], width: .wide))
        switch (name, variant) {
        case (let name?, .outdoors): shareLine = String(localized: "\(name) walked \(miles) today.")
        case (nil, .outdoors): shareLine = String(localized: "A \(miles) walk today.")
        case (let name?, _): shareLine = String(localized: "\(name) moved for \(minutesText) today, on the way to \(place).")
        case (nil, _): shareLine = String(localized: "\(minutesText) of moving today, on the way to \(place).")
        }
    }

    /// Miles shown in the user's unit ("2.6 mi" / "4.2 km"); `trimmed` drops a trailing ".0" ("5 mi").
    static func miles(_ value: Double, trimmed: Bool = false) -> String {
        DistanceText.text(miles: value, trimmed: trimmed)
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
