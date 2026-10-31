import Foundation
import Testing
@testable import atlas

@Suite("SearchIndexStore")
struct SearchIndexStoreTests {
    let store: SearchIndexStore

    init() throws {
        store = try SearchIndexStore(location: .inMemory)
    }

    @Test("Indexing the same entry twice keeps a single record")
    func noDuplicates() async throws {
        let entry = Fixture.entry("NavigationStack")
        try await store.index([entry, entry])
        try await store.index([entry])
        #expect(try await store.candidates(matching: "navigation", enabledSources: [.apple]).count == 1)
    }

    @Test("Matching is case and diacritic insensitive and includes keywords")
    func matching() async throws {
        try await store.index([Fixture.entry("Café"), Fixture.entry("Observable", keywords: ["State Management"])])
        #expect(try await store.candidates(matching: "CAFE", enabledSources: [.apple]).map(\.title) == ["Café"])
        #expect(try await store.candidates(matching: "management", enabledSources: [.apple]).map(\.title) == ["Observable"])
    }

    @Test("Substrings match anywhere, including short queries and LIKE wildcards taken literally")
    func substrings() async throws {
        try await store.index([Fixture.entry("ScrollViewReader"), Fixture.entry("Some_Thing"), Fixture.entry("SomeXThing")])
        #expect(try await store.candidates(matching: "viewread", enabledSources: [.apple]).map(\.title) == ["ScrollViewReader"])
        #expect(try await store.candidates(matching: "wr", enabledSources: [.apple]).map(\.title) == ["ScrollViewReader"])
        #expect(try await store.candidates(matching: "e_t", enabledSources: [.apple]).map(\.title) == ["Some_Thing"])
    }

    @Test("Entries from disabled sources are not returned")
    func respectsEnabledSources() async throws {
        try await store.index([Fixture.entry("Text")])
        #expect(try await store.candidates(matching: "text", enabledSources: []).isEmpty)
        #expect(try await store.candidates(matching: "text", enabledSources: [DocumentationSourceID(rawValue: "other")]).isEmpty)
    }

    @Test("An exact title match is returned even when a broad query has more matches than the limit")
    func exactMatchesAreNeverCrowdedOut() async throws {
        let limited = try SearchIndexStore(location: .inMemory, candidateLimit: 10)
        let noise = (0..<50).map { Fixture.entry("SomeViewThing\($0)") }
        try await limited.index(noise + [Fixture.entry("View")])

        let titles = try await limited.candidates(matching: "view", enabledSources: [.apple]).map(\.title)

        #expect(titles.count == 10)
        #expect(titles.first == "View")
    }

    @Test("Title prefix matches come before other matches")
    func prefixTier() async throws {
        let limited = try SearchIndexStore(location: .inMemory, candidateLimit: 2)
        try await limited.index([Fixture.entry("AView"), Fixture.entry("BView"), Fixture.entry("ViewBuilder")])
        #expect(try await limited.candidates(matching: "view", enabledSources: [.apple]).first?.title == "ViewBuilder")
    }

    @Test("Large lists are indexed in batches without losing entries")
    func batchIndexing() async throws {
        let batched = try SearchIndexStore(location: .inMemory, candidateLimit: 2_000, batchSize: 100)
        let entries = (0..<1_234).map { Fixture.entry("Symbol\($0)") }
        try await batched.index(entries)
        #expect(try await batched.candidates(matching: "symbol", enabledSources: [.apple]).count == 1_234)
    }

    @Test("A sparse re-index does not erase a richer abstract")
    func keepsRicherData() async throws {
        let rich = Fixture.entry("List")
        let sparse = DocumentationEntry(id: rich.id, title: rich.title, kind: rich.kind, frameworkName: rich.frameworkName)
        try await store.index([rich])
        try await store.index([sparse])
        #expect(try await store.candidates(matching: "list", enabledSources: [.apple]).first?.abstract == rich.abstract)
    }

    @Test("A change of deprecation status is picked up even from a sparse entry")
    func updatesDeprecation() async throws {
        let rich = Fixture.entry("OldAPI")
        let sparseDeprecated = DocumentationEntry(id: rich.id, title: rich.title, kind: rich.kind, isDeprecated: true)
        try await store.index([rich])
        try await store.index([sparseDeprecated])

        let stored = try #require(try await store.entry(for: rich.id))
        #expect(stored.isDeprecated)
        #expect(stored.abstract == rich.abstract)
    }

    @Test("Indexed resources are remembered")
    func indexedResources() async throws {
        #expect(try await !store.hasIndexed(resourceKey: "apple:framework-index:/documentation/swiftui"))
        try await store.markIndexed(resourceKey: "apple:framework-index:/documentation/swiftui")
        #expect(try await store.hasIndexed(resourceKey: "apple:framework-index:/documentation/swiftui"))
    }

    @Test("The index persists across connections")
    func persistence() async throws {
        let url = URL.temporaryDirectory.appending(path: "atlas-\(UUID().uuidString)/SearchIndex.sqlite")
        defer { try? FileManager.default.removeItem(at: url.deletingLastPathComponent()) }

        try await SearchIndexStore(location: .file(url)).index([Fixture.entry("Persisted")])
        #expect(try await SearchIndexStore(location: .file(url)).candidates(matching: "persisted", enabledSources: [.apple]).count == 1)
    }
}
