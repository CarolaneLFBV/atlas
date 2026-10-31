import Foundation
import Testing
@testable import atlas

@Suite("MarkdownInlineParser")
struct MarkdownInlineParserTests {
    @Test("Code spans, emphasis and strong text are recognized")
    func styles() {
        let elements = MarkdownInlineParser().parse("Use `@concurrent` *now* and **always**")
        #expect(elements == [
            .text("Use "), .code("@concurrent"), .text(" "), .emphasis([.text("now")]),
            .text(" and "), .strong([.text("always")]),
        ])
    }

    @Test("Links resolve to pages, absolute URLs or plain text for anchors")
    func links() {
        var parser = MarkdownInlineParser()
        parser.baseURL = URL(string: "https://example.com/docs/")
        let page = DocumentationID(sourceID: .apple, path: "/page")
        parser.resolveReference = { $0 == "page.md" ? page : nil }

        let elements = parser.parse("[A](page.md) [B](https://swift.org) [C](#anchor) [D](other.html)")

        #expect(elements.contains(.reference(page, title: "A")))
        #expect(elements.contains(.link(URL(string: "https://swift.org")!, title: "B")))
        #expect(elements.contains(.text("C")))
        #expect(elements.contains(.link(URL(string: "https://example.com/docs/other.html")!, title: "D")))
    }

    @Test("Reference-style links resolve from the document's definitions, or fall back to their text")
    func referenceLinks() {
        var parser = MarkdownInlineParser()
        parser.linkDefinitions = ["se-0338": "https://example.com/0338.md"]
        #expect(parser.resolvingReferenceLinks(in: "See [SE-0338: Clarify][SE-0338].") == "See [SE-0338: Clarify](https://example.com/0338.md).")
        #expect(parser.resolvingReferenceLinks(in: "See [Unknown][missing] and [SE-0338][].") == "See Unknown and [SE-0338](https://example.com/0338.md).")
    }
}
