import Testing
@testable import atlas

@Suite("SearchResultGroups")
struct SearchResultGroupsTests {
    private let results: [SearchResult] = [
        SearchResult(entry: Fixture.entry("NavigationStack"), match: .metadata),
        SearchResult(entry: Fixture.entry("SwiftUI", kind: .framework), match: .metadata),
        SearchResult(entry: Fixture.entry("init(path:root:)", kind: .symbol(.initializer)), match: .metadata),
        SearchResult(entry: Fixture.entry("Navigation", kind: .article), match: .metadata),
        SearchResult(entry: Fixture.entry("Concurrency", kind: .article), match: .text(sectionTitle: "Actors", excerpt: "…")),
    ]

    @Test("The best match is the top hit; the rest is grouped by kind, in ranking order")
    func grouping() {
        let groups = SearchResultGroups(results, scope: .all)
        #expect(groups.topHit?.entry.title == "NavigationStack")
        #expect(groups.frameworks.map(\.entry.title) == ["SwiftUI"])
        #expect(groups.symbols.map(\.entry.title) == ["init(path:root:)"])
        #expect(groups.articles.map(\.entry.title) == ["Navigation"])
        #expect(groups.passages.map(\.entry.title) == ["Concurrency"])
    }

    @Test("A scope keeps only its kind; text passages count as articles")
    func scopes() {
        let symbols = SearchResultGroups(results, scope: .symbols)
        #expect(symbols.topHit?.entry.title == "NavigationStack")
        #expect(symbols.symbols.map(\.entry.title) == ["init(path:root:)"])
        #expect(symbols.frameworks.isEmpty && symbols.articles.isEmpty && symbols.passages.isEmpty)

        let articles = SearchResultGroups(results, scope: .articles)
        #expect(articles.topHit?.entry.title == "Navigation")
        #expect(articles.passages.count == 1)
    }

    @Test("A scope without matches is empty")
    func emptyScope() {
        let groups = SearchResultGroups([results[0]], scope: .frameworks)
        #expect(groups.isEmpty)
    }
}
