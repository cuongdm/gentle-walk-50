import Foundation
import SwiftData
import Testing
import GentleWalkCore
@testable import GentleWalk

@MainActor final class FakeHealthWriter: WorkoutHealthWriting {
    private(set) var saved: [SessionSummary] = []
    func saveWorkout(_ summary: SessionSummary) async { saved.append(summary) }
}

@MainActor final class FakeRescheduler: NotificationRescheduling {
    private(set) var calls = 0
    func reschedule() async { calls += 1 }
}

@MainActor @Suite(.serialized) struct SessionCompletionServiceTests {
    let calendar = { var c = Calendar(identifier: .gregorian); c.timeZone = TimeZone(identifier: "America/New_York")!; return c }()

    /// Keeps each test's in-memory container alive (a context whose container is freed crashes).
    let container = try! ModelContainerFactory.make(inMemory: true)

    func service(entitlement: Entitlement = .subscribed) throws -> (SessionCompletionService, ModelContext, FakeHealthWriter, FakeRescheduler) {
        let context = container.mainContext
        let health = FakeHealthWriter()
        let notifications = FakeRescheduler()
        let service = SessionCompletionService(context: context, content: TestFixtures.content, entitlement: { entitlement },
                                               health: health, notifications: notifications, calendar: calendar)
        return (service, context, health, notifications)
    }

    func summary(minutes: Double, on date: Date, breaks: Int = 0) -> SessionSummary {
        SessionSummary(date: date, kind: .walk, level: .seated, intensity: .steady, place: .indoors,
                       activeSeconds: Int(minutes * 60), breakCount: breaks)
    }

    func day(_ d: Int, _ hour: Int = 9) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 9, day: d, hour: hour))!
    }

    @Test func twelveMinutesSavesARecordAndMovesTheJourney() async throws {
        let (service, context, health, notifications) = try service()
        let first = try await service.complete(summary(minutes: 12, on: day(28), breaks: 1))
        #expect(abs(first.sessionMiles - 0.6) < 0.0001)
        #expect(first.unlockedStops.map(\.id) == ["pc.ny.zoo"])
        #expect(first.isFirstWorkout)
        #expect(first.activeDays == 1)
        let records = try context.fetch(FetchDescriptor<WorkoutRecord>())
        #expect(records.count == 1)
        #expect(records[0].activeSeconds == 720)
        #expect(records[0].breakCount == 1)
        #expect(records[0].kind == "walk")
        let journey = try #require(try context.fetch(FetchDescriptor<JourneyState>()).first { $0.isCurrent })
        #expect(journey.journeyID == "jr.ny")
        #expect(abs(journey.miles - 0.6) < 0.0001)
        #expect(health.saved.count == 1)
        #expect(notifications.calls == 1)
    }

    @Test func crossingAStopUnlocksItsPostcard() async throws {
        let (service, context, _, _) = try service()
        _ = try await service.complete(summary(minutes: 12, on: day(21)))
        let second = try await service.complete(summary(minutes: 10, on: day(22)))  // 0.6 + 0.5 = 1.1 ≥ 1.0 Bethesda
        #expect(second.unlockedStops.map(\.id) == ["pc.ny.bethesda"])
        #expect(second.nextStop?.id == "pc.ny.times")
        #expect(second.activeDays == 2)
        let unlocks = try context.fetch(FetchDescriptor<PostcardUnlock>())
        #expect(Set(unlocks.map(\.stopID)) == ["pc.ny.zoo", "pc.ny.bethesda"])
    }

    @Test func sameDayTwiceIsOneActiveDay() async throws {
        let (service, _, _, _) = try service()
        _ = try await service.complete(summary(minutes: 5, on: day(28, 8)))
        let again = try await service.complete(summary(minutes: 5, on: day(28, 18)))
        #expect(again.activeDays == 1)
        #expect(!again.isFirstWorkout)
    }

    @Test func stoppingAfterThreeMinutesStillCounts() async throws {
        let (service, context, _, _) = try service()
        let result = try await service.complete(summary(minutes: 3, on: day(28)))
        #expect(result.activeDays == 1)
        #expect(try context.fetch(FetchDescriptor<WorkoutRecord>()).count == 1)
    }

    @Test func seventhActiveDayReachesSprout() async throws {
        let (service, _, _, _) = try service()
        var last: CompletionResult?
        for d in 21...27 { last = try await service.complete(summary(minutes: 5, on: day(d))) }
        #expect(last?.activeDays == 7)
        #expect(last?.reachedLevel == .sprout)
    }

    @Test func feelingIsSavedOnTheRecord() async throws {
        let (service, context, _, _) = try service()
        let result = try await service.complete(summary(minutes: 8, on: day(28)))
        try service.recordFeeling(.tooHard, for: result.recordID)
        #expect(try context.fetch(FetchDescriptor<WorkoutRecord>()).first?.feeling == "tooHard")
    }

    @Test func freeUserOnAPaidRouteStopsAtTheFirstPostcardButMilesCount() async throws {
        let (service, context, _, _) = try service(entitlement: .free)
        context.insert(JourneyState(journeyID: "jr.smoky", miles: 0, isCurrent: true, startedAt: day(20)))
        try context.save()
        let result = try await service.complete(summary(minutes: 60, on: day(28)))  // 3 miles
        #expect(result.unlockedStops.map(\.id) == ["pc.smoky.1"])
        #expect(result.isLockedAhead)
        let journey = try #require(try context.fetch(FetchDescriptor<JourneyState>()).first { $0.isCurrent })
        #expect(abs(journey.miles - 3) < 0.0001)
    }

    @Test func upgradingUnlocksTheStopsWalkedPastWhileFree() async throws {
        let context = container.mainContext
        // Walked 3 miles of Smoky on the free plan (capped at the first stop), then bought Pro.
        context.insert(JourneyState(journeyID: "jr.smoky", miles: 3, isCurrent: true, startedAt: day(20)))
        context.insert(PostcardUnlock(journeyID: "jr.smoky", stopID: "pc.smoky.1", unlockedAt: day(21)))
        try context.save()
        let (pro, _, _, _) = try service(entitlement: .subscribed)
        let result = try await pro.complete(summary(minutes: 6, on: day(28)))  // 3.3 miles
        #expect(result.unlockedStops.map(\.id) == ["pc.smoky.2"])
        #expect(result.nextStop?.id == "pc.smoky.3")
    }
}
