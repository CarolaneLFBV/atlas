import Foundation

nonisolated struct CatalogueMapper: Sendable {
    let source: any DocumentationSource

    private var pageMapper: RenderNodeMapper { RenderNodeMapper(source: source) }

    func categories(from technologies: TechnologiesDTO) -> [DocumentationCatalogue.Category] {
        let references = technologies.references ?? [:]
        var seen = Set<DocumentationID>()

        let groups = (technologies.sections ?? []).flatMap { $0.groups ?? [] }
        return groups.compactMap { group in
            guard let name = group.name else { return nil }
            let frameworks: [DocumentationFramework] = (group.technologies ?? []).compactMap { technology in
                guard let identifier = technology.destination?.identifier,
                      let title = technology.title,
                      let id = pageMapper.documentationID(forReference: identifier),
                      seen.insert(id).inserted
                else { return nil }
                let reference = references[identifier]
                return DocumentationFramework(
                    id: reference?.url.map { DocumentationID(sourceID: source.id, path: $0) } ?? id,
                    title: title,
                    abstract: reference.flatMap { pageMapper.entry(from: $0, frameworkName: title)?.abstract },
                    category: name,
                    tags: technology.tags ?? [],
                    webURL: source.webURL(forPath: reference?.url ?? id.path)
                )
            }
            return frameworks.isEmpty ? nil : DocumentationCatalogue.Category(name: name, frameworks: frameworks)
        }
    }

    func categories(fromRootPage node: RenderNodeDTO, category: String) -> [DocumentationCatalogue.Category] {
        let entry = pageMapper.pageEntry(from: node, frameworkName: source.defaultFrameworkName)
        let framework = DocumentationFramework(
            id: entry.id,
            title: entry.title,
            abstract: entry.abstract,
            category: category,
            tags: [],
            webURL: entry.webURL
        )
        return [DocumentationCatalogue.Category(name: category, frameworks: [framework])]
    }

    /// Parent titles and the group marker preceding a page (e.g. "Language Guide") become its keywords.
    /// Group markers are siblings of the pages they introduce, not parents, and aren't pages themselves.
    func searchEntries(from index: NavigatorIndexDTO, frameworkName: String? = nil) -> [DocumentationEntry] {
        let frameworkName = frameworkName ?? source.defaultFrameworkName
        var entries: [DocumentationEntry] = []
        func visit(_ nodes: [NavigatorIndexDTO.Node], parents: [String]) {
            var currentGroup: String?
            for node in nodes {
                if node.type == "groupMarker" {
                    currentGroup = node.title
                    continue
                }
                let context = parents + [currentGroup].compactMap { $0 }
                if let path = node.path, let title = node.title, !Self.isImplementationsGroup(node) {
                    let id = DocumentationID(sourceID: source.id, path: path)
                    entries.append(DocumentationEntry(
                        id: id,
                        title: title,
                        kind: DocCKindMapper.kind(navigatorType: node.type),
                        frameworkName: frameworkName,
                        webURL: source.webURL(forPath: id.path),
                        keywords: context,
                        isDeprecated: node.deprecated ?? false
                    ))
                }
                let childContext = Self.isImplementationsGroup(node) ? context : (node.title.map { context + [$0] } ?? context)
                visit(node.children ?? [], parents: childContext)
            }
        }
        visit((index.interfaceLanguages ?? [:])["swift"] ?? [], parents: [])
        return entries
    }

    /// "AsyncSequence Implementations"-style collections group default implementations under every
    /// conforming type, flooding results with identical titles. Their members are still indexed.
    private static func isImplementationsGroup(_ node: NavigatorIndexDTO.Node) -> Bool {
        node.type == "collection" && (node.title?.hasSuffix(" Implementations") ?? false)
    }
}
