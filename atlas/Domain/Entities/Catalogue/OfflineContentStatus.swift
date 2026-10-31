import Foundation

nonisolated struct OfflineContentStatus: Identifiable, Hashable, Sendable {
    let id: DocumentationSourceID
    let displayName: String
    let downloadedPages: Int
    let lastUpdated: Date?
}
