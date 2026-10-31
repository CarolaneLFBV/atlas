import Foundation
import Observation

@Observable
final class LibraryViewModel {
    enum State {
        case loading
        case loaded(Fetched<DocumentationCatalogue>)
        case failed(String)
    }

    static let featuredCount = 3

    private(set) var state: State = .loading
    private(set) var isRefreshing = false
    private(set) var disabledSources: [DocumentationSourceStatus] = []
    var hiddenCategories: Set<String> = []

    private let loadCatalogue: LoadCatalogueUseCase

    init(loadCatalogue: LoadCatalogueUseCase) {
        self.loadCatalogue = loadCatalogue
    }

    private var catalogue: DocumentationCatalogue? {
        guard case .loaded(let fetched) = state else { return nil }
        return fetched.value
    }

    var allCategoryNames: [String] {
        catalogue?.categories.map(\.name) ?? []
    }

    private var visibleCategories: [DocumentationCatalogue.Category] {
        (catalogue?.categories ?? []).filter { !hiddenCategories.contains($0.name) }
    }

    var featured: [DocumentationFramework] {
        Array(visibleCategories.flatMap(\.frameworks).prefix(Self.featuredCount))
    }

    /// Categories left empty once featured frameworks are removed are dropped.
    var browseCategories: [DocumentationCatalogue.Category] {
        let featuredIDs = Set(featured.map(\.id))
        return visibleCategories.compactMap { category in
            let frameworks = category.frameworks.filter { !featuredIDs.contains($0.id) }
            return frameworks.isEmpty ? nil : DocumentationCatalogue.Category(name: category.name, frameworks: frameworks)
        }
    }

    /// Safe to call again (e.g. after a source is enabled): the current content stays visible
    /// until the new catalogue is ready.
    func load() async {
        await fetch(forceRefresh: false)
    }

    /// Keeps the current catalogue if revalidation fails.
    func refresh() async {
        isRefreshing = true
        defer { isRefreshing = false }
        await fetch(forceRefresh: true)
    }

    private func fetch(forceRefresh: Bool) async {
        disabledSources = loadCatalogue.disabledSources
        do {
            state = .loaded(try await loadCatalogue.execute(forceRefresh: forceRefresh))
        } catch is CancellationError {
            return
        } catch {
            // Never replace content the user can already see with an error.
            if case .loaded = state { return }
            state = .failed(error.documentationUserMessage)
        }
    }
}
