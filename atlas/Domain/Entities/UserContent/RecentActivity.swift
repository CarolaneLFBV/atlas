import Foundation

nonisolated struct RecentActivity: Identifiable, Hashable, Codable, Sendable {
    var id: DocumentationID { entry.id }
    let entry: DocumentationEntry
    let lastOpenedAt: Date
}
