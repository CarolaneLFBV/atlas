import Foundation

nonisolated struct EvolutionMapper: Sendable {
    let source: any DocumentationSource

    private static let rawProposalsBase = URL(string: "https://raw.githubusercontent.com/swiftlang/swift-evolution/main/proposals")
    private static let webProposalsBase = URL(string: "https://github.com/swiftlang/swift-evolution/blob/main/proposals/")

    // MARK: Dashboard

    func proposalEntries(from dashboard: EvolutionDashboardDTO) -> [DocumentationEntry] {
        (dashboard.proposals ?? []).compactMap(entry)
    }

    func pageLocations(from dashboard: EvolutionDashboardDTO) -> [DocumentationID: PageLocation] {
        var locations: [DocumentationID: PageLocation] = [:]
        for proposal in dashboard.proposals ?? [] {
            guard let link = proposal.link, let id = Self.proposalID(forFile: link, source: source.id),
                  let url = Self.rawProposalsBase?.appending(path: link)
            else { continue }
            locations[id] = PageLocation(dataURL: url, version: proposal.sha)
        }
        return locations
    }

    func catalogueCategories(from dashboard: EvolutionDashboardDTO, category: String) -> [DocumentationCatalogue.Category] {
        let root = rootEntry(count: dashboard.proposals?.count ?? 0)
        let framework = DocumentationFramework(
            id: root.id, title: root.title, abstract: root.abstract,
            category: category, tags: ["Proposals"], webURL: root.webURL
        )
        return [DocumentationCatalogue.Category(name: category, frameworks: [framework])]
    }

    func overview(from dashboard: EvolutionDashboardDTO) -> DocumentationDetail {
        let proposals = (dashboard.proposals ?? []).compactMap { proposal in entry(for: proposal).map { (proposal, $0) } }
        let grouped = Dictionary(grouping: proposals) { Self.statusGroup(for: $0.0) }
        let topics = grouped
            .sorted { lhs, rhs in
                if lhs.key.order != rhs.key.order { return lhs.key.order < rhs.key.order }
                // Newest Swift version first, comparing numerically ("5.10" after "5.9").
                return lhs.key.title.compare(rhs.key.title, options: .numeric) == .orderedDescending
            }
            .map { group, items in
                TopicGroup(title: group.title, entries: items.map(\.1).sorted { $0.title > $1.title })
            }
        return DocumentationDetail(
            entry: rootEntry(count: proposals.count),
            permission: source.permission,
            declaration: nil, sections: [], topics: topics, relationships: [], availability: [], isDeprecated: false
        )
    }

    // MARK: Proposals

    func proposal(fromMarkdown markdown: String, id: DocumentationID, metadata: DocumentationEntry?) -> DocumentationDetail {
        var parser = MarkdownBlockParser()
        parser.codeOrigin = .documentation(id)
        parser.inline.baseURL = Self.webProposalsBase
        let sourceID = source.id
        parser.inline.resolveReference = { destination in
            guard !destination.contains("://"), destination.hasSuffix(".md") else { return nil }
            return Self.proposalID(forFile: (destination as NSString).lastPathComponent, source: sourceID)
        }
        let (title, blocks) = parser.parse(markdown)

        let entry = metadata ?? DocumentationEntry(
            id: id,
            title: title ?? id.path,
            kind: .article,
            frameworkName: source.defaultFrameworkName,
            webURL: source.webURL(forPath: id.path)
        )
        return DocumentationDetail(
            entry: entry,
            permission: source.permission,
            declaration: nil,
            sections: Self.sections(from: blocks),
            topics: [], relationships: [], availability: [], isDeprecated: false
        )
    }

    // MARK: Helpers

    private func entry(for proposal: EvolutionDashboardDTO.Proposal) -> DocumentationEntry? {
        guard let link = proposal.link, let number = proposal.id, let title = proposal.title,
              let id = Self.proposalID(forFile: link, source: source.id)
        else { return nil }
        let status = Self.statusLabel(for: proposal)
        return DocumentationEntry(
            id: id,
            // Titles keep Markdown code spans (`async`); show them as plain text, like headings.
            title: "\(number): \(title.replacingOccurrences(of: "`", with: "").trimmingCharacters(in: .whitespaces))",
            kind: .article,
            frameworkName: source.defaultFrameworkName,
            abstract: proposal.summary.map { "\(status) · \($0.trimmingCharacters(in: .whitespacesAndNewlines))" } ?? status,
            webURL: source.webURL(forPath: id.path),
            keywords: [number, status, proposal.upcomingFeatureFlag?.flag].compactMap { $0 }
        )
    }

    private func rootEntry(count: Int) -> DocumentationEntry {
        let id = DocumentationID(sourceID: source.id, path: SwiftEvolutionSource.rootPath)
        return DocumentationEntry(
            id: id,
            title: source.displayName,
            kind: .collection,
            frameworkName: source.defaultFrameworkName,
            abstract: String(localized: .evolutionRootAbstract(count: count)),
            webURL: source.webURL(forPath: id.path)
        )
    }

    /// `0461-async-function-isolation.md` → `/proposals/0461-async-function-isolation`.
    static func proposalID(forFile file: String, source: DocumentationSourceID) -> DocumentationID? {
        guard file.hasSuffix(".md"), let number = file.first, number.isNumber else { return nil }
        return DocumentationID(sourceID: source, path: "\(SwiftEvolutionSource.rootPath)/\(file.dropLast(3))")
    }

    /// Splits blocks into sections at level-2 headings, like DocC pages, dropping the table of contents.
    static func sections(from blocks: [ContentBlock]) -> [DocumentationSection] {
        var sections: [DocumentationSection] = []
        var title = String(localized: .detailOverviewTitle)
        var current: [ContentBlock] = []
        func flush() {
            if !current.isEmpty, !["table of contents", "contents"].contains(title.lowercased()) {
                sections.append(DocumentationSection(title: title, blocks: current))
            }
            current = []
        }
        for block in blocks {
            if case .heading(let level, let text) = block, level == 2 {
                flush()
                title = text
            } else {
                current.append(block)
            }
        }
        flush()
        return sections
    }

    static func statusLabel(for proposal: EvolutionDashboardDTO.Proposal) -> String {
        let version = proposal.status?.version
        switch proposal.status?.state {
        case "implemented": return version.map { "Implemented (Swift \($0))" } ?? "Implemented"
        case "accepted": return "Accepted"
        case "activeReview": return "In Review"
        case "previewing": return "Previewing"
        case "returnedForRevision": return "Returned for Revision"
        case "rejected": return "Rejected"
        case "withdrawn": return "Withdrawn"
        default: return proposal.status?.state ?? "Unknown"
        }
    }

    private struct StatusGroup: Hashable {
        let title: String
        let order: Int
    }

    private static func statusGroup(for proposal: EvolutionDashboardDTO.Proposal) -> StatusGroup {
        switch proposal.status?.state {
        case "activeReview": StatusGroup(title: "In Review", order: 0)
        case "accepted", "previewing": StatusGroup(title: "Accepted", order: 1)
        case "implemented":
            StatusGroup(title: proposal.status?.version.map { "Implemented in Swift \($0)" } ?? "Implemented", order: 2)
        case "returnedForRevision": StatusGroup(title: "Returned for Revision", order: 3)
        case "rejected": StatusGroup(title: "Rejected", order: 4)
        case "withdrawn": StatusGroup(title: "Withdrawn", order: 5)
        default: StatusGroup(title: "Other", order: 6)
        }
    }
}
