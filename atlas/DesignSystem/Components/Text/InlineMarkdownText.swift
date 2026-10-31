import SwiftUI

struct InlineMarkdownText: View {
    let markdown: String

    init(_ markdown: String) {
        self.markdown = markdown
    }

    var body: some View {
        Text(Self.attributed(markdown))
    }

    static func attributed(_ markdown: String) -> AttributedString {
        // Reference-style links have no definitions in a lone abstract: keep their text.
        let text = markdown.replacing(/\[([^\]]+)\]\[[^\]]*\]/) { String($0.1) }
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace,
            failurePolicy: .returnPartiallyParsedIfPossible
        )
        // Unparseable Markdown is shown as plain text rather than dropped.
        // `Text` renders code spans in a monospaced face on its own.
        return (try? AttributedString(markdown: text, options: options)) ?? AttributedString(text)
    }
}

#if DEBUG
#Preview {
    InlineMarkdownText("Adds `MutableSpan`, see [SE-0273](https://example.com) and [SE-0338][SE-0338].")
        .padding()
}
#endif
