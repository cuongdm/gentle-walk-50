import Foundation
import SwiftData
import Testing
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
}
