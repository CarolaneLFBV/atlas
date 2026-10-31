import Foundation

/// Level-2 headings start the page's sections (done by the mapper); deeper headings inside a
/// section start their own passage, so results can name the most precise heading.
nonisolated enum FullTextExtractor {
    nonisolated struct Passage: Hashable, Sendable {
        let title: String
        let text: String
    }

    static func passages(from detail: DocumentationDetail) -> [Passage] {
        var passages: [Passage] = []
        for section in detail.sections {
            var title = section.title
            var lines: [String] = []

            func flush() {
                let text = lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                if !text.isEmpty { passages.append(Passage(title: title, text: text)) }
                lines.removeAll()
            }

            for block in section.blocks {
                if case .heading(_, let text) = block {
                    flush()
                    title = text
                } else {
                    lines.append(contentsOf: plainText(of: block))
                }
            }
            flush()
        }
        return passages
    }

    private static func plainText(of block: ContentBlock) -> [String] {
        switch block {
        case .heading(_, let text): [text]
        case .paragraph(let inlines): [inlines.map(\.plainText).joined()]
        case .code(let snippet): [snippet.code]
        case .list(_, let items): items.flatMap { $0.flatMap(plainText(of:)) }
        case .aside(_, let title, let content): [title].compactMap { $0 } + content.flatMap(plainText(of:))
        case .unsupported: []
        }
    }
}
