import Testing
@testable import atlas

@MainActor
@Suite("SearchDocumentationUseCase")
struct SearchDocumentationUseCaseTests {
    @Test("Queries shorter than the minimum length are not sent")
    func minimumLength() async throws {
        let repository = FakeDocumentationRepository(candidates: [Fixture.entry("Text")])
        let results = try await SearchDocumentationUseCase(repository: repository).execute(query: " T ")
        #expect(results.isEmpty)
        #expect(repository.searchCalls == 0)
    }

    @Test("The query is trimmed and candidates are ranked")
    func trimsAndRanks() async throws {
        let repository = FakeDocumentationRepository(candidates: [Fixture.entry("TextField"), Fixture.entry("Text")])
        let results = try await SearchDocumentationUseCase(repository: repository).execute(query: "  text ")
        #expect(results.map(\.entry.title) == ["Text", "TextField"])
        #expect(repository.lastQuery == "text")
    }
}
