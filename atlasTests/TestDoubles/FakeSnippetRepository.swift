import Foundation
@testable import atlas

@MainActor
final class FakeSnippetRepository: SnippetRepository {
    private(set) var saved: [CodeSnippet] = []

    func snippets() throws -> [CodeSnippet] {
        saved
    }

    func save(_ snippet: CodeSnippet) throws {
        saved.removeAll { $0.id == snippet.id }
        saved.append(snippet)
    }

    func deleteSnippet(_ id: UUID) throws {
        saved.removeAll { $0.id == id }
    }
}
