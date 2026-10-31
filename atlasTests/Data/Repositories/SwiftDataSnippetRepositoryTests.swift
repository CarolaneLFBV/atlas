import Foundation
import SwiftData
import Testing
@testable import atlas

@MainActor
@Suite("SwiftDataSnippetRepository")
struct SwiftDataSnippetRepositoryTests {
    /// Retained for the suite's lifetime: a `ModelContext` does not keep its container alive.
    let container: ModelContainer
    let repository: SwiftDataSnippetRepository

    init() throws {
        container = try PersistenceStore.makeContainer(inMemory: true)
        repository = SwiftDataSnippetRepository(context: container.mainContext)
    }

    @Test("Snippets upsert by id and preserve their origin")
    func upsertPreservesOrigin() throws {
        let origin = Fixture.id("/documentation/swift/array")
        var snippet = CodeSnippet(title: "Map", language: "swift", code: "a.map { $0 }", origin: .documentation(origin))
        try repository.save(snippet)
        snippet.title = "Map values"
        try repository.save(snippet)

        let stored = try repository.snippets()
        #expect(stored.count == 1)
        #expect(stored.first?.title == "Map values")
        #expect(stored.first?.origin == .documentation(origin))
    }

    @Test("User-authored snippets round-trip and can be deleted")
    func userAuthoredAndDelete() throws {
        let snippet = CodeSnippet(title: "Mine", language: "swift", code: "print(1)", origin: .userAuthored)
        try repository.save(snippet)
        #expect(try repository.snippets().first?.origin == .userAuthored)

        try repository.deleteSnippet(snippet.id)
        #expect(try repository.snippets().isEmpty)
    }
}
