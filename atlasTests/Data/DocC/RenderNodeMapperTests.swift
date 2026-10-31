import Foundation
import Testing
@testable import atlas

@Suite("RenderNodeMapper")
struct RenderNodeMapperTests {
    private func detail(permission: RenderingPermission? = nil) async throws -> DocumentationDetail {
        var source = TestDocumentationSource()
        if let permission { source.permission = permission }
        return try await DocCParser.detail(from: DocCFixtures.symbolPage, source: source)
    }

    @Test("Page identity, kind, framework and canonical link are mapped")
    func entry() async throws {
        let entry = try await detail().entry
        #expect(entry.id == DocumentationID(sourceID: TestDocumentationSource().id, path: "/documentation/testkit/widget"))
        #expect(entry.title == "Widget")
        #expect(entry.kind == .symbol(.structure))
        #expect(entry.frameworkName == "TestKit")
        #expect(entry.abstract == "A fixture struct.")
        #expect(entry.webURL?.absoluteString == "https://docs.example.com/test/documentation/testkit/widget")
    }

    @Test("Declaration tokens keep their kinds and links")
    func declaration() async throws {
        let declaration = try #require(try await detail().declaration)
        #expect(declaration.source == "struct Widget : View")
        #expect(declaration.tokens.first?.kind == .keyword)
        #expect(declaration.tokens.last?.reference?.path == "/documentation/testkit/view")
    }

    @Test("Content is split into sections at level-2 headings")
    func sections() async throws {
        let detail = try await detail()
        #expect(detail.sections.map(\.title) == ["Overview", "Usage"])
        #expect(detail.codeExamples.map(\.code) == ["let w = Widget()\nprint(w)"])
    }

    @Test("Unknown block and inline types degrade instead of failing the page")
    func tolerantDecoding() async throws {
        let usage = try #require(try await detail().sections.last)
        #expect(usage.blocks.contains(.unsupported(kind: "table")))
        #expect(usage.blocks.contains(.paragraph([.text("Still readable")])))
    }

    @Test("References become links to pages with their titles")
    func references() async throws {
        let overview = try #require(try await detail().sections.first)
        guard case .paragraph(let inlines) = overview.blocks.first else {
            Issue.record("Expected a paragraph")
            return
        }
        #expect(inlines.last == .reference(DocumentationID(sourceID: TestDocumentationSource().id, path: "/documentation/testkit/view"), title: "View"))
    }

    @Test("Topics resolve references and skip missing ones; relationships are included")
    func topics() async throws {
        let detail = try await detail()
        #expect(detail.topics.map(\.title) == ["Essentials"])
        #expect(detail.topics.first?.entries.map(\.title) == ["View"])
        #expect(detail.relationships.first?.title == "Conforms To")
    }

    @Test("Availability is mapped, including beta")
    func availability() async throws {
        let availability = try await detail().availability
        #expect(availability.map(\.platform) == ["iOS", "macOS"])
        #expect(availability.last?.isBeta == true)
    }

    @Test("Metadata-only sources keep structure but drop prose")
    func metadataOnly() async throws {
        let detail = try await detail(permission: .metadataOnly)
        #expect(detail.entry.abstract == nil)
        #expect(detail.sections.isEmpty)
        #expect(detail.topics.first?.entries.first?.abstract == nil)
        #expect(detail.declaration != nil)
        #expect(detail.entry.webURL != nil)
    }

    @Test("Markdown code spans are removed from headings")
    func plainHeadings() {
        #expect(RenderNodeMapper.plainHeading("Replacing `@Sendable` with `sending`") == "Replacing @Sendable with sending")
    }

    @Test("Malformed JSON is reported as an invalid response")
    func malformed() async {
        await #expect(throws: DocumentationError.invalidResponse) {
            try await DocCParser.detail(from: Data("{".utf8), source: TestDocumentationSource())
        }
    }
}
