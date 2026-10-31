import Foundation
import OSLog

/// Rules:
/// - A cached copy within its max age is returned without any network request.
/// - Otherwise the source is asked whether it changed (`If-None-Match` / `If-Modified-Since`).
/// - If the source can't be reached, the cached copy is returned as `.stale`. The cache is never
///   cleared because a sync failed.
/// - Without a cached copy, the error is surfaced.
///
/// Cache read and write failures never fail a load (the network copy is still returned), but they're logged.
final class DocumentationSyncService {
    private static let logger = Logger(subsystem: "atlas", category: "Cache")

    private let http: any HTTPClient
    private let store: CachedResourceStore
    private let now: () -> Date

    init(http: any HTTPClient, store: CachedResourceStore, now: @escaping () -> Date = { .now }) {
        self.http = http
        self.store = store
        self.now = now
    }

    /// Loads a resource whose current version is already known from an index (e.g. a git SHA).
    ///
    /// When the cached copy has that version, it's returned without any request; otherwise the resource
    /// is downloaded and cached under the new version. The version is stored as the cache validator.
    func loadPinned(
        _ url: URL,
        key: String,
        sourceID: DocumentationSourceID,
        version: String
    ) async throws -> (data: Data, freshness: Freshness) {
        let validator = "version:\(version)"
        let cached = await cachedResource(forKey: key)
        if let cached, cached.validators.etag == validator {
            await markRevalidated(key: key)
            return (cached.data, .fresh)
        }
        do {
            switch try await http.get(url, validators: nil) {
            case .modified(let data, _):
                await persist(data, validators: CacheValidators(etag: validator), key: key, sourceID: sourceID)
                return (data, .fresh)
            case .notModified:
                throw DocumentationError.invalidResponse
            }
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            if let cached { return (cached.data, .stale(fetchedAt: cached.fetchedAt)) }
            throw error
        }
    }

    func lastPageFetch(for sourceID: DocumentationSourceID) async -> Date? {
        do {
            return try await store.lastPageFetch(for: sourceID)
        } catch {
            Self.logger.error("Reading last fetch date of \(sourceID.rawValue, privacy: .public) failed: \(error)")
            return nil
        }
    }

    /// - Parameter forceRevalidation: Ask the source even if the cached copy is still fresh (pull-to-refresh).
    func load(
        _ url: URL,
        key: String,
        sourceID: DocumentationSourceID,
        maxAge: Duration,
        forceRevalidation: Bool = false,
        policy: CachePolicy = .standard
    ) async throws -> (data: Data, freshness: Freshness) {
        let cached = await cachedResource(forKey: key)

        if let cached, !forceRevalidation, policy.isFresh(fetchedAt: cached.fetchedAt, maxAge: maxAge, now: now()) {
            return (cached.data, .cached(fetchedAt: cached.fetchedAt))
        }

        do {
            switch try await http.get(url, validators: cached?.validators) {
            case .modified(let data, let validators):
                await persist(data, validators: validators, key: key, sourceID: sourceID)
                return (data, .fresh)
            case .notModified:
                guard let cached else { throw DocumentationError.invalidResponse }
                await markRevalidated(key: key)
                return (cached.data, .fresh)
            }
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            // Includes `HTTPStatusError` (e.g. 404): a cached copy stays readable; callers map the error otherwise.
            if let cached { return (cached.data, .stale(fetchedAt: cached.fetchedAt)) }
            throw error
        }
    }

    // MARK: Cache access (logged, never fatal to a load)

    private func cachedResource(forKey key: String) async -> CachedResource? {
        do {
            return try await store.resource(forKey: key)
        } catch {
            Self.logger.error("Reading cache for \(key, privacy: .public) failed: \(error)")
            return nil
        }
    }

    private func persist(_ data: Data, validators: CacheValidators, key: String, sourceID: DocumentationSourceID) async {
        do {
            try await store.store(data, validators: validators, forKey: key, sourceID: sourceID, at: now())
        } catch {
            Self.logger.error("Caching \(key, privacy: .public) failed: \(error)")
        }
    }

    private func markRevalidated(key: String) async {
        do {
            try await store.markRevalidated(key: key, at: now())
        } catch {
            Self.logger.error("Marking \(key, privacy: .public) as revalidated failed: \(error)")
        }
    }
}
