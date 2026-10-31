import Foundation
@testable import atlas

@MainActor
final class FakeDocumentationRepository: DocumentationRepository {
    var capability: SearchCapability = .metadata

    func searchCapability() async -> SearchCapability { capability }
    var sourceStatuses: [DocumentationSourceStatus] = []
    var candidates: [DocumentationEntry]
    var detailValue: DocumentationDetail?
    private(set) var searchCalls = 0
    private(set) var lastQuery: String?

    init(candidates: [DocumentationEntry] = [], detail: DocumentationDetail? = nil) {
        self.candidates = candidates
        self.detailValue = detail
    }

    func catalogue() async throws -> Fetched<DocumentationCatalogue> {
        Fetched(value: .empty, freshness: .fresh)
    }

    func refreshCatalogue() async throws -> Fetched<DocumentationCatalogue> {
        Fetched(value: .empty, freshness: .fresh)
    }

    func searchCandidates(matching query: String) async throws -> [DocumentationEntry] {
        searchCalls += 1
        lastQuery = query
        return candidates
    }

    var fullTextResult: [FullTextMatch] = []

    func fullTextMatches(matching query: String) async throws -> [FullTextMatch] {
        fullTextResult
    }

    func detail(for id: DocumentationID) async throws -> Fetched<DocumentationDetail> {
        guard let detailValue else { throw DocumentationError.notFound(id) }
        return Fetched(value: detailValue, freshness: .fresh)
    }
}
