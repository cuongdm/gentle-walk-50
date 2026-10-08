import Foundation
import SwiftData
import Testing
import GentleWalkCore
@testable import GentleWalk

@Suite(.serialized) @MainActor
struct PersistenceTests {
    @Test func insertsAndFetchesWorkout() throws {
        let container = try ModelContainerFactory.make(inMemory: true)
        let context = ModelContext(container)
        let record = WorkoutRecord(
            date: Date(timeIntervalSince1970: 1_790_000_000), kind: "walk", level: "seated",
            intensity: "steady", place: "indoors", activeSeconds: 480, journeyMiles: 0.4
        )
        context.insert(record)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<WorkoutRecord>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.id == record.id)
        #expect(fetched.first?.journeyMiles == 0.4)
    }

    @Test func storeHasNoCloudKit() {
        let configuration = ModelContainerFactory.configuration(inMemory: false)
        // CloudKitDatabase is not Equatable, and .automatic also has a nil container identifier,
        // so read the flag it carries (description: "CloudKitDatabase(_automatic:_none:_privateDBName:)").
        let isNone = Mirror(reflecting: configuration.cloudKitDatabase).children
            .first { $0.label == "_none" }?.value as? Bool
        #expect(isNone == true)
        #expect(configuration.cloudKitContainerIdentifier == nil)
    }

    @Test func schemaListsAllSevenModels() {
        #expect(SchemaV1.models.count == 7)
        #expect(SchemaV1.versionIdentifier == Schema.Version(1, 0, 0))
    }

    /// Steady program 3.1: V2 adds the program and the self-checks; the app opens V2.
    @Test func v2HasProgramAndSelfCheck() throws {
        #expect(SchemaV2.models.count == 9)
        #expect(SchemaV2.versionIdentifier == Schema.Version(2, 0, 0))
        #expect(GentleWalkMigrationPlan.schemas.count == 2)
        let context = ModelContext(try ModelContainerFactory.make(inMemory: true))
        let start = Date(timeIntervalSince1970: 1_791_000_000)
        context.insert(ProgramState(start: start))
        context.insert(SelfCheckRecord(date: start, count: 7, usedHands: true, week: 0))
        try context.save()
        let program = try #require(try context.fetch(FetchDescriptor<ProgramState>()).first)
        #expect(program.programRound == ProgramRound(start: start, round: 1, pausedDays: 0))
        let check = try #require(try context.fetch(FetchDescriptor<SelfCheckRecord>()).first)
        #expect(check.result == SelfCheckResult(date: start, count: 7, usedHands: true))
    }

    /// Steady program 3.2: a store written by V1 opens with V2 and keeps every row.
    @Test func migratesV1StoreKeepingRows() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("v1-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let url = folder.appendingPathComponent("store.sqlite")
        let now = Date(timeIntervalSince1970: 1_791_000_000)

        do {
            let v1 = Schema(versionedSchema: SchemaV1.self)
            let container = try ModelContainer(for: v1, configurations: [ModelConfiguration(schema: v1, url: url,
                                                                                            cloudKitDatabase: .none)])
            let context = ModelContext(container)
            context.insert(SchemaV1.UserProfile(name: "Margaret", onboardingCompleted: true))
            for day in 0..<5 {
                context.insert(SchemaV1.WorkoutRecord(date: now.addingTimeInterval(Double(day) * 86_400), kind: "walk",
                                                      level: "seated", intensity: "steady", place: "indoors",
                                                      activeSeconds: 600, journeyMiles: 0.4))
            }
            context.insert(SchemaV1.JourneyState(journeyID: "jr.ny", miles: 1.8, isCurrent: true, startedAt: now))
            try context.save()
        }

        let container = try ModelContainer(for: Schema(versionedSchema: SchemaV2.self),
                                           migrationPlan: GentleWalkMigrationPlan.self,
                                           configurations: [ModelContainerFactory.configuration(url: url)])
        let context = ModelContext(container)
        #expect(try context.fetchCount(FetchDescriptor<UserProfile>()) == 1)
        #expect(try context.fetchCount(FetchDescriptor<WorkoutRecord>()) == 5)
        #expect(try context.fetchCount(FetchDescriptor<JourneyState>()) == 1)
        #expect(try context.fetchCount(FetchDescriptor<ProgramState>()) == 0)
        #expect(try context.fetch(FetchDescriptor<UserProfile>()).first?.name == "Margaret")
    }
}
