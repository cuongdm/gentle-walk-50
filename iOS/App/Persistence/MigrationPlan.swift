import SwiftData

/// The store version the app opens.
typealias CurrentSchema = SchemaV2

/// Ordered list of schema versions — never remove a version. V1 → V2 only adds the program and
/// self-check models, so it is a lightweight stage.
enum GentleWalkMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [SchemaV1.self, SchemaV2.self] }
    // Computed, not a stored static: MigrationStage is not Sendable (Swift 6 strict concurrency).
    static var stages: [MigrationStage] { [.lightweight(fromVersion: SchemaV1.self, toVersion: SchemaV2.self)] }
}
