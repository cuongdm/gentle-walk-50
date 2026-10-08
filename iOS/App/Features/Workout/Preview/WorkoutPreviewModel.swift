import Foundation
import Observation
import GentleWalkCore

/// One line of the S10 list: "Warm-up march · 2 min", "Sit-to-stand · 10 reps".
struct PreviewRow: Identifiable, Equatable {
    var id: String
    var title: String
    var detail: String
    var symbol: String
    /// Chair moves can be swapped for another move of the same group.
    var swappableExerciseID: String?
}

/// S10 Workout preview (task 4.2): place, level, the list of parts, and the request to start.
@Observable @MainActor final class WorkoutPreviewModel {
    let day: PlannedDay
    let intensity: Intensity
    let checkIn: CheckIn?
    let suggestedLevel: WalkLevel
    var place: WorkoutPlace { didSet { defaults.set(place.rawValue, forKey: Self.placeKey) } }
    var level: WalkLevel
    /// Stretch day: "Standing, holding the chair" instead of seated.
    var standingStretch = false
    private(set) var swaps: [String: String] = [:]
    /// Picked from "All sessions" or "Try something else"; kept on the request it starts.
    let presetID: String?

    @ObservationIgnored private let content: ContentBundle
    @ObservationIgnored private let limits: Set<BodyLimit>
    @ObservationIgnored private let rotationIndex: Int
    @ObservationIgnored private let minutesDelta: Int
    @ObservationIgnored private let defaults: UserDefaults
    /// Her rules, remembered swaps and the coach's opening (P1, P3, P5, P7, P12) from the request it opened with.
    @ObservationIgnored private let carried: WorkoutRequest?
    static let placeKey = "lastWorkoutPlace"

    init(day: PlannedDay, intensity: Intensity, checkIn: CheckIn?, suggestedLevel: WalkLevel, limits: Set<BodyLimit>,
         rotationIndex: Int, minutesDelta: Int = 0, content: ContentBundle, defaults: UserDefaults = .standard,
         presetID: String? = nil, standing: Bool = false, carrying: WorkoutRequest? = nil) {
        self.day = day
        self.intensity = intensity
        self.checkIn = checkIn
        self.suggestedLevel = suggestedLevel
        self.limits = limits
        self.rotationIndex = rotationIndex
        self.minutesDelta = minutesDelta
        self.content = content
        self.defaults = defaults
        place = defaults.string(forKey: Self.placeKey).flatMap(WorkoutPlace.init) ?? .indoors
        level = suggestedLevel == .pad ? .seated : suggestedLevel
        self.presetID = presetID
        standingStretch = standing
        carried = carrying
    }

    var isWalkDay: Bool { day.main == .walk || day.main == .longWalk }
    var showsPlaceQuestion: Bool { isWalkDay }
    var showsLevelSelector: Bool { isWalkDay && place == .indoors }

    var request: WorkoutRequest {
        var walkDay = day
        if place == .outdoors { walkDay = PlannedDay(main: day.main, chairMoves: 0, cooldown: false) }
        // Outdoors she walks on her feet: never the seated walk (review C).
        let chosen: WalkLevel = place == .pad ? .pad : place == .outdoors && isWalkDay ? .inPlace
            : (day.main == .stretch ? (standingStretch ? .inPlace : .seated) : level)
        var request = WorkoutRequest(day: walkDay, level: chosen, intensity: intensity, place: isWalkDay ? place : .indoors,
                                     limits: limits.union(day.main == .stretch && !standingStretch ? [.standingIsHard] : []),
                                     rotationIndex: rotationIndex, minutesDelta: minutesDelta)
        request.swaps = swaps
        request.presetID = presetID
        if let carried {
            request.exerciseRules = carried.exerciseRules
            request.swapMemory = carried.swapMemory
            request.opening = carried.opening
        }
        return request
    }

    private var plan: SessionPlan? { try? request.plan(content: content) }

    var minutes: Int { Int(((Double(plan?.totalSeconds ?? 0)) / 60).rounded()) }

    var title: String {
        if let preset = presetID.flatMap(SessionCatalog.preset(id:)), preset.variant != nil {
            return String(localized: "\(String(localized: preset.title)) · \(minutes) min")
        }
        return switch day.main {
        case .chair: String(localized: "Chair moves · \(minutes) min")
        case .stretch: String(localized: "Gentle stretch · \(minutes) min")
        default:
            switch intensity {
            case .gentle: String(localized: "Gentle walk · \(minutes) min")
            case .steady: String(localized: "Steady walk · \(minutes) min")
            case .strong: String(localized: "Strong walk · \(minutes) min")
            }
        }
    }

    var subtitle: String? {
        if day.main == .stretch {
            return standingStretch ? String(localized: "Standing, holding the chair.") : String(localized: "Seated, with a chair to hold on to.")
        }
        switch checkIn {
        case .achy: return String(localized: "Picked for an “Achy” day.")
        case .okay: return String(localized: "Picked for an “Okay” day.")
        case .great: return String(localized: "Picked for a “Great” day.")
        case nil: return nil
        }
    }

    var rows: [PreviewRow] {
        guard let plan else { return [] }
        var rows: [PreviewRow] = []
        let exercises = Dictionary(content.exercises.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        for block in plan.blocks {
            switch block.kind {
            case .walk:
                let warm = block.segments.filter { $0.kind == .intro || $0.kind == .warmup }.reduce(0) { $0 + $1.seconds }
                let intervals = block.segments.filter { $0.kind == .brisk || $0.kind == .easy }.reduce(0) { $0 + $1.seconds }
                let cool = block.segments.filter { $0.kind == .cooldown }.reduce(0) { $0 + $1.seconds }
                let outdoors = place == .outdoors
                let warmTitle = outdoors ? String(localized: "Warm-up stroll")
                    : place == .pad ? String(localized: "Warm-up walk") : String(localized: "Warm-up march")
                rows.append(PreviewRow(id: "warm", title: warmTitle,
                                       detail: Self.minutesText(warm), symbol: "figure.walk"))
                let quicker = block.segments.contains { $0.kind == .brisk }
                // "Quicker" everywhere, as the players say it (review C).
                let movesTitle = quicker ? String(localized: "Easy and quicker rounds") : String(localized: "Walking moves")
                rows.append(PreviewRow(id: "intervals", title: movesTitle,
                                       detail: Self.minutesText(intervals), symbol: "figure.walk.motion"))
                let isStretch: (SessionTemplate.Segment) -> Bool = { $0.kind == .cooldown && $0.exerciseID?.hasPrefix("st.") == true }
                let stretches = block.segments.contains(where: isStretch)
                if outdoors && stretches {
                    // Outdoors the walk ends with a slow walk, then one standing stretch: listed as they play.
                    let stretch = block.segments.filter(isStretch).reduce(0) { $0 + $1.seconds }
                    rows.append(PreviewRow(id: "cool", title: String(localized: "Cool-down walk"),
                                           detail: Self.minutesText(cool - stretch), symbol: "figure.cooldown"))
                    rows.append(PreviewRow(id: "cool-stretch", title: String(localized: "Cool-down stretch"),
                                           detail: Self.minutesText(stretch), symbol: "figure.flexibility"))
                } else {
                    rows.append(PreviewRow(id: "cool", title: stretches ? String(localized: "Cool-down and stretches")
                                           : String(localized: "Cool-down walk"), detail: Self.minutesText(cool),
                                           symbol: "figure.cooldown"))
                }
            case .chair:
                let warm = block.segments.filter { $0.kind == .warmup }.reduce(0) { $0 + $1.seconds }
                if warm > 0 {
                    rows.append(PreviewRow(id: "chair-warm", title: String(localized: "Warm-up march"),
                                           detail: Self.minutesText(warm), symbol: "figure.walk"))
                }
                // Catalog sessions with their own template (Balance) keep their moves.
                let swappable = request.variant == nil
                for (index, segment) in block.segments.enumerated() where segment.kind == .move {
                    guard let id = segment.exerciseID, let exercise = exercises[id] else { continue }
                    let detail = segment.reps.map { reps in
                        segment.sets.map { String(localized: "\($0) × \(reps) reps") } ?? String(localized: "\(reps) reps")
                    } ?? Self.secondsText(segment.seconds)
                    rows.append(PreviewRow(id: "move-\(index)-\(id)", title: exercise.name, detail: detail, symbol: "chair.fill",
                                           swappableExerciseID: swappable && exercise.kind == .move ? id : nil))
                }
            case .stretch:
                var seen = Set<String>()
                for segment in block.segments where segment.isExercise {
                    guard let id = segment.exerciseID, let exercise = exercises[id], seen.insert(id).inserted else { continue }
                    let hold = segment.hold ?? plan.holdSeconds ?? 20
                    let bilateral = segment.cues.contains { $0.line.hasPrefix("a10.switch") }
                    // A pose without a set hold shows its time to the nearest 5 s ("49 sec" read like a bug; review C).
                    let detail = hold == 0 ? Self.secondsText(max(5, Int((Double(segment.seconds) / 5).rounded()) * 5))
                        : bilateral ? String(localized: "\(hold) sec each side") : String(localized: "\(hold) sec")
                    rows.append(PreviewRow(id: "pose-\(id)", title: exercise.name, detail: detail, symbol: "figure.flexibility"))
                }
            case .cooldown:
                rows.append(PreviewRow(id: "cooldown", title: String(localized: "Cool-down stretch"),
                                       detail: Self.minutesText(block.seconds), symbol: "figure.cooldown"))
            case .steady:
                rows.append(PreviewRow(id: "steady", title: String(localized: "Steady set"),
                                       detail: Self.minutesText(block.seconds), symbol: "figure.stand"))
            }
        }
        return rows
    }

    /// Swap a chair move for the next allowed move not already in the session.
    func swap(_ exerciseID: String) {
        guard let plan else { return }
        let used = Set(plan.exerciseIDs)
        let aside = carried?.exerciseRules.setAsideIDs ?? []
        let moves = BodyLimitFilter.allowed(content.exercises, limits: limits).filter { $0.kind == .move && !aside.contains($0.id) }
            .map(\.id)
        guard let start = moves.firstIndex(of: exerciseID) else { return }
        let candidates = (moves[(start + 1)...] + moves[..<start]).filter { !used.contains($0) }
        guard let replacement = candidates.first else { return }
        let original = swaps.first { $0.value == exerciseID }?.key ?? exerciseID
        swaps[original] = replacement
    }

    static func minutesText(_ seconds: Int) -> String {
        let minutes = max(1, Int((Double(seconds) / 60).rounded()))
        return String(localized: "\(minutes) min")
    }

    static func secondsText(_ seconds: Int) -> String {
        seconds % 60 == 0 ? String(localized: "\(seconds / 60) min") : String(localized: "\(seconds) sec")
    }
}
