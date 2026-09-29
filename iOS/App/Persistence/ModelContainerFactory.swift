import Foundation
import SwiftData

/// Builds the app's SwiftData container. The store never syncs to iCloud: workout, pain and journey
/// records are health-adjacent data that must stay on the device (App Review 5.1.3, CLAUDE.md).
enum ModelContainerFactory {
    static func configuration(inMemory: Bool) -> ModelConfiguration {
        ModelConfiguration(
            schema: Schema(versionedSchema: SchemaV1.self),
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: .none
        )
    }

    /// `inMemory: true` for tests and the screenshot hook; one fresh container per call.
    static func make(inMemory: Bool) throws -> ModelContainer {
        try ModelContainer(
            for: Schema(versionedSchema: SchemaV1.self),
            migrationPlan: GentleWalkMigrationPlan.self,
            configurations: [configuration(inMemory: inMemory)]
        )
    }
}
