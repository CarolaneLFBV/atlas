import Foundation

nonisolated struct DocumentationCatalogue: Hashable, Codable, Sendable {
    nonisolated struct Category: Identifiable, Hashable, Codable, Sendable {
        var id: String { name }
        let name: String
        let frameworks: [DocumentationFramework]
    }

    let categories: [Category]
    let lastUpdated: Date?

    static let empty = DocumentationCatalogue(categories: [], lastUpdated: nil)

    var allFrameworks: [DocumentationFramework] { categories.flatMap(\.frameworks) }
    var isEmpty: Bool { categories.allSatisfy { $0.frameworks.isEmpty } }
}
