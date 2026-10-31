import Foundation
import Testing
@testable import atlas

@Suite("Deprecation mapping")
struct DeprecationMappingTests {
    let source = TestDocumentationSource()

    private func detail(_ data: Data) async throws -> DocumentationDetail {
        try await DocCParser.detail(from: data, source: source)
    }

    @Test("A page with a deprecation summary is deprecated, with its notice and replacements")
    func summary() async throws {
        let detail = try await detail(DocCFixtures.deprecatedPage)

        #expect(detail.isDeprecated)
        #expect(detail.entry.isDeprecated)
        #expect(detail.replacements.map(\.title) == ["NewView"])
        guard case .paragraph(let inlines) = detail.deprecationNotice.first else {
            Issue.record("Expected a notice paragraph"); return
        }
        #expect(inlines.map(\.plainText).joined() == "Use NewView instead.")
    }

    @Test("Deprecated on a single platform only is not a deprecated page")
    func partial() async throws {
        let detail = try await detail(DocCFixtures.partlyDeprecatedPage)
        #expect(!detail.isDeprecated)
        #expect(detail.deprecationNotice.isEmpty)
        #expect(detail.availability.last?.deprecatedAt == "10.0")
    }

    @Test("Without a summary, the platforms' message becomes the notice")
    func messageFallback() async throws {
        let detail = try await detail(DocCFixtures.messageOnlyDeprecatedPage)
        #expect(detail.isDeprecated)
        #expect(detail.deprecationNotice == [.paragraph([.text("Use modern() instead.")])])
        #expect(detail.replacements.isEmpty)
    }

    @Test("Deprecated links are flagged and grouped apart in topics")
    func deprecatedReferences() async throws {
        let group = try #require(try await detail(DocCFixtures.deprecatedPage).topics.first)
        #expect(group.currentEntries.map(\.title) == ["NewView"])
        #expect(group.deprecatedEntries.map(\.title) == ["OlderView"])
    }

    @Test("Deprecated navigator index nodes are flagged")
    func navigatorIndex() async throws {
        let entries = try await DocCParser.searchEntries(from: DocCFixtures.frameworkIndex, source: source)
        #expect(entries.first { $0.title == "OldWidget" }?.isDeprecated == true)
        #expect(entries.first { $0.title == "MainWidget" }?.isDeprecated == false)
    }
}
