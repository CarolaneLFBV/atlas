import Foundation
import SwiftData
import Testing
@testable import atlas

@MainActor
@Suite("Offline download")
struct OfflineDownloadTests {
    let container: ModelContainer
    let http = FakeHTTPClient()
    let indexes = SearchIndexes.inMemory()

    init() throws {
        container = try PersistenceStore.makeContainer(inMemory: true)
    }

    private func repository(_ source: TestDocumentationSource) -> CachedDocumentationRepository {
        CachedDocumentationRepository(
            sources: [source],
            sync: DocumentationSyncService(http: http, store: CachedResourceStore(modelContainer: container)),
            searchIndex: indexes.metadata,
            fullTextIndex: indexes.fullText
        )
    }

    private var downloadableSource: TestDocumentationSource {
        var source = TestDocumentationSource()
        source.searchIndexURL = URL(string: "https://docs.example.com/test/index/index.json")
        return source
    }

    @Test("Every indexed page is downloaded; one failing page doesn't abort the rest")
    func downloadsAllPages() async throws {
        let source = downloadableSource
        await http.respond(to: try #require(source.searchIndexURL), with: .modified(DocCFixtures.navigatorIndex))
        await http.respond(to: try #require(source.pageDataURL(forPath: "/documentation/root")), with: .modified(DocCFixtures.symbolPage))
        await http.respond(to: try #require(source.pageDataURL(forPath: "/documentation/root/thebasics")), with: .failure(DocumentationError.offline))
        let repository = repository(source)
        var reported: [(Int, Int)] = []

        let downloaded = try await repository.downloadForOffline(source.id) { reported.append(($0, $1)) }

        #expect(downloaded == 1)
        #expect(reported.last.map { [$0.0, $0.1] } == [2, 2])
        #expect(await repository.searchCapability().fullTextSourceNames == [source.displayName])
        let statuses = try await repository.offlineStatuses()
        #expect(statuses.first?.downloadedPages == 1)
    }

    @Test("Downloaded text is searchable through the search use case")
    func fullTextSearch() async throws {
        let source = downloadableSource
        await http.respond(to: try #require(source.searchIndexURL), with: .modified(DocCFixtures.navigatorIndex))
        await http.respond(to: try #require(source.pageDataURL(forPath: "/documentation/root")), with: .modified(DocCFixtures.symbolPage))
        let repository = repository(source)
        try await repository.downloadForOffline(source.id) { _, _ in }

        let results = try await SearchDocumentationUseCase(repository: repository).execute(query: "careful")

        guard case .text(let section, let excerpt) = results.first?.match else {
            Issue.record("Expected a full-text match, got \(results)")
            return
        }
        #expect(results.first?.entry.title == "Widget")
        #expect(section == "Usage")
        #expect(excerpt.localizedCaseInsensitiveContains("careful"))
    }

    @Test("Sources that don't allow offline download are refused without any request")
    func refusesRestrictedSources() async throws {
        var source = downloadableSource
        source.allowsOfflineDownload = false
        let repository = repository(source)

        await #expect(throws: DocumentationError.sourceDisabled(source.id)) {
            try await repository.downloadForOffline(source.id) { _, _ in }
        }
        #expect(await http.requests.isEmpty)
        #expect(try await repository.offlineStatuses().isEmpty)
    }

    @Test("Pages of restricted sources are never full-text indexed when opened")
    func noFullTextForRestrictedSources() async throws {
        var source = downloadableSource
        source.allowsOfflineDownload = false
        let id = DocumentationID(sourceID: source.id, path: "/documentation/testkit/widget")
        await http.respond(to: try #require(source.pageDataURL(forPath: id.path)), with: .modified(DocCFixtures.symbolPage))
        let repository = repository(source)

        _ = try await repository.detail(for: id)

        #expect(await !repository.searchCapability().includesFullText)
        #expect(try await repository.fullTextMatches(matching: "careful").isEmpty)
    }
}
