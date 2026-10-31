import Testing
@testable import atlas

@MainActor
@Suite("SearchDocumentationUseCase – full text")
struct SearchDocumentationUseCaseFullTextTests {
    @Test("Title matches come first, then passages; identical results aren't repeated")
    func mergesResults() async throws {
        let page = Fixture.entry("Concurrency")
        let other = Fixture.entry("Migrating")
        let repository = FakeDocumentationRepository(candidates: [page])
        repository.capability = SearchCapability(fullTextSourceNames: ["Guide"])
        repository.fullTextResult = [
            FullTextMatch(entry: other, sectionTitle: "Overview", excerpt: "…concurrency…"),
            FullTextMatch(entry: other, sectionTitle: "Overview", excerpt: "…concurrency again…"),
        ]

        let results = try await SearchDocumentationUseCase(repository: repository).execute(query: "concurrency")

        #expect(results.map(\.entry.title) == ["Concurrency", "Migrating"])
        #expect(results.first?.match == .metadata)
    }

    @Test("Full text isn't queried when no source supports it")
    func metadataOnly() async throws {
        let repository = FakeDocumentationRepository(candidates: [])
        repository.fullTextResult = [FullTextMatch(entry: Fixture.entry("X"), sectionTitle: "S", excerpt: "e")]
        let results = try await SearchDocumentationUseCase(repository: repository).execute(query: "anything")
        #expect(results.isEmpty)
    }
}
