import Foundation
import SwiftData
import Testing
@testable import atlas

@MainActor
@Suite("CachedDocumentationRepository")
struct CachedDocumentationRepositoryTests {
    let container: ModelContainer
    let http = FakeHTTPClient()
    let indexes = SearchIndexes.inMemory()

    init() throws {
        container = try PersistenceStore.makeContainer(inMemory: true)
    }

    private func repository(_ sources: [any DocumentationSource]) -> CachedDocumentationRepository {
        CachedDocumentationRepository(
            sources: sources,
            sync: DocumentationSyncService(http: http, store: CachedResourceStore(modelContainer: container)),
            searchIndex: indexes.metadata,
            fullTextIndex: indexes.fullText
        )
    }

    @Test("Disabled sources are never contacted and report sourceDisabled")
    func disabledSource() async throws {
        var source = TestDocumentationSource()
        source.isEnabled = false
        let repository = repository([source])

        let catalogue = try await repository.catalogue()
        #expect(catalogue.value.isEmpty)
        await #expect(throws: DocumentationError.sourceDisabled(source.id)) {
            try await repository.detail(for: DocumentationID(sourceID: source.id, path: "/documentation/testkit/widget"))
        }
        #expect(await http.requests.isEmpty)
        #expect(repository.sourceStatuses.first?.isEnabled == false)
    }

    @Test("Catalogues from several sources are merged; one failing source doesn't hide the others")
    func catalogueMerge() async throws {
        let book = TestDocumentationSource()
        var broken = TestDocumentationSource()
        broken.id = DocumentationSourceID(rawValue: "broken")
        await http.respond(to: try #require(book.catalogueURL), with: .modified(DocCFixtures.rootPage))
        await http.respond(to: try #require(broken.catalogueURL), with: .failure(DocumentationError.offline))

        let catalogue = try await repository([book, broken]).catalogue()

        #expect(catalogue.value.allFrameworks.map(\.title) == ["Test Book"])
    }

    @Test("When every source fails without a cache, the error is surfaced")
    func catalogueFailure() async throws {
        let source = TestDocumentationSource()
        await http.respond(to: try #require(source.catalogueURL), with: .failure(DocumentationError.offline))
        await #expect(throws: DocumentationError.offline) {
            try await repository([source]).catalogue()
        }
    }

    @Test("Opening a page maps it and makes it and its links searchable")
    func detailIndexesEntries() async throws {
        let source = TestDocumentationSource()
        let id = DocumentationID(sourceID: source.id, path: "/documentation/testkit/widget")
        await http.respond(to: try #require(source.pageDataURL(forPath: id.path)), with: .modified(DocCFixtures.symbolPage))
        let repository = repository([source])

        let detail = try await repository.detail(for: id)

        #expect(detail.value.entry.title == "Widget")
        #expect(try await repository.searchCandidates(matching: "widget").map(\.title) == ["Widget"])
        #expect(try await repository.searchCandidates(matching: "view").map(\.title) == ["View"])
    }

    @Test("A missing page is reported as notFound")
    func notFound() async throws {
        let source = TestDocumentationSource()
        let id = DocumentationID(sourceID: source.id, path: "/documentation/gone")
        await http.respond(to: try #require(source.pageDataURL(forPath: id.path)), with: .failure(HTTPStatusError(statusCode: 404)))
        await #expect(throws: DocumentationError.notFound(id)) {
            try await repository([source]).detail(for: id)
        }
    }

    @Test("Bookmarks are untouched by catalogue updates")
    func bookmarksSurviveSync() async throws {
        let source = TestDocumentationSource()
        let bookmarks = SwiftDataBookmarkRepository(context: container.mainContext)
        let entry = Fixture.entry("Kept")
        try bookmarks.addBookmark(for: entry, at: .now)
        await http.respond(to: try #require(source.catalogueURL), with: .modified(DocCFixtures.rootPage))

        _ = try await repository([source]).refreshCatalogue()

        #expect(try bookmarks.isBookmarked(entry.id))
    }

    @Test("Freshness combines to the least current value")
    func combinedFreshness() {
        let old = Date(timeIntervalSince1970: 1)
        let new = Date(timeIntervalSince1970: 2)
        #expect(CatalogueMerging.combined([.fresh, .cached(fetchedAt: new), .cached(fetchedAt: old)]) == .cached(fetchedAt: old))
        #expect(CatalogueMerging.combined([.cached(fetchedAt: old), .stale(fetchedAt: new)]) == .stale(fetchedAt: new))
        #expect(CatalogueMerging.combined([]) == .fresh)
    }
}
