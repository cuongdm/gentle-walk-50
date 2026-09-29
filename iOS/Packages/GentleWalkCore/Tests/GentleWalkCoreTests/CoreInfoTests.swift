import Testing
@testable import GentleWalkCore

@Suite struct CoreInfoTests {
    @Test func contentSchemaVersionIsOne() {
        #expect(CoreInfo.contentSchemaVersion == 1)
    }
}
