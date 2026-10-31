import Foundation

/// Permission is enforced here: for metadata-only sources, abstracts and prose are dropped
/// while titles, structure, availability and links are kept.
nonisolated struct RenderNodeMapper: Sendable {
    let source: any DocumentationSource

    private var allowsProse: Bool { source.permission.allowsProse }

    // MARK: Pages

    func detail(from node: RenderNodeDTO) -> DocumentationDetail {
        let references = node.references ?? [:]
        let frameworkName = node.metadata?.modules?.first?.name ?? source.defaultFrameworkName
        let entry = pageEntry(from: node, frameworkName: frameworkName)

        var declaration: Declaration?
        var sections: [DocumentationSection] = []
        for section in node.primaryContentSections ?? [] {
            switch section {
            case .declarations(let declarations):
                declaration = declaration ?? declarations.first.map(map)
            case .content(let blocks):
                if allowsProse { sections += self.sections(from: blocks, references: references, pageID: entry.id) }
            case .unknown:
                break
            }
        }

        return DocumentationDetail(
            entry: entry,
            permission: source.permission,
            declaration: declaration,
            sections: sections,
            topics: groups(from: node.topicSections, references: references, frameworkName: frameworkName),
            relationships: groups(from: node.relationshipsSections, references: references, frameworkName: frameworkName)
                + groups(from: node.seeAlsoSections, references: references, frameworkName: frameworkName),
            availability: (node.metadata?.platforms ?? []).compactMap(map),
            isDeprecated: Self.isDeprecated(node),
            deprecationNotice: deprecationNotice(for: node, references: references, pageID: entry.id),
            replacements: replacements(in: node.deprecationSummary, references: references, frameworkName: frameworkName)
        )
    }

    func pageEntry(from node: RenderNodeDTO, frameworkName: String?) -> DocumentationEntry {
        let id = documentationID(forReference: node.identifier.url)
            ?? DocumentationID(sourceID: source.id, path: node.identifier.url)
        return DocumentationEntry(
            id: id,
            title: node.metadata?.title ?? id.path,
            kind: DocCKindMapper.kind(kind: node.kind, role: node.metadata?.role, symbolKind: node.metadata?.symbolKind),
            frameworkName: frameworkName,
            abstract: allowsProse ? plainText(node.abstract) : nil,
            webURL: source.webURL(forPath: id.path),
            isDeprecated: Self.isDeprecated(node)
        )
    }

    /// An entry for a `topic` reference, or `nil` for other reference types.
    func entry(from reference: RenderReferenceDTO, frameworkName: String?, keywords: [String] = []) -> DocumentationEntry? {
        guard reference.type == nil || reference.type == "topic",
              let identifier = reference.identifier,
              let id = reference.url.map({ DocumentationID(sourceID: source.id, path: $0) })
                ?? documentationID(forReference: identifier),
              let title = reference.title
        else { return nil }
        return DocumentationEntry(
            id: id,
            title: title,
            kind: DocCKindMapper.kind(kind: reference.kind, role: reference.role, symbolKind: nil),
            frameworkName: frameworkName,
            abstract: allowsProse ? plainText(reference.abstract) : nil,
            webURL: source.webURL(forPath: id.path),
            keywords: keywords,
            isDeprecated: reference.deprecated ?? false
        )
    }

    func documentationID(forReference reference: String) -> DocumentationID? {
        DocumentationID(docCReference: reference, sourceID: source.id)
    }

    // MARK: Deprecation

    /// Deprecated when the page explains a deprecation, or when every listed platform deprecates it.
    /// (Deprecated on a single platform only is shown in the availability chips, not as a deprecated page.)
    static func isDeprecated(_ node: RenderNodeDTO) -> Bool {
        if let summary = node.deprecationSummary, !summary.isEmpty { return true }
        let platforms = node.metadata?.platforms ?? []
        return !platforms.isEmpty && platforms.allSatisfy { $0.deprecatedAt != nil }
    }

    /// The page's deprecation summary, or the platforms' short message when there's no summary.
    private func deprecationNotice(for node: RenderNodeDTO, references: [String: RenderReferenceDTO], pageID: DocumentationID) -> [ContentBlock] {
        guard Self.isDeprecated(node) else { return [] }
        if let summary = node.deprecationSummary, !summary.isEmpty {
            return summary.map { map($0, references: references, pageID: pageID) }
        }
        guard let message = node.metadata?.platforms?.lazy.compactMap(\.message).first else { return [] }
        return [.paragraph([.text(message.prefix(1).uppercased() + message.dropFirst() + ".")])]
    }

    private func replacements(in summary: [RenderBlockDTO]?, references: [String: RenderReferenceDTO], frameworkName: String?) -> [DocumentationEntry] {
        var seen = Set<DocumentationID>()
        return (summary ?? []).flatMap(Self.referenceIdentifiers).compactMap { identifier in
            guard let entry = references[identifier].flatMap({ entry(from: $0, frameworkName: frameworkName) }),
                  seen.insert(entry.id).inserted
            else { return nil }
            return entry
        }
    }

    private static func referenceIdentifiers(in block: RenderBlockDTO) -> [String] {
        switch block {
        case .paragraph(let inlines): inlines.flatMap(referenceIdentifiers)
        case .aside(_, _, let content): content.flatMap(referenceIdentifiers)
        case .unorderedList(let items), .orderedList(let items): items.flatMap { ($0.content ?? []).flatMap(referenceIdentifiers) }
        case .heading, .codeListing, .unknown: []
        }
    }

    private static func referenceIdentifiers(in inline: RenderInlineDTO) -> [String] {
        switch inline {
        case .reference(let identifier, _): [identifier]
        case .emphasis(let children), .strong(let children): children.flatMap(referenceIdentifiers)
        case .text, .codeVoice, .link, .unknown: []
        }
    }

    // MARK: Topics

    private func groups(from sections: [TopicSectionDTO]?, references: [String: RenderReferenceDTO], frameworkName: String?) -> [TopicGroup] {
        (sections ?? []).compactMap { section in
            let entries = (section.identifiers ?? []).compactMap { identifier in
                references[identifier].flatMap { entry(from: $0, frameworkName: frameworkName) }
            }
            guard !entries.isEmpty else { return nil }
            return TopicGroup(title: section.title ?? String(localized: .detailTopicsTitle), entries: entries)
        }
    }

    // MARK: Prose

    /// Splits content into sections at level-2 headings; content before the first heading becomes "Overview".
    private func sections(from blocks: [RenderBlockDTO], references: [String: RenderReferenceDTO], pageID: DocumentationID) -> [DocumentationSection] {
        var result: [DocumentationSection] = []
        var title = String(localized: .detailOverviewTitle)
        var current: [ContentBlock] = []

        func flush() {
            if !current.isEmpty { result.append(DocumentationSection(title: title, blocks: current)) }
            current = []
        }

        for block in blocks {
            if case .heading(let level, let text) = block, level <= 2 {
                flush()
                title = Self.plainHeading(text)
            } else {
                current.append(map(block, references: references, pageID: pageID))
            }
        }
        flush()
        return result
    }

    func map(_ block: RenderBlockDTO, references: [String: RenderReferenceDTO], pageID: DocumentationID) -> ContentBlock {
        switch block {
        case .paragraph(let inlines):
            return .paragraph(map(inlines, references: references))
        case .heading(let level, let text):
            return .heading(level: level, text: Self.plainHeading(text))
        case .codeListing(let syntax, let code):
            return .code(CodeSnippet(
                title: "",
                language: syntax ?? "swift",
                code: code.joined(separator: "\n"),
                origin: .documentation(pageID)
            ))
        case .aside(let style, let name, let content):
            return .aside(
                style: Self.asideStyle(style ?? name),
                title: name,
                content: content.map { map($0, references: references, pageID: pageID) }
            )
        case .unorderedList(let items), .orderedList(let items):
            let ordered = if case .orderedList = block { true } else { false }
            return .list(ordered: ordered, items: items.map { item in
                (item.content ?? []).map { map($0, references: references, pageID: pageID) }
            })
        case .unknown(let type):
            return .unsupported(kind: type)
        }
    }

    func map(_ inlines: [RenderInlineDTO], references: [String: RenderReferenceDTO]) -> [InlineElement] {
        inlines.compactMap { inline in
            switch inline {
            case .text(let text): .text(text)
            case .codeVoice(let code): .code(code)
            case .emphasis(let children): .emphasis(map(children, references: references))
            case .strong(let children): .strong(map(children, references: references))
            case .reference(let identifier, let overridingTitle):
                referenceElement(identifier: identifier, overridingTitle: overridingTitle, references: references)
            case .link(let destination, let title):
                URL(string: destination).map { .link($0, title: title ?? destination) }
            case .unknown: nil
            }
        }
    }

    private func referenceElement(identifier: String, overridingTitle: String?, references: [String: RenderReferenceDTO]) -> InlineElement {
        let reference = references[identifier]
        let title = overridingTitle ?? reference?.title ?? identifier
        // External links are stored as references with a URL that isn't a documentation path.
        if let urlString = reference?.url, urlString.hasPrefix("http"), let url = URL(string: urlString) {
            return .link(url, title: title)
        }
        if let id = reference?.url.map({ DocumentationID(sourceID: source.id, path: $0) }) ?? documentationID(forReference: identifier) {
            return .reference(id, title: title)
        }
        return .text(title)
    }

    private func plainText(_ inlines: [RenderInlineDTO]?) -> String? {
        guard let inlines else { return nil }
        let text = map(inlines, references: [:]).map(\.plainText).joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }

    // MARK: Declarations and availability

    private func map(_ declaration: DeclarationDTO) -> Declaration {
        Declaration(
            language: declaration.languages?.first ?? "swift",
            tokens: (declaration.tokens ?? []).map { token in
                Declaration.Token(
                    kind: Declaration.Token.Kind(rawValue: token.kind ?? "text") ?? .text,
                    text: token.text,
                    reference: token.identifier.flatMap(documentationID(forReference:))
                )
            }
        )
    }

    private func map(_ platform: RenderNodeDTO.Metadata.Platform) -> PlatformAvailability? {
        guard let name = platform.name else { return nil }
        return PlatformAvailability(
            platform: name,
            introducedAt: platform.introducedAt,
            deprecatedAt: platform.deprecatedAt,
            isBeta: platform.beta ?? false
        )
    }

    /// DocC heading text keeps inline Markdown code spans (`` `sending` parameters ``); show it as plain text.
    static func plainHeading(_ text: String) -> String {
        text.replacingOccurrences(of: "`", with: "")
    }

    private static func asideStyle(_ raw: String?) -> ContentBlock.AsideStyle {
        switch raw?.lowercased() {
        case "tip": .tip
        case "important": .important
        case "warning": .warning
        case "experiment": .experiment
        case "deprecated": .deprecated
        default: .note
        }
    }
}
