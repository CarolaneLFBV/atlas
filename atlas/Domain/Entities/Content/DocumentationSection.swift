import Foundation

nonisolated struct DocumentationSection: Identifiable, Hashable, Codable, Sendable {
    var id: String { title }
    let title: String
    let blocks: [ContentBlock]
}
