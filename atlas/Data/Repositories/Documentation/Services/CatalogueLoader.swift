import Foundation
import OSLog

/// Catalogues are merged in source order; one failing source doesn't hide the others.
final class CatalogueLoader {
    private static let logger = Logger(subsystem: "atlas", category: "Catalogue")

    private let registry: SourceRegistry
    private let sync: DocumentationSyncService
    private let indexer: DocumentationIndexer
    private let locations: PageLocationCatalog
    private let policy: CachePolicy

    init(
        registry: SourceRegistry,
        sync: DocumentationSyncService,
        indexer: DocumentationIndexer,
        locations: PageLocationCatalog,
        policy: CachePolicy
    ) {
        self.registry = registry
        self.sync = sync
        self.indexer = indexer
        self.locations = locations
        self.policy = policy
    }

    func catalogue(forceRevalidation: Bool) async throws -> Fetched<DocumentationCatalogue> {
        var categories: [DocumentationCatalogue.Category] = []
        var freshnesses: [Freshness] = []
        var firstError: Error?

        for source in registry.enabledSources {
            guard let url = source.catalogueURL else { continue }
            do {
                let (data, freshness) = try await sync.load(
                    url, key: Self.catalogueKey(for: source), sourceID: source.id,
                    maxAge: policy.catalogueMaxAge, forceRevalidation: forceRevalidation
                )
                let sourceCategories = try await SourceParser.catalogueCategories(from: data, source: source)
                categories += sourceCategories
                freshnesses.append(freshness)
                await indexer.index(sourceCategories.flatMap(\.frameworks).map(\.entry))
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                Self.logger.error("Catalogue of \(source.id.rawValue, privacy: .public) failed: \(error)")
                firstError = firstError ?? error
            }
            _ = await searchIndexEntries(of: source, forceRevalidation: forceRevalidation)
        }

        if categories.isEmpty, let firstError {
            throw DocumentationErrorMapper.domainError(firstError)
        }
        let catalogue = DocumentationCatalogue(categories: CatalogueMerging.merged(categories), lastUpdated: .now)
        return Fetched(value: catalogue, freshness: CatalogueMerging.combined(freshnesses))
    }

    /// Best effort: search still works from catalogues and page links without it.
    /// - Returns: The index entries, or `nil` when the source has no index or it couldn't be loaded.
    @discardableResult
    func searchIndexEntries(of source: any DocumentationSource, forceRevalidation: Bool) async -> [DocumentationEntry]? {
        do {
            return try await loadSearchIndex(of: source, forceRevalidation: forceRevalidation)
        } catch {
            Self.logger.notice("Search index of \(source.id.rawValue, privacy: .public) unavailable: \(error)")
            return nil
        }
    }

    /// Like `searchIndexEntries`, but reports failures (used when the index is required, e.g. offline download).
    func loadSearchIndex(of source: any DocumentationSource, forceRevalidation: Bool) async throws -> [DocumentationEntry]? {
        guard let url = source.searchIndexURL else { return nil }
        let (data, _) = try await sync.load(
            url, key: "\(source.id.rawValue):search-index", sourceID: source.id,
            maxAge: policy.searchIndexMaxAge, forceRevalidation: forceRevalidation
        )
        let entries = try await SourceParser.searchEntries(from: data, source: source)
        await indexer.index(entries)
        locations.update(try await SourceParser.pageLocations(fromIndex: data, source: source), for: source.id)
        return entries
    }

    private static func catalogueKey(for source: any DocumentationSource) -> String {
        "\(source.id.rawValue):catalogue"
    }
}
