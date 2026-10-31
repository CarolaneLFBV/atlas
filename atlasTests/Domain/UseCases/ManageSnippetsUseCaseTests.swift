import Testing
@testable import atlas

@MainActor
@Suite("ManageSnippetsUseCase")
struct ManageSnippetsUseCaseTests {
    @Test("Snippets with empty code are rejected")
    func rejectsEmptyCode() {
        let useCase = ManageSnippetsUseCase(repository: FakeSnippetRepository())
        #expect(throws: ValidationError.emptyField("code")) {
            try useCase.save(CodeSnippet(title: "Title", language: "swift", code: "  \n", origin: .userAuthored))
        }
    }

    @Test("Empty titles get a default and titles are trimmed")
    func normalizesTitle() throws {
        let repository = FakeSnippetRepository()
        let useCase = ManageSnippetsUseCase(repository: repository)

        try useCase.save(CodeSnippet(title: "   ", language: "swift", code: "let a = 1", origin: .userAuthored))
        try useCase.save(CodeSnippet(title: "  Map  ", language: "swift", code: "a.map { $0 }", origin: .userAuthored))

        #expect(repository.saved.first?.title.isEmpty == false)
        #expect(repository.saved.last?.title == "Map")
    }
}
