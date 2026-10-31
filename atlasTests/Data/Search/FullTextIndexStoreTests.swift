import Foundation
import Testing
@testable import atlas

@Suite("FullTextIndexStore")
struct FullTextIndexStoreTests {
    let store: FullTextIndexStore
    let page = Fixture.entry("Migrating", path: "/documentation/guide/migrating")

    init() throws {
        store = try FullTextIndexStore(location: .inMemory)
    }

    @Test("Text matches name the page and section, with an excerpt")
    func matches() async throws {
        try await store.replacePassages(of: page, with: [
            .init(title: "Overview", text: "Nothing relevant."),
            .init(title: "SwiftPM", text: "Mark the function @concurrent to keep it off the actor."),
        ])
        let matches = try await store.matches(for: "@CONCURRENT", enabledSources: [.apple])
        #expect(matches.count == 1)
        #expect(matches.first?.entry == page)
        #expect(matches.first?.sectionTitle == "SwiftPM")
        #expect(matches.first?.excerpt.contains("@concurrent") == true)
    }

    @Test("Re-indexing a page replaces its passages instead of accumulating them")
    func replacesPassages() async throws {
        try await store.replacePassages(of: page, with: [.init(title: "Old", text: "legacy wording")])
        try await store.replacePassages(of: page, with: [.init(title: "New", text: "current wording")])

        #expect(try await store.matches(for: "legacy", enabledSources: [.apple]).isEmpty)
        #expect(try await store.matches(for: "wording", enabledSources: [.apple]).map(\.sectionTitle) == ["New"])
        #expect(try await store.pageCount(for: .apple) == 1)
    }

    @Test("Passages whose heading names the query come first")
    func headingsFirst() async throws {
        let other = Fixture.entry("Zeta", path: "/documentation/guide/zeta")
        try await store.replacePassages(of: other, with: [.init(title: "Intro", text: "Uses actors a lot.")])
        try await store.replacePassages(of: page, with: [.init(title: "Actors", text: "Isolation.")])
        #expect(try await store.matches(for: "actors", enabledSources: [.apple]).map(\.sectionTitle) == ["Actors", "Intro"])
    }

    @Test("Pages without passages are not counted")
    func emptyPages() async throws {
        try await store.replacePassages(of: page, with: [.init(title: "S", text: "text")])
        try await store.replacePassages(of: page, with: [])
        #expect(try await store.pageCount(for: .apple) == 0)
    }

    @Test("Disabled sources are excluded")
    func respectsEnabledSources() async throws {
        try await store.replacePassages(of: page, with: [.init(title: "S", text: "text")])
        #expect(try await store.matches(for: "text", enabledSources: []).isEmpty)
    }

    @Test("Excerpts are centred on the match and cut at word boundaries")
    func excerpt() {
        let text = (Array(repeating: "alpha", count: 30) + ["needle"] + Array(repeating: "omega", count: 30)).joined(separator: " ")
        let excerpt = FullTextIndexStore.excerpt(of: text, around: "needle", radius: 20)
        #expect(excerpt.hasPrefix("…"))
        #expect(excerpt.hasSuffix("…"))
        #expect(excerpt.contains("needle"))
        #expect(!excerpt.contains("alph…"))
    }
}
