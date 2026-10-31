import Foundation

// Preview-only code: excluded from Release builds.
#if DEBUG
/// A `DocumentationRepository` serving `PreviewFixtures`, for SwiftUI previews ONLY.
final class PreviewDocumentationRepository: DocumentationRepository {
    func searchCapability() async -> SearchCapability { .metadata }
    let sourceStatuses = [
        DocumentationSourceStatus(id: PreviewFixtures.source, displayName: "Preview fixtures", isEnabled: true),
        DocumentationSourceStatus(id: .apple, displayName: "Apple Developer Documentation", isEnabled: false),
    ]

    func catalogue() async throws -> Fetched<DocumentationCatalogue> {
        Fetched(value: PreviewFixtures.catalogue, freshness: .cached(fetchedAt: .now.addingTimeInterval(-7_200)))
    }

    func refreshCatalogue() async throws -> Fetched<DocumentationCatalogue> {
        Fetched(value: PreviewFixtures.catalogue, freshness: .fresh)
    }

    func searchCandidates(matching query: String) async throws -> [DocumentationEntry] {
        PreviewFixtures.entries + PreviewFixtures.catalogue.allFrameworks.map(\.entry)
    }

    func fullTextMatches(matching query: String) async throws -> [FullTextMatch] {
        []
    }

    func detail(for id: DocumentationID) async throws -> Fetched<DocumentationDetail> {
        Fetched(value: PreviewFixtures.detail, freshness: .fresh)
    }
}
#endif
