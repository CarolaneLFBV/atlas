import Testing
@testable import atlas

@Suite("SourceRegistry")
struct SourceRegistryTests {
    private let kept = TestDocumentationSource(id: DocumentationSourceID(rawValue: "kept"))
    private let dropped = TestDocumentationSource(id: DocumentationSourceID(rawValue: "dropped"))

    @Test("A source turned off by the user is neither enabled nor contactable, and says why")
    func turnedOffSources() {
        let dropped = dropped.id
        let registry = SourceRegistry(sources: [kept, self.dropped], isTurnedOffByUser: { $0 == dropped })

        #expect(registry.enabledSourceIDs == [kept.id])
        #expect(throws: DocumentationError.self) { try registry.enabledSource(for: dropped) }
        let status = registry.statuses.first { $0.id == dropped }
        #expect(status?.isEnabled == false)
        #expect(status?.isTurnedOffByUser == true)
    }
}
