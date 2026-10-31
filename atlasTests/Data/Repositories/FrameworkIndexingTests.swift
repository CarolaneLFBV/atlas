import Foundation
import SwiftData
import Testing
@testable import atlas

@MainActor
@Suite("Framework indexing")
struct FrameworkIndexingTests {
    let container: ModelContainer
    let http = FakeHTTPClient()
    let indexes = SearchIndexes.inMemory()
    let frameworkID: DocumentationID
    var source = TestDocumentationSource()

    init() throws {
        container = try PersistenceStore.makeContainer(inMemory: true)
        source.frameworkIndexBase = URL(string: "https://docs.example.com/test/index")
        frameworkID = DocumentationID(sourceID: source.id, path: "/documentation/testkit")
    }

    private func makeRepository(indexes: SearchIndexes? = nil) -> CachedDocumentationRepository {
        let indexes = indexes ?? self.indexes
        return CachedDocumentationRepository(
            sources: [source],
            sync: DocumentationSyncService(http: http, store: CachedResourceStore(modelContainer: container)),
            searchIndex: indexes.metadata,
            fullTextIndex: indexes.fullText
        )
    }

    private func respondWithFramework() async throws {
        await http.respond(to: try #require(source.pageDataURL(forPath: frameworkID.path)), with: .modified(DocCFixtures.frameworkPage))
        await http.respond(to: try #require(source.frameworkIndexURL(forFrameworkPath: frameworkID.path)), with: .modified(DocCFixtures.frameworkIndex))
    }

    private func waitForIndexing(_ repository: CachedDocumentationRepository) async {
        for task in repository.frameworkIndexingTasks.values { await task.value }
    }

    @Test("Opening a framework makes its whole API searchable by name")
    func indexesOnOpen() async throws {
        try await respondWithFramework()
        let repository = makeRepository()

        _ = try await repository.detail(for: frameworkID)
        await waitForIndexing(repository)

        let results = try await SearchDocumentationUseCase(repository: repository).execute(query: "MainWidget")
        #expect(results.first?.entry.title == "MainWidget")
        #expect(results.first?.entry.kind == .symbol(.classType))
        #expect(results.first?.entry.frameworkName == "TestKit")
        #expect(results.contains { $0.entry.title == "static let shared: MainWidget" })
    }

    @Test("Default-implementation groups are skipped but their members stay searchable")
    func skipsImplementationGroups() async throws {
        try await respondWithFramework()
        let repository = makeRepository()

        _ = try await repository.detail(for: frameworkID)
        await waitForIndexing(repository)

        let search = SearchDocumentationUseCase(repository: repository)
        #expect(try await search.execute(query: "Implementations").isEmpty)
        #expect(try await search.execute(query: "render").map(\.entry.title) == ["func render()"])
    }

    @Test("Reopening a framework within a week doesn't download its index again")
    func noRedownload() async throws {
        try await respondWithFramework()
        let repository = makeRepository()

        _ = try await repository.detail(for: frameworkID)
        await waitForIndexing(repository)
        _ = try await repository.detail(for: frameworkID)
        await waitForIndexing(repository)

        let indexURL = try #require(source.frameworkIndexURL(forFrameworkPath: frameworkID.path))
        #expect(await http.requests.filter { $0.url == indexURL }.count == 1)
    }

    @Test("A rebuilt index is refilled from the cached framework index, without a request")
    func reindexesAfterRebuild() async throws {
        try await respondWithFramework()
        let first = makeRepository()
        _ = try await first.detail(for: frameworkID)
        await waitForIndexing(first)

        let rebuilt = makeRepository(indexes: .inMemory())
        _ = try await rebuilt.detail(for: frameworkID)
        await waitForIndexing(rebuilt)

        let indexURL = try #require(source.frameworkIndexURL(forFrameworkPath: frameworkID.path))
        #expect(await http.requests.filter { $0.url == indexURL }.count == 1)
        #expect(try await SearchDocumentationUseCase(repository: rebuilt).execute(query: "MainWidget").first?.entry.title == "MainWidget")
    }

    @Test("Symbol pages don't trigger a framework index")
    func symbolsDontIndex() async throws {
        let id = DocumentationID(sourceID: source.id, path: "/documentation/testkit/widget")
        await http.respond(to: try #require(source.pageDataURL(forPath: id.path)), with: .modified(DocCFixtures.symbolPage))
        let repository = makeRepository()

        _ = try await repository.detail(for: id)

        #expect(repository.frameworkIndexingTasks.isEmpty)
    }
}
