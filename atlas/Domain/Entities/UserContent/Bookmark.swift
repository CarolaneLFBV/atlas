import Foundation

/// Keyed by `DocumentationID`, never by title.
nonisolated struct Bookmark: Identifiable, Hashable, Codable, Sendable {
    var id: DocumentationID { entry.id }
    let entry: DocumentationEntry
    let createdAt: Date
}
