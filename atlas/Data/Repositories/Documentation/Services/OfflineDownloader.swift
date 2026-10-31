import Foundation
import OSLog

/// Pages are fetched one at a time (the download runs in the background, and sequential requests keep
/// the load on documentation servers minimal). Pages whose version the index declares are pinned to it,
/// so unchanged pages cost no request.
final class OfflineDownloader {
    private static let logger = Logger(subsystem: "atlas", category: "OfflineDownload")

    private let registry: SourceRegistry
    private let sync: DocumentationSyncService
    private let indexer: DocumentationIndexer
    private let locations: PageLocationCatalog
    private let catalogueLoader: CatalogueLoader
    private let policy: CachePolicy

    init(
        registry: SourceRegistry,
        sync: DocumentationSyncService,
        indexer: DocumentationIndexer,
        locations: PageLocationCatalog,
        catalogueLoader: CatalogueLoader,
        policy: CachePolicy
    ) {
        self.registry = registry
        self.sync = sync
        self.indexer = indexer
        self.locations = locations
        self.catalogueLoader = catalogueLoader
        self.policy = policy
    }

    func statuses() async -> [OfflineContentStatus] {
        var statuses: [OfflineContentStatus] = []
        for source in registry.downloadableSources {
            statuses.append(OfflineContentStatus(
                id: source.id,
                displayName: source.displayName,
                downloadedPages: await indexer.fullTextPageCount(for: source.id),
                lastUpdated: await sync.lastPageFetch(for: source.id)
            ))
        }
        return statuses
    }

    /// - Returns: The number of pages now available offline.
    func download(_ sourceID: DocumentationSourceID, progress: @escaping (Int, Int) -> Void) async throws -> Int {
        let source = try registry.enabledSource(for: sourceID)
        guard source.allowsOfflineDownload,
              let pages = try await catalogueLoader.loadSearchIndex(of: source, forceRevalidation: false)
        else { throw DocumentationError.sourceDisabled(sourceID) }

        var uniqueIDs = Set<DocumentationID>()
        let ids = pages.map(\.id).filter { uniqueIDs.insert($0).inserted }
        progress(0, ids.count)

        var succeeded = 0
        for (index, id) in ids.enumerated() {
            try Task.checkCancellation()
            if await downloadPage(id, from: source) { succeeded += 1 }
            progress(index + 1, ids.count)
        }

        if succeeded == 0, !ids.isEmpty { throw DocumentationError.offline }
        return succeeded
    }

    /// Failures are logged and counted, not thrown, so one missing page doesn't abort the whole download.
    private func downloadPage(_ id: DocumentationID, from source: any DocumentationSource) async -> Bool {
        let location = locations.location(for: id)
        guard let url = location?.dataURL ?? source.pageDataURL(forPath: id.path) else { return false }
        do {
            let data: Data
            if let version = location?.version {
                (data, _) = try await sync.loadPinned(url, key: id.storageKey, sourceID: source.id, version: version)
            } else {
                (data, _) = try await sync.load(url, key: id.storageKey, sourceID: source.id, maxAge: policy.pageMaxAge)
            }
            let detail = try await SourceParser.detail(from: data, id: id, metadata: await indexer.knownEntry(for: id), source: source)
            await indexer.index(detail, from: source)
            return true
        } catch {
            Self.logger.notice("Offline download skipped \(id.storageKey, privacy: .public): \(error)")
            return false
        }
    }
}
