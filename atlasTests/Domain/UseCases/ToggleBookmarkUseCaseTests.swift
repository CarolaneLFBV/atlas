import Testing
@testable import atlas

@MainActor
@Suite("ToggleBookmarkUseCase")
struct ToggleBookmarkUseCaseTests {
    @Test("Toggling twice adds then removes the bookmark")
    func togglesState() throws {
        let repository = FakeBookmarkRepository()
        let useCase = ToggleBookmarkUseCase(repository: repository)
        let entry = Fixture.entry("List")

        #expect(try useCase.execute(for: entry) == true)
        #expect(try repository.isBookmarked(entry.id))

        #expect(try useCase.execute(for: entry) == false)
        #expect(try repository.bookmarks().isEmpty)
    }
}
