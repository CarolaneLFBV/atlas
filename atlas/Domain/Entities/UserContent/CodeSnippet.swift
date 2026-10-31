import Foundation

nonisolated struct CodeSnippet: Identifiable, Hashable, Codable, Sendable {
    nonisolated enum Origin: Hashable, Codable, Sendable {
        case userAuthored
        /// Copied from a documentation page whose license permits saving it.
        case documentation(DocumentationID)
    }

    let id: UUID
    var title: String
    var language: String
    var code: String
    let origin: Origin
    let createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        language: String,
        code: String,
        origin: Origin,
        createdAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.language = language
        self.code = code
        self.origin = origin
        self.createdAt = createdAt
    }
}
