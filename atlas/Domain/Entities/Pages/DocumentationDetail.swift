import Foundation

nonisolated struct DocumentationDetail: Identifiable, Hashable, Codable, Sendable {
    var id: DocumentationID { entry.id }

    let entry: DocumentationEntry
    let permission: RenderingPermission
    let declaration: Declaration?
    let sections: [DocumentationSection]
    let topics: [TopicGroup]
    let relationships: [TopicGroup]
    let availability: [PlatformAvailability]
    let isDeprecated: Bool
    var deprecationNotice: [ContentBlock] = []
    var replacements: [DocumentationEntry] = []

    var codeExamples: [CodeSnippet] {
        sections.flatMap { Self.snippets(in: $0.blocks) }
    }

    private static func snippets(in blocks: [ContentBlock]) -> [CodeSnippet] {
        blocks.flatMap { block -> [CodeSnippet] in
            switch block {
            case .code(let snippet): [snippet]
            case .list(_, let items): items.flatMap { snippets(in: $0) }
            case .aside(_, _, let content): snippets(in: content)
            case .heading, .paragraph, .unsupported: []
            }
        }
    }
}
