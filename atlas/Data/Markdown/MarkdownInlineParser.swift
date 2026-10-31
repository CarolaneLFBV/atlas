import Foundation

nonisolated struct MarkdownInlineParser: Sendable {
    /// Maps a link destination to a documentation page, or `nil` to keep it as a plain link.
    var resolveReference: @Sendable (String) -> DocumentationID? = { _ in nil }
    /// Base for relative links that aren't documentation pages.
    var baseURL: URL?
    /// Reference-style link definitions of the document, by lowercased label.
    var linkDefinitions: [String: String] = [:]

    func parse(_ markdown: String) -> [InlineElement] {
        let markdown = resolvingReferenceLinks(in: markdown)
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace,
            failurePolicy: .returnPartiallyParsedIfPossible
        )
        // Unparseable Markdown is shown as plain text rather than dropped: no content is lost.
        guard let attributed = try? AttributedString(markdown: markdown, options: options) else {
            return [.text(markdown)]
        }
        return attributed.runs.compactMap { run in
            let text = String(attributed[run.range].characters)
            guard !text.isEmpty else { return nil }
            return element(for: text, intent: run.inlinePresentationIntent, link: run.link)
        }
    }

    /// Rewrites "[text][label]" and "[text][]" as inline links when the label is defined, and as
    /// plain text otherwise, so brackets never show on screen.
    func resolvingReferenceLinks(in markdown: String) -> String {
        markdown.replacing(/\[([^\]]+)\]\[([^\]]*)\]/) { match in
            let text = String(match.1)
            let label = (match.2.isEmpty ? text : String(match.2)).lowercased()
            guard let destination = linkDefinitions[label] else { return text }
            return "[\(text)](\(destination))"
        }
    }

    private func element(for text: String, intent: InlinePresentationIntent?, link: URL?) -> InlineElement {
        if let link {
            let destination = link.absoluteString
            if let id = resolveReference(destination) { return .reference(id, title: text) }
            if destination.hasPrefix("#") { return .text(text) }
            let resolved = link.scheme == nil ? URL(string: destination, relativeTo: baseURL)?.absoluteURL : link
            return resolved.map { .link($0, title: text) } ?? .text(text)
        }
        guard let intent else { return .text(text) }
        if intent.contains(.code) { return .code(text) }
        if intent.contains(.stronglyEmphasized) { return .strong([.text(text)]) }
        if intent.contains(.emphasized) { return .emphasis([.text(text)]) }
        return .text(text)
    }
}
