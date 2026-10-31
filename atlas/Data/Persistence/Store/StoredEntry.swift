import Foundation

/// Owned by the Data layer so domain types can evolve freely: renaming a property of
/// `DocumentationEntry` changes the mapping below, never what's already on disk. Every field the
/// format adds later must be optional, so older payloads keep decoding.
nonisolated struct StoredEntry: Codable, Sendable {
    static let currentVersion = 1

    let version: Int
    let source: String
    let path: String
    let title: String
    /// See `StoredKindCode`.
    let kind: String
    let framework: String?
    let abstract: String?
    let webURL: URL?
    let keywords: [String]?
    let deprecated: Bool?

    init(_ entry: DocumentationEntry) {
        version = Self.currentVersion
        source = entry.id.sourceID.rawValue
        path = entry.id.path
        title = entry.title
        kind = StoredKindCode.code(for: entry.kind)
        framework = entry.frameworkName
        abstract = entry.abstract
        webURL = entry.webURL
        keywords = entry.keywords.isEmpty ? nil : entry.keywords
        deprecated = entry.isDeprecated ? true : nil
    }

    var entry: DocumentationEntry {
        DocumentationEntry(
            id: DocumentationID(sourceID: DocumentationSourceID(rawValue: source), path: path),
            title: title,
            kind: StoredKindCode.kind(for: kind),
            frameworkName: framework,
            abstract: abstract,
            webURL: webURL,
            keywords: keywords ?? [],
            isDeprecated: deprecated ?? false
        )
    }
}
