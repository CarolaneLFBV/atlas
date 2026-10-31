import Foundation
import Observation

/// The view calls `search()` from `.task(id: query)`: SwiftUI cancels the previous task whenever the
/// query changes, so the debounce sleep doubles as cancellation of outdated requests.
@Observable
final class SearchViewModel {
    enum State: Equatable {
        case idle
        case loading
        case results([SearchResult])
        case noResults(String)
        case failed(String)
    }

    var query = ""
    /// Filters the current results; changing it doesn't search again.
    var scope: SearchScope = .all
    private(set) var state: State = .idle
    /// What search covers; refreshed on every search, since downloads extend it.
    private(set) var capability: SearchCapability = .metadata

    private let searchDocumentation: SearchDocumentationUseCase
    private let debounce: Duration

    init(searchDocumentation: SearchDocumentationUseCase, debounce: Duration = .milliseconds(300)) {
        self.searchDocumentation = searchDocumentation
        self.debounce = debounce
    }

    func refreshCapability() async {
        capability = await searchDocumentation.capability()
    }

    func search() async {
        await refreshCapability()
        let query = self.query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard query.count >= SearchDocumentationUseCase.minimumQueryLength else {
            state = .idle
            return
        }

        // Show progress right away so the idle content doesn't linger while the user types.
        if state == .idle { state = .loading }
        do {
            try await Task.sleep(for: debounce)
            if case .results = state {} else { state = .loading }
            let results = try await searchDocumentation.execute(query: query)
            state = results.isEmpty ? .noResults(query) : .results(results)
        } catch is CancellationError {
            // A newer query superseded this one; its own task updates the state.
        } catch {
            state = .failed(error.documentationUserMessage)
        }
    }
}
