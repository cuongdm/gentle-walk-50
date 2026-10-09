import Foundation
import GentleWalkCore

/// The words of the stage recaps (docs/plans/2026-10-09-plan-journey-link.md). Count up only, never a loss;
/// journey miles read as Complete says them ("on your journey"), outdoor miles as "walked outdoors"; a check
/// is her own number, with "+N since your first check" only when it went up. No fall, bone or pain words.
enum StageRecapText {
    /// "Stage 1 is done: Steady base"
    static func doneTitle(_ stage: ProgramStage) -> String {
        String(localized: "Stage \(stage.rawValue) is done: \(String(localized: stage.title))")
    }

    /// "Stage 1 · Steady base"
    static func name(_ stage: ProgramStage) -> String {
        String(localized: "Stage \(stage.rawValue) · \(String(localized: stage.title))")
    }

    /// "11 active days · 2 hr, 15 min moving"
    static func activity(_ recap: StageRecap) -> String {
        "\(Plural.activeDays(recap.activeDays)) · \(moving(recap.activeSeconds))"
    }

    /// "2 hr, 15 min moving"
    static func moving(_ seconds: Int) -> String {
        String(localized: "\(time(seconds)) moving")
    }

    /// "2 hr, 15 min" or "48 min", in her language.
    static func time(_ seconds: Int) -> String {
        let minutes = max(1, Int((Double(seconds) / 60).rounded()))
        return Duration.seconds(minutes * 60).formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
    }

    /// "6.8 mi on your journey", and "1.2 mi of it walked outdoors" when she walked outside; nil under a tenth.
    static func miles(_ journeyMiles: Double, outdoor: Double) -> String? {
        guard journeyMiles >= 0.05 else { return nil }
        let total = CompleteContent.miles(journeyMiles)
        guard outdoor >= 0.05 else { return String(localized: "\(total) on your journey") }
        return String(localized: "\(total) on your journey, \(CompleteContent.miles(outdoor)) of it walked outdoors")
    }

    /// "You reached Times Square and Bryant Park."; past three stops "You reached 5 stops, the latest Union
    /// Square." (the postcards beside it show them); nil without a stop.
    static func stops(_ stops: [StageRecap.Stop]) -> String? {
        guard let last = stops.last else { return nil }
        if stops.count <= 3 { return String(localized: "You reached \(names(stops)).") }
        return String(localized: "You reached \(Plural.stops(stops.count)), the latest \(last.name).")
    }

    /// "Times Square, Bryant Park and Union Square", in her language.
    static func names(_ stops: [StageRecap.Stop]) -> String {
        stops.map(\.name).formatted(.list(type: .and))
    }

    /// "Your 2-week check: 8"
    static func check(_ check: StageRecap.Check) -> String {
        String(localized: "Your 2-week check: \(check.count)")
    }

    /// "+1 since your first check", only when it went up (never a loss line).
    static func checkGain(_ check: StageRecap.Check) -> String? {
        guard let since = check.sinceFirst, since > 0 else { return nil }
        return String(localized: "+\(since) since your first check")
    }

    /// "You're now in Stage 2 · Building strength. Your sessions change only when you're ready." A stage is a
    /// label: it never raises reps or support by itself.
    static func nowIn(after stage: ProgramStage) -> String? {
        guard let next = ProgramStage(rawValue: stage.rawValue + 1) else { return nil }
        return String(localized: "You're now in Stage \(next.rawValue) · \(String(localized: next.title)). Your sessions change only when you're ready.")
    }

    /// "Next stop: Brooklyn Bridge · 0.2 mi to go"; nil when the route is done or the next stop needs Pro.
    static func nextStop(_ route: RoutePosition) -> String? {
        guard let name = route.nextStop, let miles = route.milesToNext, miles > 0 else { return nil }
        return String(localized: "Next stop: \(name) · \(CompleteContent.miles(miles)) to go")
    }

    /// "24.6 mi on your journey · 9 stops"
    static func wholeRoute(_ whole: RoundRecap) -> String {
        let miles = miles(whole.journeyMiles, outdoor: 0) ?? String(localized: "\(CompleteContent.miles(0)) on your journey")
        return whole.stops.isEmpty ? miles : "\(miles) · \(Plural.stops(whole.stops.count))"
    }

    /// "From Central Park Zoo to Laurel Falls."; nil with fewer than two stops.
    static func fromTo(_ whole: RoundRecap) -> String? {
        guard let first = whole.first, let last = whole.last, first.id != last.id else { return nil }
        return String(localized: "From \(first.name) to \(last.name).")
    }
}
