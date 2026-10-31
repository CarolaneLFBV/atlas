import Testing
@testable import atlas

@Suite("DocumentationSearchRanker")
struct DocumentationSearchRankerTests {
    let ranker = DocumentationSearchRanker()

    @Test("Exact match beats prefix, which beats word prefix, which beats substring")
    func orderingByMatchQuality() {
        let candidates = [
            Fixture.entry("ScrollViewReader"),      // prefix of word "View"
            Fixture.entry("Viewport"),              // title prefix
            Fixture.entry("View"),                  // exact
            Fixture.entry("Preview", path: "/p"),   // substring only
        ]
        let titles = ranker.rank(candidates, for: "view", limit: 10).map(\.title)
        #expect(titles == ["View", "Viewport", "ScrollViewReader", "Preview"])
    }

    @Test("Camel-case word starts are matched")
    func camelCaseWordStart() {
        #expect(DocumentationSearchRanker.wordStarts(in: "NavigationStack") == ["navigationstack", "stack"])
        let results = ranker.rank([Fixture.entry("NavigationStack")], for: "stack", limit: 5)
        #expect(results.count == 1)
    }

    @Test("Keywords and framework names match with lower priority")
    func keywordAndFrameworkMatches() {
        let byKeyword = Fixture.entry("Observable", keywords: ["state management"])
        let byFramework = Fixture.entry("ModelContainer", framework: "SwiftData")
        let direct = Fixture.entry("StateObject")
        #expect(ranker.rank([byKeyword, direct], for: "state", limit: 5).map(\.title) == ["StateObject", "Observable"])
        #expect(ranker.rank([byFramework], for: "swiftdata", limit: 5).map(\.title) == ["ModelContainer"])
    }

    @Test("Frameworks are boosted over symbols with the same match quality")
    func frameworkBoost() {
        let symbol = Fixture.entry("Vision", path: "/symbol")
        let framework = Fixture.entry("Vision", path: "/framework", kind: .framework)
        #expect(ranker.rank([symbol, framework], for: "vision", limit: 5).first?.kind == .framework)
    }

    @Test("Matching is case and diacritic insensitive")
    func folding() {
        #expect(ranker.rank([Fixture.entry("Café")], for: "CAFE", limit: 5).count == 1)
    }

    @Test("Duplicates are removed and the limit is respected")
    func deduplicationAndLimit() {
        let entry = Fixture.entry("Text")
        let many = (0..<20).map { Fixture.entry("Text\($0)") }
        #expect(ranker.rank([entry, entry], for: "text", limit: 10).count == 1)
        #expect(ranker.rank(many, for: "text", limit: 5).count == 5)
    }

    @Test("Non-matching and empty queries return nothing")
    func noMatches() {
        #expect(ranker.rank([Fixture.entry("Button")], for: "toggle", limit: 5).isEmpty)
        #expect(ranker.rank([Fixture.entry("Button")], for: "   ", limit: 5).isEmpty)
    }

    @Test("Deprecated APIs rank below current ones, but an exact match still comes first")
    func deprecatedRanking() {
        let current = Fixture.entry("NavigationStack", path: "/stack")
        let deprecated = DocumentationEntry(id: Fixture.id("/view"), title: "NavigationView", kind: .symbol(.structure), isDeprecated: true)

        #expect(ranker.rank([deprecated, current], for: "navigation", limit: 5).map(\.title) == ["NavigationStack", "NavigationView"])
        #expect(ranker.rank([current, deprecated], for: "navigationview", limit: 5).first?.title == "NavigationView")
    }
}
