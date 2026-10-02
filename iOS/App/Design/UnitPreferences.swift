import Foundation

/// Me → Language & units (owner 02/10/2026): distance (miles / kilometres), weight (lb / kg) and
/// height (ft / cm). The first choice follows the iPhone's region; Me changes it. Distances are kept
/// in miles inside the app (journeys and outdoor walks) and shown in the chosen unit.
struct UnitPreferences: Equatable {
    enum Distance: String, CaseIterable, Identifiable { case miles, kilometers; var id: String { rawValue } }
    enum Weight: String, CaseIterable, Identifiable { case pounds, kilograms; var id: String { rawValue } }
    enum Height: String, CaseIterable, Identifiable { case feetInches, centimeters; var id: String { rawValue } }

    var distance: Distance
    var weight: Weight
    var height: Height

    static let distanceKey = "unitDistance"
    static let weightKey = "unitWeight"
    static let heightKey = "unitHeight"

    /// US: miles, pounds, feet. UK: miles, kilograms, centimetres. Elsewhere: metric.
    static func regionDefault(_ locale: Locale = .autoupdatingCurrent) -> UnitPreferences {
        switch locale.measurementSystem {
        case .us: UnitPreferences(distance: .miles, weight: .pounds, height: .feetInches)
        case .uk: UnitPreferences(distance: .miles, weight: .kilograms, height: .centimeters)
        default: UnitPreferences(distance: .kilometers, weight: .kilograms, height: .centimeters)
        }
    }

    init(distance: Distance, weight: Weight, height: Height) {
        self.distance = distance; self.weight = weight; self.height = height
    }

    init(defaults: UserDefaults = .standard, locale: Locale = .autoupdatingCurrent) {
        let region = Self.regionDefault(locale)
        distance = defaults.string(forKey: Self.distanceKey).flatMap(Distance.init) ?? region.distance
        weight = defaults.string(forKey: Self.weightKey).flatMap(Weight.init) ?? region.weight
        height = defaults.string(forKey: Self.heightKey).flatMap(Height.init) ?? region.height
    }

    func save(to defaults: UserDefaults = .standard) {
        defaults.set(distance.rawValue, forKey: Self.distanceKey)
        defaults.set(weight.rawValue, forKey: Self.weightKey)
        defaults.set(height.rawValue, forKey: Self.heightKey)
    }

    /// What the screens read (formatting happens far from the settings).
    nonisolated(unsafe) static var current = UnitPreferences()
}

extension UnitPreferences.Distance {
    var title: LocalizedStringResource {
        switch self {
        case .miles: "Miles"
        case .kilometers: "Kilometers"
        }
    }

    var unit: UnitLength { self == .miles ? .miles : .kilometers }
}

extension UnitPreferences.Weight {
    var title: LocalizedStringResource {
        switch self {
        case .pounds: "Pounds (lb)"
        case .kilograms: "Kilograms (kg)"
        }
    }
}

extension UnitPreferences.Height {
    var title: LocalizedStringResource {
        switch self {
        case .feetInches: "Feet (ft)"
        case .centimeters: "Centimeters (cm)"
        }
    }
}

/// Distances on screen: kept in miles, shown in the chosen unit.
enum DistanceText {
    /// Miles → the chosen unit's value.
    static func value(miles: Double, unit: UnitPreferences.Distance = UnitPreferences.current.distance) -> Double {
        Measurement(value: miles, unit: UnitLength.miles).converted(to: unit.unit).value
    }

    /// "2.6 mi" / "4.2 km"; `trimmed` drops a trailing ".0" ("5 mi").
    static func text(miles: Double, trimmed: Bool = false, unit: UnitPreferences.Distance = UnitPreferences.current.distance) -> String {
        let digits: ClosedRange<Int> = trimmed ? 0...1 : 1...1
        return Measurement(value: value(miles: miles, unit: unit), unit: unit.unit)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(digits))))
    }

    /// The bare number in the chosen unit ("1.8" of "5 mi").
    static func number(miles: Double, unit: UnitPreferences.Distance = UnitPreferences.current.distance) -> String {
        value(miles: miles, unit: unit).formatted(.number.precision(.fractionLength(0...1)))
    }

    /// Minutes per mile → minutes per chosen unit.
    static func pace(minutesPerMile: Double?, unit: UnitPreferences.Distance = UnitPreferences.current.distance) -> Double? {
        guard let minutesPerMile else { return nil }
        return unit == .miles ? minutesPerMile : minutesPerMile / 1.609_344
    }
}
