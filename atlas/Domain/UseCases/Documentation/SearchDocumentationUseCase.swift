import Foundation

struct SearchDocumentationUseCase {
    /// Queries shorter than this are not sent to the repository.
    static let minimumQueryLength = 2

    let repository: any DocumentationRepository
    var ranker = DocumentationSearchRanker()
    var limit = 50

    func capability() async -> SearchCapability {
        await repository.searchCapability()
    }

    func execute(query: String) async throws -> [SearchResult] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= Self.minimumQueryLength else { return [] }

        let candidates = try await repository.searchCandidates(matching: trimmed)
        try Task.checkCancellation()
        let metadataResults = ranker.rank(candidates, for: trimmed, limit: limit)
            .map { SearchResult(entry: $0, match: .metadata) }

        guard await capability().includesFullText else { return metadataResults }
        let textMatches = try await repository.fullTextMatches(matching: trimmed)
        try Task.checkCancellation()

        var seen = Set(metadataResults.map(\.id))
        let textResults = textMatches
            .map { SearchResult(entry: $0.entry, match: .text(sectionTitle: $0.sectionTitle, excerpt: $0.excerpt)) }
            .filter { seen.insert($0.id).inserted }

        return Array((metadataResults + textResults).prefix(limit))
    }
}
