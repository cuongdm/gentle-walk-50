import Foundation
@testable import GentleWalkCore

/// Shared helpers for core tests: fixed calendars and dates, the New York journey.
enum TestSupport {
    static func calendar(_ identifier: String) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: identifier)!
        calendar.locale = Locale(identifier: "en_US")
        return calendar
    }

    static let newYork = calendar("America/New_York")
    static let hoChiMinh = calendar("Asia/Ho_Chi_Minh")

    /// A date from an ISO 8601 string with offset, e.g. "2026-09-29T10:00:00Z".
    static func date(_ iso: String) -> Date {
        try! Date(iso, strategy: .iso8601)
    }

    /// Local wall-clock date in a calendar.
    static func local(_ calendar: Calendar, _ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    static let newYorkJourney = Journey(id: "jr.ny", title: "New York City", isFree: true, stops: [
        .init(id: "pc.ny.zoo", name: "Central Park Zoo", mile: 0),
        .init(id: "pc.ny.bethesda", name: "Bethesda Fountain", mile: 1.0),
        .init(id: "pc.ny.times", name: "Times Square", mile: 2.2),
        .init(id: "pc.ny.bryant", name: "Bryant Park", mile: 2.8),
        .init(id: "pc.ny.union", name: "Union Square", mile: 3.9),
        .init(id: "pc.ny.bridge", name: "Brooklyn Bridge", mile: 5.0),
    ])

    static let paidJourney = Journey(id: "jr.smoky", title: "Smoky Mountains", isFree: false, stops: [
        .init(id: "pc.smoky.1", name: "Cades Cove", mile: 0),
        .init(id: "pc.smoky.2", name: "Laurel Falls", mile: 2.4),
        .init(id: "pc.smoky.3", name: "Clingmans Dome", mile: 4.8),
        .init(id: "pc.smoky.4", name: "Mingus Mill", mile: 7.2),
        .init(id: "pc.smoky.5", name: "Mabry Mill", mile: 9.6),
        .init(id: "pc.smoky.6", name: "Linn Cove Viaduct", mile: 12.0),
    ])
}

extension TestSupport {
    private struct Files: Decodable {
        var voiceLines: [VoiceLine]?
        var exercises: [Exercise]?
        var journeys: [Journey]?
        var sessions: [SessionTemplate]?
    }

    /// The app's real generated content (App/Resources/Content), the single source of truth.
    static let appContent: ContentBundle = {
        let dir = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("App/Resources/Content")
        func load(_ name: String) -> Files {
            try! JSONDecoder().decode(Files.self, from: Data(contentsOf: dir.appendingPathComponent(name + ".json")))
        }
        return ContentBundle(
            exercises: load("exercises").exercises!,
            journeys: load("journeys").journeys!,
            voiceLines: load("voice-lines").voiceLines!,
            sessions: load("sessions").sessions!
        )
    }()

    static func exercise(_ id: String) -> Exercise {
        appContent.exercises.first { $0.id == id }!
    }

    /// The repository root (…/Tests/GentleWalkCoreTests/TestSupport.swift is six levels down).
    static let repositoryRoot: URL = {
        var url = URL(fileURLWithPath: #filePath)
        for _ in 0..<6 { url.deleteLastPathComponent() }
        return url
    }()

    /// Every Vietnamese UI translation the app will get (docs/i18n/vi/ui*.json, English key → Vietnamese).
    static func vietnameseUI() throws -> [String: String] {
        let folder = repositoryRoot.appendingPathComponent("docs/i18n/vi")
        let files = try FileManager.default.contentsOfDirectory(atPath: folder.path)
            .filter { $0.hasPrefix("ui") && $0.hasSuffix(".json") }
        var all: [String: String] = [:]
        for file in files {
            let data = try Data(contentsOf: folder.appendingPathComponent(file))
            all.merge(try JSONDecoder().decode([String: String].self, from: data)) { first, _ in first }
        }
        return all
    }
}

