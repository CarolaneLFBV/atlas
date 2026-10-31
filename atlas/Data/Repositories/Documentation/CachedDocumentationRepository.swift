import Foundation

/// Disabled sources are never contacted; other sources are never bulk-downloaded or full-text indexed.
final class CachedDocumentationRepository: DocumentationRepository, OfflineContentRepository {
    private let registry: SourceRegistry
    private let indexer: DocumentationIndexer
    private let catalogueLoader: CatalogueLoader
    private let pageLoader: PageLoader
    private let frameworkIndexer: FrameworkIndexer
    private let offlineDownloader: OfflineDownloader

    init(
        sources: [any DocumentationSource],
        sync: DocumentationSyncService,
        searchIndex: SearchIndexStore,
        fullTextIndex: FullTextIndexStore,
        policy: CachePolicy = .standard,
        isTurnedOffByUser: @escaping @Sendable (DocumentationSourceID) -> Bool = { _ in false }
    ) {
        let registry = SourceRegistry(sources: sources, isTurnedOffByUser: isTurnedOffByUser)
        let indexer = DocumentationIndexer(searchIndex: searchIndex, fullTextIndex: fullTextIndex)
        let locations = PageLocationCatalog()
        let catalogueLoader = CatalogueLoader(registry: registry, sync: sync, indexer: indexer, locations: locations, policy: policy)
        let frameworkIndexer = FrameworkIndexer(sync: sync, indexer: indexer, policy: policy)

        self.registry = registry
        self.indexer = indexer
        self.catalogueLoader = catalogueLoader
        self.frameworkIndexer = frameworkIndexer
        pageLoader = PageLoader(
            registry: registry, sync: sync, indexer: indexer, locations: locations,
            catalogueLoader: catalogueLoader, frameworkIndexer: frameworkIndexer, policy: policy
        )
        offlineDownloader = OfflineDownloader(
            registry: registry, sync: sync, indexer: indexer, locations: locations,
            catalogueLoader: catalogueLoader, policy: policy
        )
    }

    /// Internal so tests can await completion.
    var frameworkIndexingTasks: [String: Task<Void, Never>] { frameworkIndexer.tasks }

    // MARK: DocumentationRepository

    /// Full text is searchable for enabled, downloadable sources that have indexed pages.
    func searchCapability() async -> SearchCapability {
        var names: [String] = []
        for source in registry.downloadableSources where await indexer.fullTextPageCount(for: source.id) > 0 {
            names.append(source.displayName)
        }
        return SearchCapability(fullTextSourceNames: names)
    }

    var sourceStatuses: [DocumentationSourceStatus] { registry.statuses }

    func catalogue() async throws -> Fetched<DocumentationCatalogue> {
        try await catalogueLoader.catalogue(forceRevalidation: false)
    }

    func refreshCatalogue() async throws -> Fetched<DocumentationCatalogue> {
        try await catalogueLoader.catalogue(forceRevalidation: true)
    }

    func searchCandidates(matching query: String) async throws -> [DocumentationEntry] {
        try await indexer.searchIndex.candidates(matching: query, enabledSources: registry.enabledSourceIDs)
    }

    func fullTextMatches(matching query: String) async throws -> [FullTextMatch] {
        try await indexer.fullTextIndex.matches(for: query, enabledSources: registry.enabledSourceIDs)
    }

    func detail(for id: DocumentationID) async throws -> Fetched<DocumentationDetail> {
        try await pageLoader.detail(for: id)
    }

    // MARK: OfflineContentRepository

    func offlineStatuses() async throws -> [OfflineContentStatus] {
        await offlineDownloader.statuses()
    }

    @discardableResult
    func downloadForOffline(_ sourceID: DocumentationSourceID, progress: @escaping (Int, Int) -> Void) async throws -> Int {
        try await offlineDownloader.download(sourceID, progress: progress)
    }
}
