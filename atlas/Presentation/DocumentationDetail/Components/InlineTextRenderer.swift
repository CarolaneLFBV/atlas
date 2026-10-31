import SwiftUI

/// References to other pages are links with an in-app URL (`DocumentationReferenceURL`): the
/// detail screen opens them in place, like a row of Topics.
enum InlineTextRenderer {
    static func attributedString(from elements: [InlineElement]) -> AttributedString {
        var result = AttributedString()
        var previousText = ""
        for element in elements {
            // A code span right after a word ("non-`Sendable`") gets no leading padding.
            let piece = render(element, padsLeading: previousText.last.map(\.isWhitespace) ?? true)
            result += piece
            previousText = String(piece.characters)
        }
        return result
    }

    private static func render(_ element: InlineElement, padsLeading: Bool = true) -> AttributedString {
        switch element {
        case .text(let text):
            return AttributedString(text)
        case .code(let code):
            // Code spans sit on the fill color, like the handoff's inline code chips. The padding is a
            // narrow no-break space, so a line can't break between the padding and the code.
            var piece = AttributedString((padsLeading ? "\u{202F}" : "") + code + "\u{202F}")
            piece.font = .atlasInlineCode
            piece.backgroundColor = AtlasColor.fill
            return piece
        case .emphasis(let children):
            var piece = attributedString(from: children)
            piece.inlinePresentationIntent = .emphasized
            return piece
        case .strong(let children):
            var piece = attributedString(from: children)
            piece.inlinePresentationIntent = .stronglyEmphasized
            return piece
        case .reference(let id, let title):
            var piece = AttributedString(title)
            piece.link = DocumentationReferenceURL.url(for: id, title: title)
            // Symbol names read as code; page titles ("SE-0338: Clarify the Execution…") as prose.
            if !title.contains(" ") { piece.font = .atlasInlineCode }
            piece.foregroundColor = AtlasColor.accent
            return piece
        case .link(let url, let title):
            var piece = AttributedString(title)
            piece.link = url
            return piece
        }
    }
}
