import Testing
@testable import atlas

@MainActor
@Suite("SearchViewModel")
struct SearchViewModelTests {
    let repository = StubDocumentationRepository()

    private func makeViewModel() -> SearchViewModel {
        SearchViewModel(searchDocumentation: SearchDocumentationUseCase(repository: repository), debounce: .zero)
    }

    @Test("Short queries stay idle without searching")
    func shortQueryIsIdle() async {
        let viewModel = makeViewModel()
        viewModel.query = "a"
        await viewModel.search()
        #expect(viewModel.state == .idle)
        #expect(repository.searchCalls == 0)
    }

    @Test("Matching results are shown")
    func showsResults() async {
        repository.searchResult = .success([Fixture.entry("Text")])
        let viewModel = makeViewModel()
        viewModel.query = "text"
        await viewModel.search()
        #expect(viewModel.state == .results([SearchResult(entry: Fixture.entry("Text"), match: .metadata)]))
    }

    @Test("No matches produce an explicit empty state with the query")
    func noResults() async {
        repository.searchResult = .success([Fixture.entry("Button")])
        let viewModel = makeViewModel()
        viewModel.query = "toggle"
        await viewModel.search()
        #expect(viewModel.state == .noResults("toggle"))
    }

    @Test("Failures surface a user-facing message")
    func failure() async {
        repository.searchResult = .failure(.offline)
        let viewModel = makeViewModel()
        viewModel.query = "text"
        await viewModel.search()
        #expect(viewModel.state == .failed(DocumentationError.offline.userMessage))
    }

    @Test("A search cancelled during the debounce sends no request and shows no results")
    func cancellation() async {
        let viewModel = SearchViewModel(
            searchDocumentation: SearchDocumentationUseCase(repository: repository),
            debounce: .seconds(10)
        )
        viewModel.query = "text"
        let task = Task { await viewModel.search() }
        task.cancel()
        await task.value
        // The newer query's task owns the state; this one just must not produce results.
        #expect(viewModel.state == .loading)
        #expect(repository.searchCalls == 0)
    }
}
