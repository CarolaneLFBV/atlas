import Foundation

protocol DocumentationRepository: AnyObject {
    func searchCapability() async -> SearchCapability

    var sourceStatuses: [DocumentationSourceStatus] { get }

    /// Served local-first. Returns an empty catalogue when nothing is cached yet.
    func catalogue() async throws -> Fetched<DocumentationCatalogue>

    /// Never discards the cache on failure.
    func refreshCatalogue() async throws -> Fetched<DocumentationCatalogue>

    /// Ranking is done by the caller.
    func searchCandidates(matching query: String) async throws -> [DocumentationEntry]

    /// Best first. Only called when `searchCapability().includesFullText` is true.
    func fullTextMatches(matching query: String) async throws -> [FullTextMatch]

    func detail(for id: DocumentationID) async throws -> Fetched<DocumentationDetail>
}
