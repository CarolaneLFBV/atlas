import Foundation

nonisolated struct FullTextMatch: Hashable, Sendable {
    let entry: DocumentationEntry
    let sectionTitle: String
    /// A short excerpt around the first occurrence of the query.
    let excerpt: String
}
