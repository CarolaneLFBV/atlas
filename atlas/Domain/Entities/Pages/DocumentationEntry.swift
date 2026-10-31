import Foundation

nonisolated struct DocumentationEntry: Identifiable, Hashable, Codable, Sendable {
    let id: DocumentationID
    let title: String
    let kind: DocumentationKind
    let frameworkName: String?
    /// `nil` when the source does not permit displaying prose.
    let abstract: String?
    /// Canonical public URL of the page, always preserved so users can open the official source.
    let webURL: URL?
    let keywords: [String]
    /// Deprecated entries stay available but are de-emphasized.
    let isDeprecated: Bool

    init(
        id: DocumentationID,
        title: String,
        kind: DocumentationKind,
        frameworkName: String? = nil,
        abstract: String? = nil,
        webURL: URL? = nil,
        keywords: [String] = [],
        isDeprecated: Bool = false
    ) {
        self.id = id
        self.title = title
        self.kind = kind
        self.frameworkName = frameworkName
        self.abstract = abstract
        self.webURL = webURL
        self.keywords = keywords
        self.isDeprecated = isDeprecated
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, kind, frameworkName, abstract, webURL, keywords, isDeprecated
    }

    /// Decodes entries saved before `isDeprecated` existed (bookmarks, history, search index).
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(DocumentationID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        kind = try container.decode(DocumentationKind.self, forKey: .kind)
        frameworkName = try container.decodeIfPresent(String.self, forKey: .frameworkName)
        abstract = try container.decodeIfPresent(String.self, forKey: .abstract)
        webURL = try container.decodeIfPresent(URL.self, forKey: .webURL)
        keywords = try container.decodeIfPresent([String].self, forKey: .keywords) ?? []
        isDeprecated = try container.decodeIfPresent(Bool.self, forKey: .isDeprecated) ?? false
    }

    func withoutProse() -> DocumentationEntry {
        DocumentationEntry(
            id: id, title: title, kind: kind, frameworkName: frameworkName,
            abstract: nil, webURL: webURL, keywords: keywords, isDeprecated: isDeprecated
        )
    }
}
