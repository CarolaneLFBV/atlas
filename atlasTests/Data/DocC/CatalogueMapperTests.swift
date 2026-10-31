import Foundation
import Testing
@testable import atlas

@Suite("CatalogueMapper")
struct CatalogueMapperTests {
    @Test("Technologies become categories, with duplicates and empty groups removed")
    func technologies() async throws {
        var source = TestDocumentationSource()
        source.catalogueFormat = .technologies
        let categories = try await DocCParser.catalogueCategories(from: DocCFixtures.technologies, source: source)

        #expect(categories.map(\.name) == ["App Frameworks"])
        let framework = try #require(categories.first?.frameworks.first)
        #expect(categories.first?.frameworks.count == 1)
        #expect(framework.title == "TestKit")
        #expect(framework.id.path == "/documentation/testkit")
        #expect(framework.abstract == "Fixture framework.")
        #expect(framework.tags == ["UI"])
    }

    @Test("A root page becomes a single catalogue entry in its category")
    func rootPage() async throws {
        let categories = try await DocCParser.catalogueCategories(from: DocCFixtures.rootPage, source: TestDocumentationSource())
        #expect(categories.map(\.name) == ["Test Category"])
        #expect(categories.first?.frameworks.map(\.title) == ["Test Book"])
    }

    @Test("Navigator index pages become search entries; group markers are skipped")
    func navigatorIndex() async throws {
        let entries = try await DocCParser.searchEntries(from: DocCFixtures.navigatorIndex, source: TestDocumentationSource())
        #expect(entries.map(\.title) == ["Test Book", "The Basics"])
        #expect(entries.last?.keywords == ["Test Book", "Basics"])
        #expect(entries.last?.kind == .article)
    }
}
