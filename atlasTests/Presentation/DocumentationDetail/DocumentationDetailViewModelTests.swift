import Testing
@testable import atlas

@MainActor
@Suite("DocumentationDetailViewModel")
struct DocumentationDetailViewModelTests {
    let repository = StubDocumentationRepository()
    let entry = Fixture.entry("View", path: "/documentation/swiftui/view")

    private func makeViewModel() -> DocumentationDetailViewModel {
        DocumentationDetailViewModel(
            entry: entry,
            getDetail: GetDocumentationDetailUseCase(repository: repository, activity: FakeRecentActivityRepository())
        )
    }

    @Test("A disabled or unknown source falls back to metadata and the official link", arguments: [
        DocumentationError.sourceDisabled(.apple),
        DocumentationError.unknownSource(.apple),
    ])
    func metadataOnlyFallback(_ error: DocumentationError) async {
        repository.detailResult = .failure(error)
        let viewModel = makeViewModel()

        await viewModel.load()

        guard case .metadataOnly = viewModel.state else {
            Issue.record("Expected metadata-only state, got \(viewModel.state)")
            return
        }
        #expect(viewModel.displayedEntry == entry)
    }

    @Test("Other errors show an error state")
    func otherErrors() async {
        repository.detailResult = .failure(.offline)
        let viewModel = makeViewModel()

        await viewModel.load()

        guard case .failed(let message) = viewModel.state else {
            Issue.record("Expected an error state, got \(viewModel.state)")
            return
        }
        #expect(message == DocumentationError.offline.userMessage)
    }

    @Test("Saved snippets are new personal copies linked to the page")
    func snippetToSave() {
        let example = CodeSnippet(title: "", language: "swift", code: "Text(\"Hi\")", origin: .documentation(entry.id))
        let snippet = makeViewModel().snippetToSave(from: example)

        #expect(snippet.id != example.id)
        #expect(snippet.title == entry.title)
        #expect(snippet.origin == .documentation(entry.id))
    }
}
