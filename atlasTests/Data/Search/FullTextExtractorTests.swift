import Foundation
import Testing
@testable import atlas

@Suite("FullTextExtractor")
struct FullTextExtractorTests {
    private func detail(sections: [DocumentationSection]) -> DocumentationDetail {
        DocumentationDetail(
            entry: Fixture.entry("Page"), permission: .metadataOnly, declaration: nil, sections: sections,
            topics: [], relationships: [], availability: [], isDeprecated: false
        )
    }

    @Test("Deeper headings start their own passage, named after the heading")
    func splitsAtHeadings() {
        let passages = FullTextExtractor.passages(from: detail(sections: [
            DocumentationSection(title: "Overview", blocks: [
                .paragraph([.text("Intro text.")]),
                .heading(level: 3, text: "Details"),
                .paragraph([.text("Use "), .code("@concurrent"), .text(" here.")]),
            ]),
        ]))
        #expect(passages == [
            .init(title: "Overview", text: "Intro text."),
            .init(title: "Details", text: "Use @concurrent here."),
        ])
    }

    @Test("Code, lists and asides are included; empty passages are skipped")
    func includesAllProse() {
        let passages = FullTextExtractor.passages(from: detail(sections: [
            DocumentationSection(title: "Usage", blocks: [
                .heading(level: 3, text: "Empty"),
                .heading(level: 3, text: "Full"),
                .code(CodeSnippet(title: "", language: "swift", code: "let x = 1", origin: .userAuthored)),
                .list(ordered: false, items: [[.paragraph([.text("Item")])]]),
                .aside(style: .note, title: "Note", content: [.paragraph([.text("Careful")])]),
            ]),
        ]))
        #expect(passages.map(\.title) == ["Full"])
        #expect(passages.first?.text == "let x = 1\nItem\nNote\nCareful")
    }
}
