import Foundation

/// Loads a documentation page, indexes it, and starts framework indexing for framework pages.
final class PageLoader {
    private let registry: SourceRegistry
    private let sync: DocumentationSyncService
    private let indexer: DocumentationIndexer
    private let locations: PageLocationCatalog
    private let catalogueLoader: CatalogueLoader
    private let frameworkIndexer: FrameworkIndexer
    private let policy: CachePolicy

    init(
        registry: SourceRegistry,
        sync: DocumentationSyncService,
        indexer: DocumentationIndexer,
        locations: PageLocationCatalog,
        catalogueLoader: CatalogueLoader,
        frameworkIndexer: FrameworkIndexer,
        policy: CachePolicy
    ) {
        self.registry = registry
        self.sync = sync
        self.indexer = indexer
        self.locations = locations
        self.catalogueLoader = catalogueLoader
        self.frameworkIndexer = frameworkIndexer
        self.policy = policy
    }

    func detail(for id: DocumentationID) async throws -> Fetched<DocumentationDetail> {
        let source = try registry.enabledSource(for: id.sourceID)
        guard let url = await dataURL(for: id, from: source) else { throw DocumentationError.notFound(id) }

        do {
            let (data, freshness) = try await sync.load(url, key: id.storageKey, sourceID: source.id, maxAge: policy.pageMaxAge)
            let detail = try await SourceParser.detail(from: data, id: id, metadata: await indexer.knownEntry(for: id), source: source)
            await indexer.index(detail, from: source)
            if detail.entry.kind == .framework {
                frameworkIndexer.startIndexing(detail.entry, from: source)
            }
            return Fetched(value: detail, freshness: freshness)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw DocumentationErrorMapper.domainError(error, for: id)
        }
    }

    /// The page's data URL: as declared by the source's index when it declares one (exact,
    /// case-sensitive file names), otherwise derived from the path.
    func dataURL(for id: DocumentationID, from source: any DocumentationSource) async -> URL? {
        if source.format.declaresPageLocations, !locations.hasLocations(for: source.id) {
            await catalogueLoader.searchIndexEntries(of: source, forceRevalidation: false)
        }
        return locations.location(for: id)?.dataURL ?? source.pageDataURL(forPath: id.path)
    }
}
