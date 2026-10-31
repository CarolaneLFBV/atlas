import Foundation

nonisolated struct SearchResult: Identifiable, Hashable, Sendable {
    nonisolated enum Match: Hashable, Sendable {
        case metadata
        case text(sectionTitle: String, excerpt: String)
    }

    let entry: DocumentationEntry
    let match: Match

    var id: String {
        switch match {
        case .metadata: entry.id.storageKey
        case .text(let sectionTitle, _): "\(entry.id.storageKey)#\(sectionTitle)"
        }
    }
}
