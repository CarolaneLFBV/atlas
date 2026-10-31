import Foundation
import SwiftData

enum PersistenceStore {
    static let schema = Schema([
        BookmarkRecord.self,
        SnippetRecord.self,
        RecentActivityRecord.self,
        CachedResourceRecord.self,
    ])

    static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
