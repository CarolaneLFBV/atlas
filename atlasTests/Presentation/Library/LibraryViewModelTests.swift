import Foundation
import Testing
@testable import atlas

@MainActor
@Suite("LibraryViewModel")
struct LibraryViewModelTests {
    let repository = StubDocumentationRepository()

    private var catalogue: DocumentationCatalogue {
        let framework = DocumentationFramework(
            id: Fixture.id("/documentation/swiftui"), title: "SwiftUI", abstract: nil,
            category: "App Frameworks", tags: [], webURL: nil
        )
        let data = DocumentationFramework(
            id: Fixture.id("/documentation/swiftdata"), title: "SwiftData", abstract: nil,
            category: "Data", tags: [], webURL: nil
        )
        return DocumentationCatalogue(
            categories: [.init(name: "App Frameworks", frameworks: [framework]), .init(name: "Data", frameworks: [data])],
            lastUpdated: nil
        )
    }

    @Test("A failed refresh keeps the catalogue that is already visible")
    func refreshFailureKeepsContent() async {
        repository.catalogueResult = .success(Fetched(value: catalogue, freshness: .fresh))
        repository.refreshResult = .failure(.offline)
        let viewModel = LibraryViewModel(loadCatalogue: LoadCatalogueUseCase(repository: repository))

        await viewModel.load()
        await viewModel.refresh()

        guard case .loaded(let fetched) = viewModel.state else {
            Issue.record("Expected the catalogue to stay visible, got \(viewModel.state)")
            return
        }
        #expect(fetched.value == catalogue)
    }

    @Test("An initial failure shows an error")
    func initialFailure() async {
        repository.catalogueResult = .failure(.offline)
        let viewModel = LibraryViewModel(loadCatalogue: LoadCatalogueUseCase(repository: repository))

        await viewModel.load()

        guard case .failed = viewModel.state else {
            Issue.record("Expected an error state, got \(viewModel.state)")
            return
        }
    }

    @Test("The first frameworks are featured and aren't repeated in their categories")
    func featured() async {
        let frameworks = (0..<5).map {
            DocumentationFramework(
                id: Fixture.id("/documentation/kit\($0)"), title: "Kit\($0)", abstract: nil,
                category: $0 < 2 ? "A" : "B", tags: [], webURL: nil
            )
        }
        let catalogue = DocumentationCatalogue(
            categories: [.init(name: "A", frameworks: Array(frameworks[0..<2])), .init(name: "B", frameworks: Array(frameworks[2...]))],
            lastUpdated: nil
        )
        repository.catalogueResult = .success(Fetched(value: catalogue, freshness: .fresh))
        let viewModel = LibraryViewModel(loadCatalogue: LoadCatalogueUseCase(repository: repository))
        await viewModel.load()

        #expect(viewModel.featured.map(\.title) == ["Kit0", "Kit1", "Kit2"])
        // Category A only had featured frameworks, so it's dropped.
        #expect(viewModel.browseCategories.map(\.name) == ["B"])
        #expect(viewModel.browseCategories.first?.frameworks.map(\.title) == ["Kit3", "Kit4"])
    }

    @Test("Hidden categories are neither featured nor listed")
    func hiddenCategories() async {
        repository.catalogueResult = .success(Fetched(value: catalogue, freshness: .fresh))
        let viewModel = LibraryViewModel(loadCatalogue: LoadCatalogueUseCase(repository: repository))
        await viewModel.load()

        viewModel.hiddenCategories = ["App Frameworks"]

        #expect(viewModel.featured.map(\.title) == ["SwiftData"])
        #expect(viewModel.browseCategories.isEmpty)
        #expect(viewModel.allCategoryNames == ["App Frameworks", "Data"])
    }

    @Test("Sources the user turned off aren't explained as missing")
    func userTurnedOffSources() async {
        repository.sourceStatuses = [
            DocumentationSourceStatus(id: .apple, displayName: "Apple", isEnabled: false),
            DocumentationSourceStatus(id: DocumentationSourceID(rawValue: "swift-evolution"), displayName: "Swift Evolution", isEnabled: false, isTurnedOffByUser: true),
        ]
        let viewModel = LibraryViewModel(loadCatalogue: LoadCatalogueUseCase(repository: repository))
        await viewModel.load()
        #expect(viewModel.disabledSources.map(\.displayName) == ["Apple"])
    }
}
