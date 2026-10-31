import Foundation
@testable import atlas

@MainActor
final class StubDocumentationRepository: DocumentationRepository {
    var capability: SearchCapability = .metadata

    func searchCapability() async -> SearchCapability { capability }
    var sourceStatuses: [DocumentationSourceStatus] = []

    var catalogueResult: Result<Fetched<DocumentationCatalogue>, DocumentationError> =
        .success(Fetched(value: .empty, freshness: .fresh))
    var refreshResult: Result<Fetched<DocumentationCatalogue>, DocumentationError>?
    var searchResult: Result<[DocumentationEntry], DocumentationError> = .success([])
    var detailResult: Result<Fetched<DocumentationDetail>, DocumentationError> = .failure(.invalidResponse)
    private(set) var searchCalls = 0

    func catalogue() async throws -> Fetched<DocumentationCatalogue> {
        try catalogueResult.get()
    }

    func refreshCatalogue() async throws -> Fetched<DocumentationCatalogue> {
        try (refreshResult ?? catalogueResult).get()
    }

    func searchCandidates(matching query: String) async throws -> [DocumentationEntry] {
        searchCalls += 1
        return try searchResult.get()
    }

    var fullTextResult: [FullTextMatch] = []

    func fullTextMatches(matching query: String) async throws -> [FullTextMatch] {
        fullTextResult
    }

    func detail(for id: DocumentationID) async throws -> Fetched<DocumentationDetail> {
        try detailResult.get()
    }
}
