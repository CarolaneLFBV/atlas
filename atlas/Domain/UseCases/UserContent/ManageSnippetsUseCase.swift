import Foundation

struct ManageSnippetsUseCase {
    let repository: any SnippetRepository

    func snippets() throws -> [CodeSnippet] {
        try repository.snippets().sorted { $0.createdAt > $1.createdAt }
    }

    /// Titles are trimmed; empty code is rejected.
    func save(_ snippet: CodeSnippet) throws {
        var snippet = snippet
        snippet.title = snippet.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !snippet.code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.emptyField("code")
        }
        if snippet.title.isEmpty { snippet.title = String(localized: .snippetUntitled) }
        try repository.save(snippet)
    }

    func delete(_ id: UUID) throws {
        try repository.deleteSnippet(id)
    }
}
