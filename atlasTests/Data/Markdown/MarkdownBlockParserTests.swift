import Foundation
import Testing
@testable import atlas

@Suite("MarkdownBlockParser")
struct MarkdownBlockParserTests {
    let parser = MarkdownBlockParser()

    @Test("The first level-1 heading is the title; other headings drop code-span backticks")
    func headings() {
        let (title, blocks) = parser.parse("# Title\n\n## Second `Level`\n\n### Third")
        #expect(title == "Title")
        #expect(blocks == [.heading(level: 2, text: "Second Level"), .heading(level: 3, text: "Third")])
    }

    @Test("Fenced code keeps its language and exact content")
    func fencedCode() {
        let (_, blocks) = parser.parse("```swift\nlet a = 1\n\n  indented\n```")
        guard case .code(let snippet) = blocks.first else { Issue.record("Expected code"); return }
        #expect(snippet.language == "swift")
        #expect(snippet.code == "let a = 1\n\n  indented")
    }

    @Test("Lists, ordered or not, with continuation lines")
    func lists() {
        let (_, blocks) = parser.parse("* One\n  continued\n* Two\n\n1. First\n2. Second")
        #expect(blocks.count == 2)
        guard case .list(false, let items) = blocks.first else { Issue.record("Expected a bullet list"); return }
        #expect(items == [[.paragraph([.text("One continued")])], [.paragraph([.text("Two")])]])
        guard case .list(true, let ordered) = blocks.last else { Issue.record("Expected an ordered list"); return }
        #expect(ordered.count == 2)
    }

    @Test("Block quotes become asides; GitHub callouts set the style")
    func quotes() {
        let (_, blocks) = parser.parse("> [!WARNING]\n> Careful here.")
        #expect(blocks == [.aside(style: .warning, title: "Warning", content: [.paragraph([.text("Careful here.")])])])
    }

    @Test("Tables are kept verbatim in a monospaced block")
    func tables() {
        let (_, blocks) = parser.parse("| A | B |\n|---|---|\n| 1 | 2 |")
        guard case .code(let snippet) = blocks.first else { Issue.record("Expected a table block"); return }
        #expect(snippet.language == "text")
        #expect(snippet.code.split(separator: "\n").count == 3)
    }

    @Test("Paragraph lines are joined and stop at the next block")
    func paragraphs() {
        let (_, blocks) = parser.parse("One\ntwo\n## Next")
        #expect(blocks.first == .paragraph([.text("One two")]))
        #expect(blocks.count == 2)
    }

    @Test("Link definitions are removed from the text and resolve references anywhere in the document")
    func linkDefinitions() {
        let markdown = """
        Read [the proposal][SE-0461].

        [SE-0461]: https://example.com/0461.md
        """
        let (_, blocks) = MarkdownBlockParser().parse(markdown)
        #expect(blocks.count == 1)
        guard case .paragraph(let elements) = blocks.first else {
            Issue.record("Expected a paragraph, got \(blocks)")
            return
        }
        #expect(elements.contains { if case .link(_, let title) = $0 { title == "the proposal" } else { false } })
    }
}
