import Foundation
import Testing
@testable import atlas

@Suite("EvolutionMapper")
struct EvolutionMapperTests {
    let source = SwiftEvolutionSource()

    private func dashboard() throws -> EvolutionDashboardDTO {
        try JSONDecoder().decode(EvolutionDashboardDTO.self, from: EvolutionFixtures.dashboard)
    }

    @Test("Proposals become searchable entries with number, plain title, status and feature flag")
    func entries() throws {
        let entries = EvolutionMapper(source: source).proposalEntries(from: try dashboard())
        let se0461 = try #require(entries.first)
        #expect(se0461.title == "SE-0461: Run nonisolated async functions on the caller's actor by default")
        #expect(se0461.id.path == "/proposals/0461-async-function-isolation")
        #expect(se0461.keywords == ["SE-0461", "Implemented (Swift 6.2)", "NonisolatedNonsendingByDefault"])
        #expect(se0461.abstract?.hasPrefix("Implemented (Swift 6.2) · ") == true)
        #expect(se0461.webURL?.absoluteString == "https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md")
    }

    @Test("Page locations keep case-sensitive file names and SHAs")
    func locations() throws {
        let locations = EvolutionMapper(source: source).pageLocations(from: try dashboard())
        let id = DocumentationID(sourceID: source.id, path: "/proposals/0467-mutablespan")
        #expect(locations[id]?.dataURL.lastPathComponent == "0467-MutableSpan.md")
        #expect(locations[id]?.version == "sha-0467")
    }

    @Test("The overview groups proposals by status, newest Swift version first (numerically)")
    func overview() throws {
        let overview = EvolutionMapper(source: source).overview(from: try dashboard())
        #expect(overview.topics.map(\.title) == [
            "In Review", "Implemented in Swift 6.10", "Implemented in Swift 6.9", "Implemented in Swift 6.2",
        ])
    }

    @Test("A Markdown proposal becomes sections; the table of contents is dropped; links resolve to proposals")
    func proposal() throws {
        let id = DocumentationID(sourceID: source.id, path: "/proposals/0461-async-function-isolation")
        let detail = EvolutionMapper(source: source).proposal(fromMarkdown: EvolutionFixtures.proposal, id: id, metadata: nil)

        #expect(detail.entry.title == "Run nonisolated async functions on the caller's actor by default")
        #expect(detail.sections.map(\.title) == ["Overview", "Detailed design"])
        #expect(detail.codeExamples.first?.origin == .documentation(id))

        guard case .list(_, let items) = detail.sections.first?.blocks.first,
              case .paragraph(let inlines) = items.last?.first else {
            Issue.record("Expected the header list"); return
        }
        let previous = DocumentationID(sourceID: source.id, path: "/proposals/0338-clarify-execution-non-actor-async")
        #expect(inlines.contains(.reference(previous, title: "SE-0338")))
    }

    @Test("Known metadata (number and status) is kept when a proposal is opened")
    func keepsMetadata() throws {
        let metadata = try #require(EvolutionMapper(source: source).proposalEntries(from: try dashboard()).first)
        let detail = EvolutionMapper(source: source).proposal(fromMarkdown: EvolutionFixtures.proposal, id: metadata.id, metadata: metadata)
        #expect(detail.entry.title.hasPrefix("SE-0461: "))
    }
}
