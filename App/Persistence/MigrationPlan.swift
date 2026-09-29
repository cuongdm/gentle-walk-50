import SwiftData

/// Ordered list of schema versions. v1 only; add stages when SchemaV2 appears — never remove a version.
enum GentleWalkMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [SchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}
