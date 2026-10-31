import Foundation

nonisolated struct TopicGroup: Identifiable, Hashable, Codable, Sendable {
    var id: String { title }
    let title: String
    let entries: [DocumentationEntry]

    var currentEntries: [DocumentationEntry] { entries.filter { !$0.isDeprecated } }
    var deprecatedEntries: [DocumentationEntry] { entries.filter(\.isDeprecated) }
}
