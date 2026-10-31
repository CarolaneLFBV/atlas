import Foundation

/// It is deliberately forgiving: anything unrecognized becomes paragraph text, so nothing is lost.
/// Code is kept verbatim and never executed.
nonisolated struct MarkdownBlockParser: Sendable {
    var inline = MarkdownInlineParser()
    var codeOrigin: CodeSnippet.Origin = .userAuthored

    /// The first level-1 heading (the document title) and the remaining blocks.
    func parse(_ markdown: String) -> (title: String?, blocks: [ContentBlock]) {
        let allLines = markdown.replacingOccurrences(of: "\r\n", with: "\n").components(separatedBy: "\n")
        // Reference-style links ("[SE-0338][SE-0338]") are defined anywhere in the document, usually at
        // the end; collect the definitions first so every paragraph can resolve them.
        let (definitions, contentLines) = Self.extractLinkDefinitions(allLines)
        var parser = self
        parser.inline.linkDefinitions = definitions
        return parser.parseBlocks(contentLines[...])
    }

    private func parseBlocks(_ remaining: ArraySlice<String>) -> (title: String?, blocks: [ContentBlock]) {
        var lines = remaining
        var title: String?
        var blocks: [ContentBlock] = []

        while let line = lines.first {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || Self.isThematicBreak(trimmed) {
                lines.removeFirst()
            } else if let fence = Self.fence(trimmed) {
                blocks.append(parseCode(&lines, fence: fence))
            } else if let (level, text) = Self.heading(trimmed) {
                lines.removeFirst()
                if level == 1, title == nil { title = text } else { blocks.append(.heading(level: level, text: text)) }
            } else if trimmed.hasPrefix(">") {
                blocks.append(parseQuote(&lines))
            } else if trimmed.hasPrefix("|") {
                blocks.append(parseTable(&lines))
            } else if Self.listMarker(line) != nil {
                blocks.append(parseList(&lines))
            } else {
                blocks.append(parseParagraph(&lines))
            }
        }
        return (title, blocks)
    }

    // MARK: Blocks

    private func parseCode(_ lines: inout ArraySlice<String>, fence: (marker: String, language: String)) -> ContentBlock {
        lines.removeFirst()
        var code: [String] = []
        while let line = lines.popFirst() {
            if line.trimmingCharacters(in: .whitespaces).hasPrefix(fence.marker) { break }
            code.append(line)
        }
        return .code(CodeSnippet(
            title: "", language: fence.language.isEmpty ? "swift" : fence.language,
            code: code.joined(separator: "\n"), origin: codeOrigin
        ))
    }

    private func parseQuote(_ lines: inout ArraySlice<String>) -> ContentBlock {
        var inner: [String] = []
        while let line = lines.first, line.trimmingCharacters(in: .whitespaces).hasPrefix(">") {
            lines.removeFirst()
            var content = line.trimmingCharacters(in: .whitespaces).dropFirst()
            if content.first == " " { content = content.dropFirst() }
            inner.append(String(content))
        }
        var style = ContentBlock.AsideStyle.note
        var title: String?
        if let first = inner.first, let callout = Self.callout(first) {
            style = callout.style
            title = callout.title
            inner.removeFirst()
        }
        return .aside(style: style, title: title, content: parse(inner.joined(separator: "\n")).blocks)
    }

    /// Tables are shown verbatim in a monospaced block: readable, and no information is lost.
    private func parseTable(_ lines: inout ArraySlice<String>) -> ContentBlock {
        var rows: [String] = []
        while let line = lines.first, line.trimmingCharacters(in: .whitespaces).hasPrefix("|") {
            rows.append(lines.removeFirst())
        }
        return .code(CodeSnippet(title: "Table", language: "text", code: rows.joined(separator: "\n"), origin: codeOrigin))
    }

    private func parseList(_ lines: inout ArraySlice<String>) -> ContentBlock {
        let ordered = Self.listMarker(lines.first ?? "")?.ordered ?? false
        var items: [[String]] = []
        while let line = lines.first {
            if let marker = Self.listMarker(line) {
                // A different kind of marker (bullets vs. numbers) starts a new list.
                guard marker.ordered == ordered else { break }
                lines.removeFirst()
                items.append([String(line.dropFirst(marker.length))])
            } else if line.trimmingCharacters(in: .whitespaces).isEmpty {
                // A blank line ends the list unless the next line continues it.
                let next = lines.dropFirst().first ?? ""
                guard Self.listMarker(next)?.ordered == ordered || next.hasPrefix("  ") else { break }
                lines.removeFirst()
            } else if line.hasPrefix("  ") || line.hasPrefix("\t"), !items.isEmpty {
                lines.removeFirst()
                items[items.count - 1].append(line.trimmingCharacters(in: .whitespaces))
            } else {
                break
            }
        }
        return .list(ordered: ordered, items: items.map { [ .paragraph(inline.parse($0.joined(separator: " "))) ] })
    }

    private func parseParagraph(_ lines: inout ArraySlice<String>) -> ContentBlock {
        var text: [String] = []
        while let line = lines.first {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || Self.fence(trimmed) != nil || Self.heading(trimmed) != nil
                || trimmed.hasPrefix(">") || trimmed.hasPrefix("|") || (Self.listMarker(line) != nil && !text.isEmpty) {
                break
            }
            text.append(trimmed)
            lines.removeFirst()
        }
        return .paragraph(inline.parse(text.joined(separator: " ")))
    }

    // MARK: Line classification

    /// Splits "[label]: destination" lines (outside code fences) from the content lines.
    static func extractLinkDefinitions(_ lines: [String]) -> (definitions: [String: String], content: [String]) {
        var definitions: [String: String] = [:]
        var content: [String] = []
        var inFence = false
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if fence(trimmed) != nil { inFence.toggle() }
            if !inFence, let match = trimmed.wholeMatch(of: /\[([^\]]+)\]:\s*<?(\S+?)>?(?:\s+.*)?/) {
                definitions[String(match.1).lowercased()] = String(match.2)
            } else {
                content.append(line)
            }
        }
        return (definitions, content)
    }

    static func heading(_ line: String) -> (level: Int, text: String)? {
        let hashes = line.prefix { $0 == "#" }
        guard (1...6).contains(hashes.count), line.dropFirst(hashes.count).first == " " else { return nil }
        let text = line.dropFirst(hashes.count).trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "`", with: "")
        return (hashes.count, text)
    }

    static func fence(_ line: String) -> (marker: String, language: String)? {
        for marker in ["```", "~~~"] where line.hasPrefix(marker) {
            return (marker, String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces))
        }
        return nil
    }

    /// The list marker at the start of `line` (`* `, `- `, `+ `, `1. `), with its length including indentation.
    static func listMarker(_ line: String) -> (ordered: Bool, length: Int)? {
        let indentation = line.prefix { $0 == " " }.count
        let rest = line.dropFirst(indentation)
        if let first = rest.first, "*-+".contains(first), rest.dropFirst().first == " " {
            return (false, indentation + 2)
        }
        let digits = rest.prefix { $0.isNumber }
        if !digits.isEmpty, digits.count <= 3, rest.dropFirst(digits.count).hasPrefix(". ") {
            return (true, indentation + digits.count + 2)
        }
        return nil
    }

    static func isThematicBreak(_ line: String) -> Bool {
        let characters = line.filter { !$0.isWhitespace }
        return characters.count >= 3 && Set(characters).count == 1 && "-*_".contains(characters.first ?? " ")
    }

    private static func callout(_ line: String) -> (style: ContentBlock.AsideStyle, title: String)? {
        switch line.trimmingCharacters(in: .whitespaces).uppercased() {
        case "[!NOTE]": (.note, "Note")
        case "[!TIP]": (.tip, "Tip")
        case "[!IMPORTANT]": (.important, "Important")
        case "[!WARNING]", "[!CAUTION]": (.warning, "Warning")
        default: nil
        }
    }
}
