import Foundation
import SwiftData
import Testing
@testable import atlas

@MainActor
@Suite("DocumentationSyncService")
struct DocumentationSyncServiceTests {
    let container: ModelContainer
    let store: CachedResourceStore
    let http = FakeHTTPClient()
    let url = URL(string: "https://docs.example.com/page.json")!
    let source = DocumentationSourceID(rawValue: "test")
    let clock = Date(timeIntervalSince1970: 1_000_000)

    init() throws {
        container = try PersistenceStore.makeContainer(inMemory: true)
        store = CachedResourceStore(modelContainer: container)
    }

    private func service(at date: Date) -> DocumentationSyncService {
        DocumentationSyncService(http: http, store: store, now: { date })
    }

    private func load(at date: Date, force: Bool = false) async throws -> (data: Data, freshness: Freshness) {
        try await service(at: date).load(url, key: "page", sourceID: source, maxAge: .seconds(60), forceRevalidation: force)
    }

    @Test("A first load downloads and caches the resource")
    func firstLoad() async throws {
        await http.respond(to: url, with: .modified(Data("v1".utf8)))
        let result = try await load(at: clock)
        #expect(result.data == Data("v1".utf8))
        #expect(result.freshness == .fresh)
        #expect(try await store.resource(forKey: "page")?.validators.etag == "\"v1\"")
    }

    @Test("A fresh cached copy is served without any request")
    func freshCacheHit() async throws {
        await http.respond(to: url, with: .modified(Data("v1".utf8)))
        _ = try await load(at: clock)
        let result = try await load(at: clock.addingTimeInterval(30))
        #expect(result.freshness == .cached(fetchedAt: clock))
        #expect(await http.requests.count == 1)
    }

    @Test("A stale copy is revalidated with its ETag; 304 keeps the cached data")
    func revalidation() async throws {
        await http.respond(to: url, with: .modified(Data("v1".utf8)))
        _ = try await load(at: clock)
        await http.respond(to: url, with: .notModified)

        let later = clock.addingTimeInterval(120)
        let result = try await load(at: later)

        #expect(result.data == Data("v1".utf8))
        #expect(result.freshness == .fresh)
        #expect(await http.requests.last?.validators?.etag == "\"v1\"")
        #expect(try await store.resource(forKey: "page")?.fetchedAt == later)
    }

    @Test("Forced revalidation asks the source even when the copy is fresh")
    func forcedRevalidation() async throws {
        await http.respond(to: url, with: .modified(Data("v1".utf8)))
        _ = try await load(at: clock)
        await http.respond(to: url, with: .modified(Data("v2".utf8), CacheValidators(etag: "\"v2\"")))

        let result = try await load(at: clock.addingTimeInterval(1), force: true)

        #expect(result.data == Data("v2".utf8))
        #expect(await http.requests.count == 2)
    }

    @Test("Offline with a cached copy serves it as stale and keeps the cache")
    func offlineFallsBackToCache() async throws {
        await http.respond(to: url, with: .modified(Data("v1".utf8)))
        _ = try await load(at: clock)
        await http.respond(to: url, with: .failure(DocumentationError.offline))

        let result = try await load(at: clock.addingTimeInterval(120))

        #expect(result.data == Data("v1".utf8))
        #expect(result.freshness == .stale(fetchedAt: clock))
        #expect(try await store.resource(forKey: "page") != nil)
    }

    @Test("Offline without a cached copy reports the error")
    func offlineWithoutCache() async {
        await http.respond(to: url, with: .failure(DocumentationError.offline))
        await #expect(throws: DocumentationError.offline) {
            try await load(at: clock)
        }
    }

    @Test("Pinned loads skip the request when the version is unchanged, and refetch when it changes")
    func pinnedLoads() async throws {
        await http.respond(to: url, with: .modified(Data("v1".utf8)))
        _ = try await service(at: clock).loadPinned(url, key: "pinned", sourceID: source, version: "sha1")
        _ = try await service(at: clock).loadPinned(url, key: "pinned", sourceID: source, version: "sha1")
        #expect(await http.requests.count == 1)

        await http.respond(to: url, with: .modified(Data("v2".utf8)))
        let updated = try await service(at: clock).loadPinned(url, key: "pinned", sourceID: source, version: "sha2")
        #expect(updated.data == Data("v2".utf8))
        #expect(await http.requests.count == 2)
    }

    @Test("A pinned load that fails keeps serving the cached copy")
    func pinnedOffline() async throws {
        await http.respond(to: url, with: .modified(Data("v1".utf8)))
        _ = try await service(at: clock).loadPinned(url, key: "pinned", sourceID: source, version: "sha1")
        await http.respond(to: url, with: .failure(DocumentationError.offline))

        let result = try await service(at: clock).loadPinned(url, key: "pinned", sourceID: source, version: "sha2")

        #expect(result.data == Data("v1".utf8))
        #expect(result.freshness == .stale(fetchedAt: clock))
    }
}
