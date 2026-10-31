import Foundation

nonisolated struct DocumentationFramework: Identifiable, Hashable, Codable, Sendable {
    let id: DocumentationID
    let title: String
    /// `nil` when the source does not permit displaying prose.
    let abstract: String?
    let category: String
    let tags: [String]
    let webURL: URL?

    var entry: DocumentationEntry {
        DocumentationEntry(
            id: id,
            title: title,
            kind: .framework,
            frameworkName: title,
            abstract: abstract,
            webURL: webURL,
            keywords: tags
        )
    }
}
